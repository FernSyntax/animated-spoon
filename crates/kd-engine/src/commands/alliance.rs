//! Alliance lifecycle, membership and mutual help.
//!
//! Split out of `commands.rs`; shared helpers live in the parent module.
use super::*;

/// Found an alliance with the player as its first leader.
pub async fn create_alliance(
    engine: &Engine,
    tx: &mut Transaction<'_, Postgres>,
    player: &str,
    cmd: &kd_proto::CreateAllianceCmd,
) -> AppResult<()> {
    let (_, ally, _) = player_exists(tx, &engine.realm_id, player).await?;
    if ally.is_some() {
        return Err(AppError::Conflict("already in an alliance".into()));
    }
    if cmd.name.trim().len() < 2 || cmd.tag.trim().is_empty() || cmd.tag.len() > 6 {
        return Err(AppError::Invalid("invalid alliance name/tag".into()));
    }
    let id = kd_domain::new_id();
    let now = engine
        .now_ms(tx)
        .await
        .map_err(|e| AppError::Internal(e.to_string()))?;
    sqlx::query("INSERT INTO alliances(realm_id,alliance_id,name,tag,leader_id,created_at_ms) VALUES ($1,$2,$3,$4,$5::uuid,$6)")
        .bind(&engine.realm_id).bind(&id).bind(cmd.name.trim()).bind(cmd.tag.trim()).bind(player).bind(now)
        .execute(&mut **tx).await.map_err(|_e| AppError::Conflict("tag already used".into()))?;
    sqlx::query("INSERT INTO alliance_members(realm_id,alliance_id,player_id,role,joined_at_ms) VALUES ($1,$2,$3::uuid,'leader',$4)")
        .bind(&engine.realm_id).bind(&id).bind(player).bind(now).execute(&mut **tx).await.map_err(|e| AppError::Internal(e.to_string()))?;
    sqlx::query("UPDATE players SET alliance_id=$2,alliance_role='leader' WHERE realm_id=$1 AND player_id=$3::uuid")
        .bind(&engine.realm_id).bind(&id).bind(player).execute(&mut **tx).await.map_err(|e| AppError::Internal(e.to_string()))?;
    Ok(())
}

/// Assert the player holds one of the allowed alliance roles.
pub async fn require_role(
    tx: &mut Transaction<'_, Postgres>,
    realm: &str,
    player: &str,
    roles: &[&str],
) -> AppResult<String> {
    let (ally, role): (Option<String>, Option<String>) = sqlx::query_as(
        "SELECT alliance_id,alliance_role FROM players WHERE realm_id=$1 AND player_id=$2::uuid",
    )
    .bind(realm)
    .bind(player)
    .fetch_one(&mut **tx)
    .await
    .map_err(|e| AppError::Internal(e.to_string()))?;
    let role = role.ok_or_else(|| AppError::Forbidden("no alliance role".into()))?;
    if !roles.contains(&role.as_str()) {
        return Err(AppError::Forbidden("insufficient alliance role".into()));
    }
    ally.ok_or_else(|| AppError::Forbidden("no alliance".into()))
}

/// Invite a player to an alliance.
pub async fn alliance_invite(
    engine: &Engine,
    tx: &mut Transaction<'_, Postgres>,
    player: &str,
    cmd: &kd_proto::AllianceInviteCmd,
) -> AppResult<()> {
    let ally = require_role(tx, &engine.realm_id, player, &["leader", "officer"]).await?;
    if cmd.player_id == player {
        return Err(AppError::Invalid("cannot invite self".into()));
    }
    let (_, target_ally): (String, Option<String>) = sqlx::query_as(
        "SELECT name,alliance_id FROM players WHERE realm_id=$1 AND player_id=$2::uuid",
    )
    .bind(&engine.realm_id)
    .bind(&cmd.player_id)
    .fetch_one(&mut **tx)
    .await
    .map_err(|_| AppError::NotFound("player not found".into()))?;
    if target_ally.is_some() {
        return Err(AppError::Conflict("player already in alliance".into()));
    }
    let now = engine
        .now_ms(tx)
        .await
        .map_err(|e| AppError::Internal(e.to_string()))?;
    sqlx::query("INSERT INTO alliance_invites(realm_id,alliance_id,player_id,invited_by,created_at_ms) VALUES ($1,$2,$3::uuid,$4::uuid,$5) ON CONFLICT(realm_id,alliance_id,player_id) DO UPDATE SET created_at_ms=$5,invited_by=$4::uuid")
        .bind(&engine.realm_id).bind(ally).bind(&cmd.player_id).bind(player).bind(now)
        .execute(&mut **tx).await.map_err(|e| AppError::Internal(e.to_string()))?;
    Ok(())
}

/// Accept a pending invitation and join the alliance.
pub async fn alliance_accept(
    engine: &Engine,
    tx: &mut Transaction<'_, Postgres>,
    player: &str,
    cmd: &kd_proto::AllianceAcceptCmd,
) -> AppResult<()> {
    let (_, ally, _): (String, Option<String>, Option<String>) =
        player_exists(tx, &engine.realm_id, player).await?;
    if ally.is_some() {
        return Err(AppError::Conflict("already in an alliance".into()));
    }
    let inv: Option<(String,)> = sqlx::query_as("SELECT alliance_id FROM alliance_invites WHERE realm_id=$1 AND player_id=$2::uuid AND alliance_id=$3")
        .bind(&engine.realm_id).bind(player).bind(&cmd.alliance_id).fetch_optional(&mut **tx).await.map_err(|e| AppError::Internal(e.to_string()))?;
    inv.ok_or_else(|| AppError::NotFound("no invite".into()))?;
    join_alliance_inner(tx, &engine.realm_id, player, &cmd.alliance_id, "member").await
}

/// Join an alliance by id (used by internal callers).
pub async fn alliance_join(
    engine: &Engine,
    tx: &mut Transaction<'_, Postgres>,
    player: &str,
    cmd: &kd_proto::AllianceJoinCmd,
) -> AppResult<()> {
    let (_, ally, _): (String, Option<String>, Option<String>) =
        player_exists(tx, &engine.realm_id, player).await?;
    if ally.is_some() {
        return Err(AppError::Conflict("already in an alliance".into()));
    }
    let inv: Option<(String,)> = sqlx::query_as("SELECT alliance_id FROM alliance_invites WHERE realm_id=$1 AND player_id=$2::uuid AND alliance_id=$3")
        .bind(&engine.realm_id).bind(player).bind(&cmd.alliance_id).fetch_optional(&mut **tx).await.map_err(|e| AppError::Internal(e.to_string()))?;
    inv.ok_or_else(|| AppError::Forbidden("invite required".into()))?;
    join_alliance_inner(tx, &engine.realm_id, player, &cmd.alliance_id, "member").await
}

/// Shared membership transaction for invite/join flows.
pub async fn join_alliance_inner(
    tx: &mut Transaction<'_, Postgres>,
    realm: &str,
    player: &str,
    ally: &str,
    role: &str,
) -> AppResult<()> {
    let n: (i64,) = sqlx::query_as(
        "SELECT count(*) FROM alliance_members WHERE realm_id=$1 AND alliance_id=$2",
    )
    .bind(realm)
    .bind(ally)
    .fetch_one(&mut **tx)
    .await
    .map_err(|e| AppError::Internal(e.to_string()))?;
    if n.0 >= 100 {
        return Err(AppError::QueueFull("alliance full".into()));
    }
    let now: (i64,) = sqlx::query_as("SELECT clock_now_ms($1)")
        .bind(realm)
        .fetch_one(&mut **tx)
        .await
        .map_err(|e| AppError::Internal(e.to_string()))?;
    sqlx::query("INSERT INTO alliance_members(realm_id,alliance_id,player_id,role,joined_at_ms) VALUES ($1,$2,$3::uuid,$4,$5)")
        .bind(realm).bind(ally).bind(player).bind(role).bind(now.0).execute(&mut **tx).await.map_err(|e| AppError::Internal(e.to_string()))?;
    sqlx::query("UPDATE players SET alliance_id=$2,alliance_role=$3 WHERE realm_id=$1 AND player_id=$4::uuid")
        .bind(realm).bind(ally).bind(role).bind(player).execute(&mut **tx).await.map_err(|e| AppError::Internal(e.to_string()))?;
    sqlx::query(
        "DELETE FROM alliance_invites WHERE realm_id=$1 AND alliance_id=$2 AND player_id=$3::uuid",
    )
    .bind(realm)
    .bind(ally)
    .bind(player)
    .execute(&mut **tx)
    .await
    .map_err(|e| AppError::Internal(e.to_string()))?;
    Ok(())
}

/// Leave an alliance, dissolving it if the last member departs.
pub async fn alliance_leave(
    engine: &Engine,
    tx: &mut Transaction<'_, Postgres>,
    player: &str,
) -> AppResult<()> {
    let ally = require_role(
        tx,
        &engine.realm_id,
        player,
        &["leader", "officer", "member"],
    )
    .await?;
    let leader: (String,) = sqlx::query_as(
        "SELECT leader_id::text FROM alliances WHERE realm_id=$1 AND alliance_id=$2",
    )
    .bind(&engine.realm_id)
    .bind(&ally)
    .fetch_one(&mut **tx)
    .await
    .map_err(|e| AppError::Internal(e.to_string()))?;
    sqlx::query(
        "DELETE FROM alliance_members WHERE realm_id=$1 AND alliance_id=$2 AND player_id=$3::uuid",
    )
    .bind(&engine.realm_id)
    .bind(&ally)
    .bind(player)
    .execute(&mut **tx)
    .await
    .map_err(|e| AppError::Internal(e.to_string()))?;
    sqlx::query("UPDATE players SET alliance_id=NULL,alliance_role=NULL WHERE realm_id=$1 AND player_id=$2::uuid")
        .bind(&engine.realm_id).bind(player).execute(&mut **tx).await.map_err(|e| AppError::Internal(e.to_string()))?;
    if leader.0 == player {
        // Transfer leadership to the earliest remaining member, or dissolve.
        let next: Option<(String,)> = sqlx::query_as("SELECT player_id::text FROM alliance_members WHERE realm_id=$1 AND alliance_id=$2 ORDER BY joined_at_ms LIMIT 1")
            .bind(&engine.realm_id).bind(&ally).fetch_optional(&mut **tx).await.map_err(|e| AppError::Internal(e.to_string()))?;
        if let Some((n,)) = next {
            sqlx::query(
                "UPDATE alliances SET leader_id=$3::uuid WHERE realm_id=$1 AND alliance_id=$2",
            )
            .bind(&engine.realm_id)
            .bind(&ally)
            .bind(&n)
            .execute(&mut **tx)
            .await
            .map_err(|e| AppError::Internal(e.to_string()))?;
            sqlx::query("UPDATE alliance_members SET role='leader' WHERE realm_id=$1 AND alliance_id=$2 AND player_id=$3::uuid")
                .bind(&engine.realm_id).bind(&ally).bind(&n).execute(&mut **tx).await.map_err(|e| AppError::Internal(e.to_string()))?;
            sqlx::query("UPDATE players SET alliance_role='leader' WHERE realm_id=$1 AND player_id=$2::uuid")
                .bind(&engine.realm_id).bind(&n).execute(&mut **tx).await.map_err(|e| AppError::Internal(e.to_string()))?;
        } else {
            sqlx::query("DELETE FROM alliances WHERE realm_id=$1 AND alliance_id=$2")
                .bind(&engine.realm_id)
                .bind(&ally)
                .execute(&mut **tx)
                .await
                .map_err(|e| AppError::Internal(e.to_string()))?;
        }
    }
    Ok(())
}

/// Remove a member; restricted to officers and above.
pub async fn alliance_kick(
    engine: &Engine,
    tx: &mut Transaction<'_, Postgres>,
    player: &str,
    cmd: &kd_proto::AllianceKickCmd,
) -> AppResult<()> {
    let ally = require_role(tx, &engine.realm_id, player, &["leader", "officer"]).await?;
    if cmd.player_id == player {
        return Err(AppError::Invalid("cannot kick self".into()));
    }
    let role: Option<(String,)> = sqlx::query_as("SELECT role FROM alliance_members WHERE realm_id=$1 AND alliance_id=$2 AND player_id=$3::uuid")
        .bind(&engine.realm_id).bind(&ally).bind(&cmd.player_id).fetch_optional(&mut **tx).await.map_err(|e| AppError::Internal(e.to_string()))?;
    match role {
        None => return Err(AppError::NotFound("not a member".into())),
        Some((r,)) if r == "leader" => {
            return Err(AppError::Forbidden("cannot kick leader".into()))
        }
        _ => {}
    }
    sqlx::query(
        "DELETE FROM alliance_members WHERE realm_id=$1 AND alliance_id=$2 AND player_id=$3::uuid",
    )
    .bind(&engine.realm_id)
    .bind(&ally)
    .bind(&cmd.player_id)
    .execute(&mut **tx)
    .await
    .map_err(|e| AppError::Internal(e.to_string()))?;
    sqlx::query("UPDATE players SET alliance_id=NULL,alliance_role=NULL WHERE realm_id=$1 AND player_id=$2::uuid")
        .bind(&engine.realm_id).bind(&cmd.player_id).execute(&mut **tx).await.map_err(|e| AppError::Internal(e.to_string()))?;
    Ok(())
}

/// Spend help credit to accelerate a member's active timer.
pub async fn alliance_help(
    engine: &Engine,
    tx: &mut Transaction<'_, Postgres>,
    player: &str,
    cmd: &kd_proto::AllianceHelpCmd,
) -> AppResult<()> {
    let ally = require_role(
        tx,
        &engine.realm_id,
        player,
        &["leader", "officer", "member"],
    )
    .await?;
    let target_ally: Option<(String,)> =
        sqlx::query_as("SELECT alliance_id FROM players WHERE realm_id=$1 AND player_id=$2::uuid")
            .bind(&engine.realm_id)
            .bind(&cmd.target_player_id)
            .fetch_optional(&mut **tx)
            .await
            .map_err(|e| AppError::Internal(e.to_string()))?;
    if target_ally.map(|x| x.0) != Some(ally) {
        return Err(AppError::Forbidden("target not an ally".into()));
    }
    if cmd.target_player_id == player {
        return Err(AppError::Invalid("cannot help self".into()));
    }
    // Locate the helper's active queue event and reduce its due time once per helper.
    let ev: Option<(String, i64, Value)> = sqlx::query_as("SELECT e.id::text,e.due_at_ms,e.payload FROM scheduled_events e LEFT JOIN cities c ON c.realm_id=e.realm_id AND c.city_id=e.payload->>'city_id' WHERE e.realm_id=$1 AND e.status='pending' AND e.kind IN ('build_complete','train_complete','heal_complete','research_complete') AND (e.payload->>'player_id'=$2 OR c.player_id=$2::uuid) ORDER BY e.due_at_ms LIMIT 1")
        .bind(&engine.realm_id).bind(&cmd.target_player_id).fetch_optional(&mut **tx).await.map_err(|e| AppError::Internal(e.to_string()))?;
    let (id, due, payload) = ev.ok_or_else(|| AppError::NotFound("task not found".into()))?;
    let task_id = format!("{}:{}", id, player);
    let helped: Option<(i64,)> =
        sqlx::query_as("SELECT reduced_ms FROM help_tasks WHERE realm_id=$1 AND id=$2")
            .bind(&engine.realm_id)
            .bind(&task_id)
            .fetch_optional(&mut **tx)
            .await
            .map_err(|e| AppError::Internal(e.to_string()))?;
    if helped.is_some() {
        return Err(AppError::Conflict("already helped this task".into()));
    }
    let now = engine
        .now_ms(tx)
        .await
        .map_err(|e| AppError::Internal(e.to_string()))?;
    let reduction = ((due - now) / 10).clamp(1000, 300_000);
    let new_due = (due - reduction).max(now);
    sqlx::query("UPDATE scheduled_events SET due_at_ms=$2 WHERE realm_id=$1 AND id=$3::uuid")
        .bind(&engine.realm_id)
        .bind(new_due)
        .bind(&id)
        .execute(&mut **tx)
        .await
        .map_err(|e| AppError::Internal(e.to_string()))?;
    if let Some(city_id) = payload.get("city_id").and_then(Value::as_str) {
        sqlx::query("UPDATE cities SET busy_until_ms=$3 WHERE realm_id=$1 AND city_id=$2")
            .bind(&engine.realm_id)
            .bind(city_id)
            .bind(new_due)
            .execute(&mut **tx)
            .await
            .map_err(|e| AppError::Internal(e.to_string()))?;
    }
    let helpers = vec![player.to_string()];
    sqlx::query("INSERT INTO help_tasks(realm_id,id,player_id,kind,reduced_ms,helpers,created_at_ms) VALUES ($1,$2,$3::uuid,'queue',$4,$5,$6)")
        .bind(&engine.realm_id).bind(&task_id).bind(&cmd.target_player_id).bind(reduction).bind(serde_json::to_value(helpers)?).bind(now)
        .execute(&mut **tx).await.map_err(|e| AppError::Internal(e.to_string()))?;
    Ok(())
}
