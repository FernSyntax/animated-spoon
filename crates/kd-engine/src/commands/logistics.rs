//! Gathering and returning-march settlement.
//!
//! Split out of `events.rs`; shared helpers live in the parent.
use super::*;

/// Credit gathered resources from a finite node to the returning march.
pub async fn resolve_gather(
    engine: &Engine,
    tx: &mut Transaction<'_, Postgres>,
    payload: &Value,
) -> AppResult<()> {
    let march_id = payload["march_id"].as_str().unwrap_or("");
    let entity_id = payload["entity_id"].as_str().unwrap_or("");
    let carry = payload["carry"].as_i64().unwrap_or(0);
    let node: Option<(i64, String, i32)> =
        sqlx::query_as("SELECT stock,subtype,level FROM entity_state WHERE realm_id=$1 AND id=$2")
            .bind(&engine.realm_id)
            .bind(entity_id)
            .fetch_optional(&mut **tx)
            .await
            .map_err(|e| AppError::Internal(e.to_string()))?;
    let mut loot = ResVec::default();
    if let Some((stock, subtype, _)) = node {
        let take = stock.min(carry).max(0);
        if let Some(r) = Resource::parse(&subtype) {
            loot.set(r, take);
        }
        sqlx::query("UPDATE entity_state SET stock=stock-$3 WHERE realm_id=$1 AND id=$2")
            .bind(&engine.realm_id)
            .bind(entity_id)
            .bind(take)
            .execute(&mut **tx)
            .await
            .map_err(|e| AppError::Internal(e.to_string()))?;
        if take >= stock && stock > 0 {
            let now = engine
                .now_ms(tx)
                .await
                .map_err(|e| AppError::Internal(e.to_string()))?;
            let replenish = now + 120_000;
            sqlx::query("UPDATE entity_state SET respawn_at_ms=$3 WHERE realm_id=$1 AND id=$2")
                .bind(&engine.realm_id)
                .bind(entity_id)
                .bind(replenish)
                .execute(&mut **tx)
                .await
                .map_err(|e| AppError::Internal(e.to_string()))?;
            engine
                .schedule(
                    tx,
                    replenish,
                    400,
                    "node_replenish",
                    json!({"entity_id":entity_id}),
                )
                .await
                .map_err(|e| AppError::Internal(e.to_string()))?;
        }
    }
    sqlx::query("UPDATE marches SET resources=$3,version=version+1 WHERE realm_id=$1 AND id=$2")
        .bind(&engine.realm_id)
        .bind(march_id)
        .bind(serde_json::to_value(loot)?)
        .execute(&mut **tx)
        .await
        .map_err(|e| AppError::Internal(e.to_string()))?;
    let now = engine
        .now_ms(tx)
        .await
        .map_err(|e| AppError::Internal(e.to_string()))?;
    let row: Option<(i32, i32, i32, i32)> =
        sqlx::query_as("SELECT from_x,from_y,to_x,to_y FROM marches WHERE realm_id=$1 AND id=$2")
            .bind(&engine.realm_id)
            .bind(march_id)
            .fetch_optional(&mut **tx)
            .await
            .map_err(|e| AppError::Internal(e.to_string()))?;
    let (fx, fy, to_x, to_y) = row.unwrap_or((0, 0, 0, 0));
    let return_ms = (distance((to_x, to_y), (fx, fy)) + 1) * 1000;
    sqlx::query("UPDATE marches SET state='returning',return_at_ms=$3 WHERE realm_id=$1 AND id=$2")
        .bind(&engine.realm_id)
        .bind(march_id)
        .bind(now + return_ms)
        .execute(&mut **tx)
        .await
        .map_err(|e| AppError::Internal(e.to_string()))?;
    engine
        .schedule(
            tx,
            now + return_ms,
            300,
            "march_return",
            json!({"march_id":march_id}),
        )
        .await
        .map_err(|e| AppError::Internal(e.to_string()))?;
    Ok(())
}
/// Return a march to its origin and restore its garrison.
pub async fn resolve_return(
    engine: &Engine,
    tx: &mut Transaction<'_, Postgres>,
    payload: &Value,
) -> AppResult<()> {
    let march_id = payload["march_id"].as_str().unwrap_or("");
    let row: Option<(String, String, String, Value, Value)> = sqlx::query_as("SELECT player_id::text,state,from_city_id,troops,resources FROM marches WHERE realm_id=$1 AND id=$2")
        .bind(&engine.realm_id).bind(march_id).fetch_optional(&mut **tx).await.map_err(|e| AppError::Internal(e.to_string()))?;
    let (player, state, from_city, troops_json, cargo_json) =
        row.ok_or_else(|| AppError::NotFound("march missing".into()))?;
    if state == "completed" {
        return Ok(());
    }
    let units: Vec<ArmyUnit> = serde_json::from_value(troops_json).unwrap_or_default();
    let cargo: ResVec = serde_json::from_value(cargo_json).unwrap_or_default();
    // Return to the recorded home city if still owned; otherwise any owned city; never an enemy's.
    let home: Option<(String,)> = sqlx::query_as(
        "SELECT city_id FROM cities WHERE realm_id=$1 AND city_id=$2 AND player_id=$3::uuid",
    )
    .bind(&engine.realm_id)
    .bind(&from_city)
    .bind(&player)
    .fetch_optional(&mut **tx)
    .await
    .map_err(|e| AppError::Internal(e.to_string()))?;
    let target = match home {
        Some((c,)) => c,
        None => sqlx::query_as::<_, (String,)>(
            "SELECT city_id FROM cities WHERE realm_id=$1 AND player_id=$2::uuid LIMIT 1",
        )
        .bind(&engine.realm_id)
        .bind(&player)
        .fetch_optional(&mut **tx)
        .await
        .map_err(|e| AppError::Internal(e.to_string()))?
        .map(|c| c.0)
        .ok_or(AppError::NoTarget)?,
    };
    add_troop_list(tx, &engine.realm_id, &target, &units).await?;
    credit(tx, &engine.realm_id, &target, cargo).await?;
    sqlx::query("UPDATE heroes SET assignment='' WHERE realm_id=$1 AND player_id=$2::uuid AND assignment=$3")
        .bind(&engine.realm_id).bind(&player).bind(march_id).execute(&mut **tx).await.map_err(|e| AppError::Internal(e.to_string()))?;
    sqlx::query(
        "UPDATE marches SET state='completed',version=version+1 WHERE realm_id=$1 AND id=$2",
    )
    .bind(&engine.realm_id)
    .bind(march_id)
    .execute(&mut **tx)
    .await
    .map_err(|e| AppError::Internal(e.to_string()))?;
    bump_version(tx, &engine.realm_id).await?;
    delta(
        engine,
        tx,
        "march.returned",
        EventRouting {
            pos: None,
            aggregate_id: march_id.into(),
            owner_player_id: Some(player.clone()),
            private: true,
            visible_players: vec![player],
        },
        json!({"march_id":march_id,"survivors":units}),
    )
    .await?;
    Ok(())
}
