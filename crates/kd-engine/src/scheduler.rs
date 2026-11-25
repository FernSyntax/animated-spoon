//! Persistent discrete-event scheduler. Works with zero connected clients,
//! processes overdue events in stable (due_at, priority, id) order in bounded batches.
use crate::commands;
use crate::engine::Engine;
use serde_json::{json, Value};
use std::collections::HashMap;
use tracing::{debug, warn};

/// Process one bounded batch of overdue events; returns the number handled.
pub async fn tick(engine: &Engine) -> anyhow::Result<usize> {
    // Reclaim events left 'processing' by a crashed owner.
    {
        let mut tx = engine.tx().await?;
        sqlx::query("UPDATE scheduled_events SET status='pending' WHERE realm_id=$1 AND status='processing'")
            .bind(&engine.realm_id).execute(&mut *tx).await?;
        tx.commit().await?;
    }

    let claimed: Vec<(String, String, Value)> = {
        let mut tx = engine.tx().await?;
        let now = engine.now_ms(&mut tx).await?;
        let rows: Vec<(String, String, Value)> = sqlx::query_as(
            "UPDATE scheduled_events SET status='processing',locked_by=$4
             WHERE id IN (SELECT id FROM scheduled_events WHERE realm_id=$1 AND status='pending' AND due_at_ms<=$2
                          ORDER BY due_at_ms,priority,id LIMIT $3 FOR UPDATE SKIP LOCKED)
             RETURNING id::text,kind,payload",
        ).bind(&engine.realm_id).bind(now).bind(engine.scheduler_batch).bind(&engine.worker_id)
         .fetch_all(&mut *tx).await?;
        tx.commit().await?;
        rows
    };

    let mut processed = 0;
    for (id, kind, mut payload) in claimed {
        if let Ok(m) = serde_json::from_value::<HashMap<String, Value>>(payload.clone()) {
            let mut m = m;
            m.insert("_event_id".into(), json!(id));
            payload = serde_json::to_value(m).unwrap_or(payload);
        }
        let mut tx = match engine.tx().await {
            Ok(t) => t,
            Err(e) => {
                warn!(error = %e, "lost ownership while processing event");
                break;
            }
        };
        let result = commands::handle_event(engine, &mut tx, &kind, &payload).await;
        match result {
            Ok(()) => {
                let now = engine.now_ms(&mut tx).await.unwrap_or(0);
                sqlx::query("UPDATE scheduled_events SET status='done',processed_at_ms=$3 WHERE realm_id=$1 AND id=$2::uuid")
                    .bind(&engine.realm_id).bind(&id).bind(now).execute(&mut *tx).await?;
                tx.commit().await?;
                processed += 1;
                debug!(event_id = %id, kind, "event applied");
            }
            Err(e) => {
                let attempts: (i32,) = sqlx::query_as("SELECT COALESCE(attempts,0) FROM scheduled_events WHERE realm_id=$1 AND id=$2::uuid")
                    .bind(&engine.realm_id).bind(&id).fetch_one(&mut *tx).await.unwrap_or((0,));
                if attempts.0 < 5 {
                    let delay = 1000i64 * (1i64 << attempts.0.min(4));
                    let now = engine.now_ms(&mut tx).await.unwrap_or(0);
                    sqlx::query("UPDATE scheduled_events SET status='pending',attempts=attempts+1,due_at_ms=$3,locked_by=NULL WHERE realm_id=$1 AND id=$2::uuid")
                        .bind(&engine.realm_id).bind(&id).bind(now + delay).execute(&mut *tx).await?;
                } else {
                    sqlx::query("UPDATE scheduled_events SET status='failed',attempts=attempts+1,locked_by=NULL WHERE realm_id=$1 AND id=$2::uuid")
                        .bind(&engine.realm_id).bind(&id).execute(&mut *tx).await?;
                }
                tx.commit().await?;
                warn!(event_id = %id, kind, error = %e, "event failed; scheduled retry");
            }
        }
    }
    Ok(processed)
}

/// Backlog metrics query helper used by /metrics and readiness probes.
///
/// `due_at_ms` is in the realm's virtual clock, so the lag comparison must use
/// the same clock — wall time becomes meaningless after an `advance_clock`.
pub async fn backlog(engine: &Engine) -> anyhow::Result<(i64, i64)> {
    let mut tx = engine.pool.begin().await?;
    let now = engine.now_ms(&mut tx).await?;
    tx.commit().await?;
    let row: (i64, i64) = sqlx::query_as(
        "SELECT count(*), COALESCE(max($2 - due_at_ms),0) FROM scheduled_events WHERE realm_id=$1 AND status='pending'",
    )
    .bind(&engine.realm_id)
    .bind(now)
    .fetch_one(&engine.pool)
    .await?;
    Ok(row)
}
