//! Durable transactional-outbox relay. Reads committed events from each realm
//! shard and publishes to NATS JetStream with stable message IDs. Broker outage
//! never loses a committed gameplay event: rows stay pending until published.
use kd_common::config::Settings;
use kd_store::Store;
use std::time::Duration;

/// One claimed outbox row: identity, realm/event metadata, visibility and payload.
///
/// Naming the tuple keeps the `query_as` call readable and documents the exact
/// column order expected from the `RETURNING` clause.
type ClaimedEvent = (
    String,            // event id
    String,            // realm id
    String,            // event type
    Option<String>,    // aggregate id
    Option<i32>,       // x
    Option<i32>,       // y
    Option<String>,    // owner player id
    bool,              // is_private
    serde_json::Value, // visible_players
    serde_json::Value, // payload
    i32,               // attempts
);

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    kd_common::obs::init("outbox-worker");
    kd_common::obs::install_prometheus();
    let cfg = Settings::load()?;
    let store = Store::from_config(&cfg).await?;
    let nc = async_nats::connect(&cfg.nats_url).await?;
    let js = async_nats::jetstream::new(nc);
    js.get_or_create_stream(async_nats::jetstream::stream::Config {
        name: "KD_EVENTS".into(),
        subjects: vec!["kd.events.>".into()],
        retention: async_nats::jetstream::stream::RetentionPolicy::Limits,
        ..Default::default()
    })
    .await?;

    let http_addr: std::net::SocketAddr = cfg.http_addr.parse()?;
    tokio::spawn(async move {
        let app = axum::Router::new().route("/health", axum::routing::get(|| async { "ok" }));
        axum::serve(tokio::net::TcpListener::bind(http_addr).await.unwrap(), app)
            .await
            .unwrap();
    });

    let mut interval = tokio::time::interval(Duration::from_millis(cfg.outbox_interval_ms));
    let batch = cfg.outbox_batch as i64;
    loop {
        interval.tick().await;
        let now_ms = chrono::Utc::now().timestamp_millis();
        for (shard, pool) in &store.realm_shards {
            // Claim a bounded batch of due rows. SKIP LOCKED permits multiple
            // replicas; backoff is capped at 5 minutes and never exhausted.
            let rows: Vec<ClaimedEvent> = sqlx::query_as(
                "UPDATE outbox SET attempts=attempts+1,last_error='claim'
                 WHERE id IN (SELECT id FROM outbox WHERE realm_id IN (SELECT realm_id FROM realm_state) AND published_at_ms=0 AND (next_attempt_at_ms=0 OR next_attempt_at_ms<=$2) ORDER BY created_at_ms,id LIMIT $1 FOR UPDATE SKIP LOCKED)
                 AND realm_id IN (SELECT realm_id FROM realm_state)
                 RETURNING id::text,realm_id,event_type,aggregate_id,pos_x,pos_y,owner_player_id::text,is_private,visible_players,payload,attempts",
            ).bind(batch).bind(now_ms).fetch_all(pool).await.unwrap_or_else(|e| {
                tracing::error!(shard, error=%e, "outbox claim failed");
                Vec::new()
            });
            // Shard scoping is enforced by separate DB pools; the realm_id
            // filter keeps multi-realm shards isolated.
            for (id, realm, typ, agg, x, y, owner, private, visible, payload, attempts) in rows {
                let subject = format!("kd.events.{realm}.{typ}");
                let body = serde_json::json!({
                    "event_id": id, "realm_id": realm, "event_type": typ, "aggregate_id": agg,
                    "pos_x": x, "pos_y": y, "owner_player_id": owner, "private": private,
                    "visible_players": visible, "payload": payload,
                });
                let mut headers = async_nats::HeaderMap::new();
                headers.insert("Nats-Msg-Id", id.as_str());
                let res = js
                    .publish_with_headers(
                        subject,
                        headers,
                        serde_json::to_vec(&body).unwrap_or_default().into(),
                    )
                    .await;
                match res {
                    Ok(_ack) => {
                        let now = chrono::Utc::now().timestamp_millis();
                        if let Err(e) = sqlx::query("UPDATE outbox SET published_at_ms=$2,last_error=NULL,next_attempt_at_ms=0 WHERE id=$1 AND realm_id=$3")
                            .bind(&id).bind(now).bind(&realm).execute(pool).await {
                            tracing::error!(event_id=%id, error=%e, "published-event ack failed; Nats-Msg-Id makes replay idempotent");
                        }
                        metrics::counter!("kd_outbox_published_total").increment(1);
                    }
                    Err(e) => {
                        // Capped exponential backoff: 1s, 2s, 4s, ... 300s.
                        let delay = 1000i64 * 2i64.pow(attempts.min(8) as u32);
                        let delay = delay.min(300_000);
                        let retry_at = chrono::Utc::now().timestamp_millis() + delay;
                        if let Err(db) = sqlx::query(
                            "UPDATE outbox SET last_error=$2,next_attempt_at_ms=$3 WHERE id=$1",
                        )
                        .bind(&id)
                        .bind(e.to_string())
                        .bind(retry_at)
                        .execute(pool)
                        .await
                        {
                            tracing::error!(event_id=%id, error=%db, "failed to record outbox retry schedule");
                        }
                        metrics::counter!("kd_outbox_publish_failures_total").increment(1);
                        tracing::warn!(event_id = %id, error = %e, "outbox publish failed; will retry");
                        break;
                    }
                }
            }
        }
    }
}
