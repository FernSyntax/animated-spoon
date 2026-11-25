//! Rally coordination and chat fanout.
//!
//! Split out of `commands.rs`; shared helpers live in the parent module.
use super::*;

/// Reserve a rally at a target with a departure time.
pub async fn rally_create(
    engine: &Engine,
    tx: &mut Transaction<'_, Postgres>,
    player: &str,
    cmd: &kd_proto::RallyCreateCmd,
) -> AppResult<()> {
    let ally = require_role(tx, &engine.realm_id, player, &["leader", "officer"]).await?;
    let city = load_city(tx, &engine.realm_id, &cmd.city_id).await?;
    if city.player_id != player {
        return Err(AppError::Forbidden("not your city".into()));
    }
    let pos = cmd
        .target_pos
        .as_ref()
        .ok_or_else(|| AppError::Invalid("target required".into()))?;
    let now = engine
        .now_ms(tx)
        .await
        .map_err(|e| AppError::Internal(e.to_string()))?;
    let start = cmd.start_at_unix_ms.max(now + 5000);
    // Store the actual target id; an empty id made every launched rally attack
    // a phantom garrison instead of the fort/city the leader selected.
    let target_id: Option<(String,)> =
        sqlx::query_as("SELECT city_id FROM cities WHERE realm_id=$1 AND x=$2 AND y=$3 LIMIT 1")
            .bind(&engine.realm_id)
            .bind(pos.x)
            .bind(pos.y)
            .fetch_optional(&mut **tx)
            .await
            .map_err(|e| AppError::Internal(e.to_string()))?;
    let target_id = match target_id {
        Some((id,)) => id,
        None => {
            sqlx::query_as::<_, (String,)>(
                "SELECT id FROM entity_state WHERE realm_id=$1 AND x=$2 AND y=$3 LIMIT 1",
            )
            .bind(&engine.realm_id)
            .bind(pos.x)
            .bind(pos.y)
            .fetch_optional(&mut **tx)
            .await
            .map_err(|e| AppError::Internal(e.to_string()))?
            .ok_or_else(|| AppError::NotFound("no target at rally position".into()))?
            .0
        }
    };
    let id = kd_domain::new_id();
    sqlx::query("INSERT INTO rallies(realm_id,rally_id,leader_id,alliance_id,from_city_id,to_x,to_y,target_id,start_at_ms,state) VALUES ($1,$2,$3::uuid,$4,$5,$6,$7,$8,$9,'forming')")
        .bind(&engine.realm_id).bind(&id).bind(player).bind(ally).bind(&cmd.city_id)
        .bind(pos.x).bind(pos.y).bind(&target_id).bind(start)
        .execute(&mut **tx).await.map_err(|e| AppError::Internal(e.to_string()))?;
    engine
        .schedule(tx, start, 250, "rally_launch", json!({"rally_id":id}))
        .await
        .map_err(|e| AppError::Internal(e.to_string()))?;
    Ok(())
}

/// Add an ally's troops to an open rally.
pub async fn rally_join(
    engine: &Engine,
    tx: &mut Transaction<'_, Postgres>,
    player: &str,
    cmd: &kd_proto::RallyJoinCmd,
) -> AppResult<()> {
    let (rally_ally, leader, from_city, state): (String, String, String, String) = sqlx::query_as("SELECT alliance_id,leader_id,from_city_id,state FROM rallies WHERE realm_id=$1 AND rally_id=$2")
        .bind(&engine.realm_id).bind(&cmd.rally_id).fetch_one(&mut **tx).await.map_err(|_| AppError::NotFound("rally not found".into()))?;
    if state != "forming" {
        return Err(AppError::Conflict("rally already launched".into()));
    }
    let (_, ally, _) = player_exists(tx, &engine.realm_id, player).await?;
    if ally.as_deref() != Some(rally_ally.as_str()) {
        return Err(AppError::Forbidden("rally is alliance-only".into()));
    }
    let units = troops_from_proto(&cmd.troops)?;
    let cities = owned_cities(tx, &engine.realm_id, player).await?;
    let origin = cities
        .iter()
        .find(|c| c.is_capital)
        .ok_or(AppError::NoTarget)?;
    for u in &units {
        let have = load_troops(tx, &engine.realm_id, &origin.city_id).await?;
        let n = have
            .iter()
            .find(|x| x.unit == u.unit && x.tier == u.tier)
            .map(|x| x.count)
            .unwrap_or(0);
        if n < u.count {
            return Err(AppError::InsufficientTroops("not enough troops".into()));
        }
    }
    let previous: Option<(Value,)> = sqlx::query_as(
        "SELECT troops FROM rally_members WHERE realm_id=$1 AND rally_id=$2 AND player_id=$3::uuid",
    )
    .bind(&engine.realm_id)
    .bind(&cmd.rally_id)
    .bind(player)
    .fetch_optional(&mut **tx)
    .await
    .map_err(|e| AppError::Internal(e.to_string()))?;
    if let Some((troops,)) = previous {
        let old: Vec<ArmyUnit> = serde_json::from_value(troops).unwrap_or_default();
        add_troop_list(tx, &engine.realm_id, &origin.city_id, &old).await?;
    }
    apply_troop_list(tx, &engine.realm_id, &origin.city_id, &units).await?;
    sqlx::query("INSERT INTO rally_members(realm_id,rally_id,player_id,troops,hero,joined_at_ms) VALUES ($1,$2,$3::uuid,$4,$5,$6) ON CONFLICT(realm_id,rally_id,player_id) DO UPDATE SET troops=$4,hero=$5")
        .bind(&engine.realm_id).bind(&cmd.rally_id).bind(player).bind(serde_json::to_value(&units)?).bind("")
        .bind(engine.now_ms(tx).await.map_err(|e| AppError::Internal(e.to_string()))?)
        .execute(&mut **tx).await.map_err(|e| AppError::Internal(e.to_string()))?;
    let _ = (leader, from_city);
    Ok(())
}

/// Cancel a rally before launch and return reserved troops.
pub async fn rally_cancel(
    engine: &Engine,
    tx: &mut Transaction<'_, Postgres>,
    player: &str,
    cmd: &kd_proto::RallyCancelCmd,
) -> AppResult<()> {
    let (leader, state): (String, String) =
        sqlx::query_as("SELECT leader_id,state FROM rallies WHERE realm_id=$1 AND rally_id=$2")
            .bind(&engine.realm_id)
            .bind(&cmd.rally_id)
            .fetch_one(&mut **tx)
            .await
            .map_err(|_| AppError::NotFound("rally not found".into()))?;
    if leader != player {
        return Err(AppError::Forbidden("only leader can cancel".into()));
    }
    if state != "forming" {
        return Err(AppError::Conflict("rally already launched".into()));
    }
    sqlx::query("UPDATE rallies SET state='cancelled' WHERE realm_id=$1 AND rally_id=$2")
        .bind(&engine.realm_id)
        .bind(&cmd.rally_id)
        .execute(&mut **tx)
        .await
        .map_err(|e| AppError::Internal(e.to_string()))?;
    sqlx::query("UPDATE scheduled_events SET status='cancelled' WHERE realm_id=$1 AND status='pending' AND payload->>'rally_id'=$2")
        .bind(&engine.realm_id).bind(&cmd.rally_id).execute(&mut **tx).await.map_err(|e| AppError::Internal(e.to_string()))?;
    let members: Vec<(String, Value)> = sqlx::query_as(
        "SELECT player_id::text,troops FROM rally_members WHERE realm_id=$1 AND rally_id=$2",
    )
    .bind(&engine.realm_id)
    .bind(&cmd.rally_id)
    .fetch_all(&mut **tx)
    .await
    .map_err(|e| AppError::Internal(e.to_string()))?;
    for (pid, troops) in members {
        let units: Vec<ArmyUnit> = serde_json::from_value(troops).unwrap_or_default();
        let cities = owned_cities(tx, &engine.realm_id, &pid).await?;
        if let Some(c) = cities.iter().find(|c| c.is_capital) {
            add_troop_list(tx, &engine.realm_id, &c.city_id, &units).await?;
        }
    }
    sqlx::query("DELETE FROM rally_members WHERE realm_id=$1 AND rally_id=$2")
        .bind(&engine.realm_id)
        .bind(&cmd.rally_id)
        .execute(&mut **tx)
        .await
        .map_err(|e| AppError::Internal(e.to_string()))?;
    Ok(())
}

/// Publish a world or alliance chat message as an outbox event.
pub async fn chat(
    engine: &Engine,
    tx: &mut Transaction<'_, Postgres>,
    player: &str,
    cmd: &kd_proto::ChatCmd,
) -> AppResult<()> {
    if cmd.text.trim().is_empty() || cmd.text.len() > 500 {
        return Err(AppError::Invalid("invalid message".into()));
    }
    let (name, ally, _): (String, Option<String>, Option<String>) =
        player_exists(tx, &engine.realm_id, player).await?;
    let scope = match cmd.scope.as_str() {
        "world" | "alliance" => cmd.scope.clone(),
        _ => return Err(AppError::Invalid("invalid chat scope".into())),
    };
    if scope == "alliance" && ally.is_none() {
        return Err(AppError::Forbidden("no alliance".into()));
    }
    let id = uuid::Uuid::new_v4().to_string();
    let now = engine
        .now_ms(tx)
        .await
        .map_err(|e| AppError::Internal(e.to_string()))?;
    let target = if scope == "alliance" {
        ally.clone().unwrap_or_default()
    } else {
        String::new()
    };
    sqlx::query("INSERT INTO chat_messages(id,realm_id,scope,target_id,sender_id,sender_name,text,created_at_ms) VALUES ($1::uuid,$2,$3,$4,$5::uuid,$6,$7,$8)")
        .bind(id).bind(&engine.realm_id).bind(&scope).bind(&target).bind(player).bind(&name).bind(cmd.text.trim()).bind(now)
        .execute(&mut **tx).await.map_err(|e| AppError::Internal(e.to_string()))?;
    let routing = if scope == "alliance" {
        EventRouting {
            pos: None,
            aggregate_id: target.clone(),
            private: true,
            visible_players: alliance_member_ids(tx, &engine.realm_id, &target).await?,
            owner_player_id: None,
        }
    } else {
        EventRouting {
            pos: None,
            aggregate_id: "world".into(),
            private: false,
            visible_players: vec![],
            owner_player_id: None,
        }
    };
    delta(
        engine,
        tx,
        "chat.message",
        routing,
        json!({"scope":scope,"from":name,"text":cmd.text}),
    )
    .await?;
    Ok(())
}

/// List the player ids belonging to an alliance.
pub async fn alliance_member_ids(
    tx: &mut Transaction<'_, Postgres>,
    realm: &str,
    ally: &str,
) -> AppResult<Vec<String>> {
    let rows: Vec<(String,)> = sqlx::query_as(
        "SELECT player_id::text FROM alliance_members WHERE realm_id=$1 AND alliance_id=$2",
    )
    .bind(realm)
    .bind(ally)
    .fetch_all(&mut **tx)
    .await
    .map_err(|e| AppError::Internal(e.to_string()))?;
    Ok(rows.into_iter().map(|r| r.0).collect())
}
