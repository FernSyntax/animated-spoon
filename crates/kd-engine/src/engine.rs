//! Core mutation engine. Owns the fenced database transaction boundary for a realm.
use kd_common::AppError;
use serde_json::{json, Value};
use sqlx::{PgPool, Postgres, Transaction};
use std::sync::atomic::{AtomicBool, AtomicI64, Ordering};

use kd_proto::CommandResult;

#[derive(Clone, Debug, Default)]
/// Where an event is published and who is allowed to see it.
pub struct EventRouting {
    pub pos: Option<(i32, i32)>,
    pub aggregate_id: String,
    pub owner_player_id: Option<String>,
    pub private: bool,
    pub visible_players: Vec<String>,
}

/// Fenced mutation engine for one realm; owns the ownership epoch checks.
pub struct Engine {
    pub realm_id: String,
    pub shard: String,
    pub pool: PgPool,
    pub worker_id: String,
    pub seed: u64,
    pub dev_mode: bool,
    pub lease_secs: i64,
    pub scheduler_batch: i64,
    pub epoch: AtomicI64,
    pub lost: AtomicBool,
}

impl Engine {
    pub fn new(
        realm_id: String,
        shard: String,
        pool: PgPool,
        worker_id: String,
        seed: u64,
        dev_mode: bool,
        lease_secs: i64,
        scheduler_batch: usize,
    ) -> Self {
        Self {
            realm_id,
            shard,
            pool,
            worker_id,
            seed,
            dev_mode,
            lease_secs,
            scheduler_batch: scheduler_batch as i64,
            epoch: AtomicI64::new(0),
            lost: AtomicBool::new(false),
        }
    }

    /// Idempotent deterministic realm seeding. Safe to re-run on every worker start.
    pub async fn provision(pool: &PgPool, realm_id: &str, seed: u64) -> anyhow::Result<()> {
        let mut tx = pool.begin().await?;
        sqlx::query("INSERT INTO realm_clock(realm_id) VALUES ($1) ON CONFLICT DO NOTHING")
            .bind(realm_id)
            .execute(&mut *tx)
            .await?;
        let season_end = chrono::Utc::now().timestamp_millis() + 30 * 24 * 3600 * 1000;
        sqlx::query(
            "INSERT INTO realm_state(realm_id, seed, season_ends_at_ms, content_version)
             VALUES ($1,$2,$3,$4) ON CONFLICT DO NOTHING",
        )
        .bind(realm_id)
        .bind(seed as i64)
        .bind(season_end)
        .bind(kd_domain::content::CONTENT_VERSION as i32)
        .execute(&mut *tx)
        .await?;
        sqlx::query(
            "INSERT INTO realm_ownership(realm_id, epoch, owner_id, lease_until_ms, updated_at_ms)
             VALUES ($1,0,'',0,0) ON CONFLICT DO NOTHING",
        )
        .bind(realm_id)
        .execute(&mut *tx)
        .await?;
        tx.commit().await?;
        Ok(())
    }

    /// Acquire or renew exclusive mutation ownership. Takeover increments the
    /// fencing epoch; stale owners are rejected by assert_ownership().
    pub async fn acquire(&self) -> anyhow::Result<i64> {
        let mut tx = self.pool.begin().await?;
        let row: Option<(i64, String, i64)> = sqlx::query_as(
            "SELECT epoch, owner_id, lease_until_ms FROM realm_ownership WHERE realm_id=$1 FOR UPDATE",
        ).bind(&self.realm_id).fetch_optional(&mut *tx).await?;
        let now: (i64,) = sqlx::query_as("SELECT wall_now_ms()")
            .fetch_one(&mut *tx)
            .await?;
        let now = now.0;
        let new_epoch = match row {
            None => anyhow::bail!("realm not provisioned"),
            Some((epoch, owner, _lease_until)) if owner == self.worker_id => {
                sqlx::query("UPDATE realm_ownership SET lease_until_ms=$2, updated_at_ms=$3 WHERE realm_id=$1")
                    .bind(&self.realm_id).bind(now + self.lease_secs * 1000).bind(now)
                    .execute(&mut *tx).await?;
                epoch
            }
            Some((epoch, _, lease_until)) if lease_until < now => {
                let next = epoch + 1;
                sqlx::query("UPDATE realm_ownership SET epoch=$2, owner_id=$3, lease_until_ms=$4, updated_at_ms=$5 WHERE realm_id=$1")
                    .bind(&self.realm_id).bind(next).bind(&self.worker_id)
                    .bind(now + self.lease_secs * 1000).bind(now)
                    .execute(&mut *tx).await?;
                next
            }
            Some(_) => {
                tx.rollback().await.ok();
                return Err(AppError::NotOwner.into());
            }
        };
        tx.commit().await?;
        self.epoch.store(new_epoch, Ordering::SeqCst);
        self.lost.store(false, Ordering::SeqCst);
        Ok(new_epoch)
    }

    pub async fn renew(&self) -> anyhow::Result<bool> {
        let mut tx = self.pool.begin().await?;
        let row: Option<(i64, String, i64)> = sqlx::query_as(
            "SELECT epoch, owner_id, lease_until_ms FROM realm_ownership WHERE realm_id=$1 FOR UPDATE",
        ).bind(&self.realm_id).fetch_optional(&mut *tx).await?;
        let now: (i64,) = sqlx::query_as("SELECT wall_now_ms()")
            .fetch_one(&mut *tx)
            .await?;
        let mine = self.epoch.load(Ordering::SeqCst);
        let ok = matches!(row, Some((e, ref o, lease)) if e == mine && o == &self.worker_id && lease >= now.0);
        if ok {
            sqlx::query(
                "UPDATE realm_ownership SET lease_until_ms=$2, updated_at_ms=$3 WHERE realm_id=$1",
            )
            .bind(&self.realm_id)
            .bind(now.0 + self.lease_secs * 1000)
            .bind(now.0)
            .execute(&mut *tx)
            .await?;
        }
        tx.commit().await?;
        if !ok {
            self.lost.store(true, Ordering::SeqCst);
        }
        Ok(ok)
    }

    /// Begin a fenced transaction. The ownership row lock serializes mutations
    /// within a realm (never across realms), and the epoch check rejects stale owners.
    pub async fn tx(&self) -> anyhow::Result<Transaction<'static, Postgres>> {
        let mut tx = self.pool.begin().await?;
        sqlx::query("SELECT assert_ownership($1,$2,$3)")
            .bind(&self.realm_id)
            .bind(&self.worker_id)
            .bind(self.epoch.load(Ordering::SeqCst))
            .execute(&mut *tx)
            .await?;
        Ok(tx)
    }

    pub async fn now_ms(&self, tx: &mut Transaction<'_, Postgres>) -> anyhow::Result<i64> {
        let r: (i64,) = sqlx::query_as("SELECT clock_now_ms($1)")
            .bind(&self.realm_id)
            .fetch_one(&mut **tx)
            .await?;
        Ok(r.0)
    }

    /// Dev/test-only virtual clock advance. Rejected outside dev mode.
    pub async fn advance_clock(&self, delta_micros: i64) -> anyhow::Result<i64> {
        if !self.dev_mode {
            return Err(AppError::Forbidden("clock control disabled".into()).into());
        }
        let mut tx = self.tx().await?;
        sqlx::query("UPDATE realm_clock SET offset_micros = offset_micros + $2 WHERE realm_id=$1")
            .bind(&self.realm_id)
            .bind(delta_micros)
            .execute(&mut *tx)
            .await?;
        let now = self.now_ms(&mut tx).await?;
        tx.commit().await?;
        Ok(now)
    }

    pub async fn outbox(
        &self,
        tx: &mut Transaction<'_, Postgres>,
        event_type: &str,
        routing: EventRouting,
        payload: Value,
    ) -> anyhow::Result<()> {
        let id = uuid::Uuid::new_v4().to_string();
        let now = self.now_ms(tx).await?;
        sqlx::query(
            "INSERT INTO outbox(id,realm_id,event_type,aggregate_id,pos_x,pos_y,owner_player_id,is_private,visible_players,payload,created_at_ms)
             VALUES ($1::uuid,$2,$3,$4,$5,$6,$7::uuid,$8,$9,$10,$11)",
        )
        .bind(id).bind(&self.realm_id).bind(event_type).bind(routing.aggregate_id)
        .bind(routing.pos.map(|p| p.0)).bind(routing.pos.map(|p| p.1))
        .bind(routing.owner_player_id)
        .bind(routing.private)
        .bind(serde_json::to_value(routing.visible_players)?)
        .bind(payload).bind(now)
        .execute(&mut **tx).await?;
        Ok(())
    }

    pub async fn schedule(
        &self,
        tx: &mut Transaction<'_, Postgres>,
        due_at_ms: i64,
        priority: i32,
        kind: &str,
        payload: Value,
    ) -> anyhow::Result<String> {
        let id = uuid::Uuid::new_v4().to_string();
        let now = self.now_ms(tx).await?;
        sqlx::query(
            "INSERT INTO scheduled_events(id,realm_id,due_at_ms,priority,kind,payload,created_at_ms) VALUES ($1::uuid,$2,$3,$4,$5,$6,$7)",
        ).bind(&id).bind(&self.realm_id).bind(due_at_ms).bind(priority)
         .bind(kind).bind(payload).bind(now)
         .execute(&mut **tx).await?;
        Ok(id)
    }

    pub async fn report(
        &self,
        tx: &mut Transaction<'_, Postgres>,
        kind: &str,
        participants: Vec<String>,
        payload: Value,
    ) -> anyhow::Result<String> {
        let id = uuid::Uuid::new_v4().to_string();
        let now = self.now_ms(tx).await?;
        sqlx::query("INSERT INTO reports(id,realm_id,kind,participants,payload,created_at_ms) VALUES ($1::uuid,$2,$3,$4,$5,$6)")
            .bind(&id).bind(&self.realm_id).bind(kind)
            .bind(serde_json::to_value(participants)?).bind(payload).bind(now)
            .execute(&mut **tx).await?;
        Ok(id)
    }

    /// Stable hash of a command payload for deduplication.
    pub fn payload_hash(payload: &kd_proto::CommandPayload) -> String {
        use prost::Message;
        use sha2::{Digest, Sha256};
        let mut h = Sha256::new();
        // Debug formatting is not a canonical encoding; encode_to_vec is.
        h.update(payload.encode_to_vec());
        hex(h.finalize().to_vec())
    }

    /// Ensure a player row exists (lazy provisioning from a verified membership).
    pub async fn ensure_player(
        &self,
        account_id: &str,
        player_id: &str,
        name: &str,
    ) -> anyhow::Result<bool> {
        let mut tx = self.pool.begin().await?;
        let existing: Option<(String,)> = sqlx::query_as(
            "SELECT player_id::text FROM players WHERE realm_id=$1 AND player_id=$2::uuid",
        )
        .bind(&self.realm_id)
        .bind(player_id)
        .fetch_optional(&mut *tx)
        .await?;
        if existing.is_some() {
            tx.commit().await?;
            return Ok(false);
        }
        let now = self.now_ms(&mut tx).await?;
        sqlx::query("INSERT INTO players(realm_id,player_id,account_id,name,created_at_ms) VALUES ($1,$2::uuid,$3::uuid,$4,$5)")
            .bind(&self.realm_id).bind(player_id).bind(account_id).bind(name).bind(now)
            .execute(&mut *tx).await?;
        sqlx::query("INSERT INTO items(realm_id,player_id,item_key,qty) VALUES ($1,$2::uuid,'bundle_small',1),($1,$2::uuid,'speed_5m',2),($1,$2::uuid,'speed_1h',1)")
            .bind(&self.realm_id).bind(player_id).execute(&mut *tx).await?;
        sqlx::query(
            "INSERT INTO heroes(realm_id,player_id,hero_key,level) VALUES ($1,$2::uuid,'aurora',1)",
        )
        .bind(&self.realm_id)
        .bind(player_id)
        .execute(&mut *tx)
        .await?;
        tx.commit().await?;
        Ok(true)
    }

    /// Submit a command: deduplicate, dispatch atomically, return authoritative state.
    pub async fn submit(
        &self,
        principal_player_id: &str,
        command_id: &str,
        payload: &kd_proto::CommandPayload,
    ) -> CommandResult {
        let hash = Self::payload_hash(payload);
        let mut tx = match self.tx().await {
            Ok(t) => t,
            Err(_) => return error_result(command_id, AppError::NotOwner, self.now_wall()),
        };
        let now = match self.now_ms(&mut tx).await {
            Ok(n) => n,
            Err(e) => {
                return error_result(command_id, AppError::Internal(e.to_string()), 0);
            }
        };

        // Idempotency: insert a pending marker; racing duplicates serialize on the
        // ownership row lock, so exactly one executes.
        let inserted = sqlx::query(
            "INSERT INTO commands(realm_id,principal_id,command_id,payload_hash,status,created_at_ms,updated_at_ms)
             VALUES ($1,$2::uuid,$3,$4,'pending',$5,$5) ON CONFLICT DO NOTHING",
        ).bind(&self.realm_id).bind(principal_player_id).bind(command_id).bind(&hash).bind(now)
         .execute(&mut *tx).await;
        match inserted {
            Ok(r) if r.rows_affected() == 0 => {
                let row: Option<(String, String, Option<Value>)> = sqlx::query_as(
                    "SELECT payload_hash,status,result_json FROM commands WHERE realm_id=$1 AND principal_id=$2::uuid AND command_id=$3",
                ).bind(&self.realm_id).bind(principal_player_id).bind(command_id).fetch_optional(&mut *tx).await.unwrap_or(None);
                let _ = tx.rollback().await;
                match row {
                    Some((h, status, Some(result))) if h == hash && status == "done" => {
                        return CommandResult {
                            command_id: command_id.to_string(),
                            code: result.get("code_num").and_then(|v| v.as_i64()).unwrap_or(1)
                                as i32,
                            message: result
                                .get("message")
                                .and_then(|v| v.as_str())
                                .unwrap_or("")
                                .to_string(),
                            state_version: result
                                .get("state_version")
                                .and_then(|v| v.as_u64())
                                .unwrap_or(0),
                            server_time_unix_ms: result
                                .get("server_time_unix_ms")
                                .and_then(|v| v.as_i64())
                                .unwrap_or(0),
                            state_json: result
                                .get("state")
                                .map(|v| serde_json::to_vec(v).unwrap_or_default())
                                .unwrap_or_default(),
                        };
                    }
                    _ => {
                        return error_result(
                            command_id,
                            AppError::Conflict(
                                "command id already used, still pending, or previously rejected"
                                    .into(),
                            ),
                            0,
                        )
                    }
                }
            }
            Err(e) => {
                let _ = tx.rollback().await;
                return error_result(command_id, AppError::from(e), 0);
            }
            _ => {}
        }

        let outcome = crate::commands::dispatch(self, &mut tx, principal_player_id, payload).await;
        match outcome {
            Ok(()) => {
                let snap =
                    crate::snapshot::player_snapshot(self, &mut tx, principal_player_id).await;
                let state = match snap {
                    Ok(s) => {
                        let v = serde_json::to_value(&s).unwrap_or(json!({}));
                        json!({"ok":true,"code":"OK","code_num":1,"state_version":s.version,"state":v})
                    }
                    Err(e) => {
                        tracing::error!(realm=%self.realm_id, command_id, error=%e, "snapshot build failed");
                        let _ = tx.rollback().await;
                        return error_result(command_id, AppError::Internal(e.to_string()), now);
                    }
                };
                if let Err(e) = sqlx::query("UPDATE commands SET status='done',result_json=$4,updated_at_ms=$5 WHERE realm_id=$1 AND principal_id=$2::uuid AND command_id=$3")
                    .bind(&self.realm_id).bind(principal_player_id).bind(command_id).bind(&state).bind(now)
                    .execute(&mut *tx).await {
                    let _ = tx.rollback().await;
                    return error_result(command_id, AppError::Internal(e.to_string()), now);
                }
                if let Err(e) = tx.commit().await {
                    return error_result(command_id, AppError::Internal(e.to_string()), now);
                }
                let version = state
                    .get("state_version")
                    .and_then(|v| v.as_u64())
                    .unwrap_or(0);
                CommandResult {
                    command_id: command_id.to_string(),
                    code: kd_proto::ErrorCode::Ok as i32,
                    message: String::new(),
                    state_version: version,
                    server_time_unix_ms: now,
                    state_json: serde_json::to_vec(&state).unwrap_or_default(),
                }
            }
            Err(e) => {
                tracing::error!(realm=%self.realm_id, command_id, error=%e, "command rejected");
                let code_num = e.code() as i32;
                let rejection = json!({"ok":false,"code":format!("{:?}", e.code()),"code_num":code_num,"message":e.to_string()});
                // Roll back partially-applied work, then persist the rejection in
                // a fresh transaction. The pending marker lived in the rolled-back
                // transaction, so this must UPSERT rather than UPDATE: otherwise a
                // rejected command id would leave no durable audit/dedup record.
                let _ = tx.rollback().await;
                if let Ok(mut tx2) = self.tx().await {
                    let result = sqlx::query(
                        "INSERT INTO commands(realm_id,principal_id,command_id,payload_hash,status,result_json,created_at_ms,updated_at_ms)
                         VALUES ($1,$2::uuid,$3,$4,'rejected',$5,$6,$6)
                         ON CONFLICT (realm_id,principal_id,command_id)
                         DO UPDATE SET status='rejected',result_json=$5,updated_at_ms=$6",
                    )
                    .bind(&self.realm_id)
                    .bind(principal_player_id)
                    .bind(command_id)
                    .bind(&hash)
                    .bind(&rejection)
                    .bind(now)
                    .execute(&mut *tx2)
                    .await;
                    match result {
                        Ok(_) => {
                            if let Err(e) = tx2.commit().await {
                                tracing::warn!(realm=%self.realm_id, command_id, error=%e, "rejection commit failed");
                            }
                        }
                        Err(e) => {
                            tracing::warn!(realm=%self.realm_id, command_id, error=%e, "rejection persist failed");
                            let _ = tx2.rollback().await;
                        }
                    }
                }
                error_result(command_id, e, now)
            }
        }
    }

    fn now_wall(&self) -> i64 {
        chrono::Utc::now().timestamp_millis()
    }
}

fn error_result(command_id: &str, e: AppError, t: i64) -> CommandResult {
    CommandResult {
        command_id: command_id.to_string(),
        code: e.code() as i32,
        message: e.to_string(),
        state_version: 0,
        server_time_unix_ms: t,
        state_json: vec![],
    }
}

fn hex(bytes: Vec<u8>) -> String {
    bytes.iter().map(|b| format!("{b:02x}")).collect()
}

#[cfg(test)]
mod tests {
    use super::*;
    use kd_proto::command_payload::Action;
    use kd_proto::{CommandPayload, UpgradeBuildingCmd};

    #[test]
    fn payload_hash_is_canonical_and_sensitive_to_content() {
        let a = CommandPayload {
            action: Some(Action::UpgradeBuilding(UpgradeBuildingCmd {
                city_id: "city-1".into(),
                building: "farm".into(),
            })),
        };
        let b = CommandPayload {
            action: Some(Action::UpgradeBuilding(UpgradeBuildingCmd {
                city_id: "city-1".into(),
                building: "farm".into(),
            })),
        };
        let c = CommandPayload {
            action: Some(Action::UpgradeBuilding(UpgradeBuildingCmd {
                city_id: "city-2".into(),
                building: "farm".into(),
            })),
        };
        assert_eq!(Engine::payload_hash(&a), Engine::payload_hash(&b));
        assert_ne!(Engine::payload_hash(&a), Engine::payload_hash(&c));
        assert_eq!(Engine::payload_hash(&a).len(), 64);
    }
}
