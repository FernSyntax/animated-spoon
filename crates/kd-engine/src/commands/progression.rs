//! Season scoring and deterministic world seeding.
//!
//! Split out of `events.rs`; shared helpers live in the parent.
use super::*;

/// Increase a player's season score after a scoring event.
pub async fn bump_score(
    tx: &mut Transaction<'_, Postgres>,
    realm: &str,
    player: &str,
    ally: Option<&str>,
    points: i64,
) -> AppResult<()> {
    let key = format!("p:{player}");
    sqlx::query("INSERT INTO season_scores(realm_id,score_key,player_id,score) VALUES ($1,$2,$3::uuid,$4) ON CONFLICT(realm_id,score_key) DO UPDATE SET score=season_scores.score+$4")
        .bind(realm).bind(key).bind(player).bind(points).execute(&mut **tx).await.map_err(|e| AppError::Internal(e.to_string()))?;
    if let Some(a) = ally {
        sqlx::query("INSERT INTO season_scores(realm_id,score_key,alliance_id,score) VALUES ($1,$2,$3,$4) ON CONFLICT(realm_id,score_key) DO UPDATE SET score=season_scores.score+$4")
            .bind(realm).bind(format!("a:{a}")).bind(a).bind(points).execute(&mut **tx).await.map_err(|e| AppError::Internal(e.to_string()))?;
    }
    Ok(())
}
/// Seed deterministic monsters/nodes/forts into entity_state on first provision.
pub async fn seed_entities(
    pool: &PgPool,
    realm_id: &str,
    seed: u64,
    chunk_size: i32,
) -> anyhow::Result<usize> {
    let mut count = 0;
    for cy in 0..8 {
        for cx in 0..8 {
            for e in world::entities_for_chunk(seed, cx, cy, chunk_size) {
                let (hp, stock) = match e.kind {
                    EntityKind::Monster => (e.level * 100, 0),
                    EntityKind::ResourceNode => (0, e.level * 5000),
                    EntityKind::Fort => (e.level * 500, 0),
                };
                let r = sqlx::query(
                    "INSERT INTO entity_state(realm_id,id,kind,x,y,level,subtype,stock,hp,owner_player_id) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,NULL) ON CONFLICT DO NOTHING",
                ).bind(realm_id).bind(&e.id).bind(e.kind.key()).bind(e.x).bind(e.y).bind(e.level)
                 .bind(&e.subtype).bind(stock).bind(hp).execute(pool).await?;
                count += r.rows_affected() as usize;
            }
        }
    }
    // Kick off the recurring world spawner. It re-arms itself after every tick
    // and is processed by the same durable scheduler as all other events.
    let now: (i64,) = sqlx::query_as("SELECT wall_now_ms()")
        .fetch_one(pool)
        .await?;
    sqlx::query(
        "INSERT INTO scheduled_events(id,realm_id,kind,due_at_ms,priority,payload,status,created_at_ms)
         VALUES ($1::uuid,$2,'monster_spawn',$3,250,'{\"seq\":0}','pending',$3) ON CONFLICT DO NOTHING",
    )
    .bind(uuid::Uuid::new_v4().to_string())
    .bind(realm_id)
    .bind(now.0 + 15 * 60 * 1000)
    .execute(pool)
    .await?;
    Ok(count)
}
