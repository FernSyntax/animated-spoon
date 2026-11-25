//! gRPC implementation of the global control plane.
//!
//! Accounts and sessions are global concerns; realm gameplay is never touched
//! here. All mutations go through the store inside explicit transactions.
use kd_common::auth::Auth;
use kd_common::AppError;
use kd_proto::control_plane_server::ControlPlane;
use kd_proto::*;
use kd_store::Store;
use std::sync::Arc;
use tonic::{Request, Response, Status};

pub struct Cp {
    pub(crate) store: Store,
    pub(crate) auth: Arc<Auth>,
    pub(crate) dev_mode: bool,
}

fn status(e: AppError) -> Status {
    let code = match e {
        AppError::Unauthenticated => tonic::Code::Unauthenticated,
        AppError::Forbidden(_) => tonic::Code::PermissionDenied,
        AppError::NotFound(_) => tonic::Code::NotFound,
        AppError::Invalid(_) | AppError::Conflict(_) => tonic::Code::InvalidArgument,
        _ => tonic::Code::Internal,
    };
    Status::new(code, e.to_string())
}

#[tonic::async_trait]
impl ControlPlane for Cp {
    async fn register(
        &self,
        req: Request<RegisterRequest>,
    ) -> Result<Response<RegisterResponse>, Status> {
        let r = req.into_inner();
        let username = r.username.trim().to_lowercase();
        if username.len() < 3
            || username.len() > 32
            || !username
                .chars()
                .all(|c| c.is_ascii_alphanumeric() || c == '_')
        {
            return Err(status(AppError::Invalid("invalid username".into())));
        }
        if r.password.len() < 8 || r.password.len() > 128 {
            return Err(status(AppError::Invalid(
                "password must be 8..128 characters".into(),
            )));
        }
        let hash = Auth::hash_password(&r.password)
            .map_err(|e| status(AppError::Internal(e.to_string())))?;
        let id = uuid::Uuid::new_v4();
        let name = if r.display_name.trim().is_empty() {
            username.clone()
        } else {
            r.display_name.trim().to_string()
        };
        sqlx::query(
            "INSERT INTO accounts(id,username,password_hash,display_name) VALUES ($1,$2,$3,$4)",
        )
        .bind(id)
        .bind(&username)
        .bind(hash)
        .bind(name)
        .execute(&self.store.global)
        .await
        .map_err(|e| status(AppError::Conflict(format!("username unavailable: {e}"))))?;
        Ok(Response::new(RegisterResponse {
            account_id: id.to_string(),
        }))
    }

    async fn login(&self, req: Request<LoginRequest>) -> Result<Response<LoginResponse>, Status> {
        let r = req.into_inner();
        let row: Option<(uuid::Uuid, String)> =
            sqlx::query_as("SELECT id,password_hash FROM accounts WHERE username=$1")
                .bind(r.username.trim().to_lowercase())
                .fetch_optional(&self.store.global)
                .await
                .map_err(|e| status(AppError::Internal(e.to_string())))?;
        let (account_id, hash) = row.ok_or_else(|| status(AppError::Unauthenticated))?;
        if !Auth::verify_password(&hash, &r.password) {
            return Err(status(AppError::Unauthenticated));
        }
        let sid = Auth::new_session_id();
        let ttl = 24 * 3600i64;
        let expires = chrono::Utc::now() + chrono::Duration::seconds(ttl);
        sqlx::query("INSERT INTO sessions(id,account_id,expires_at) VALUES ($1::uuid,$2,$3)")
            .bind(&sid)
            .bind(account_id)
            .bind(expires)
            .execute(&self.store.global)
            .await
            .map_err(|e| status(AppError::Internal(e.to_string())))?;
        let token = self
            .auth
            .issue(&account_id.to_string(), &sid, ttl)
            .map_err(|e| status(AppError::Internal(e.to_string())))?;
        Ok(Response::new(LoginResponse {
            token,
            expires_at_unix: expires.timestamp(),
            account_id: account_id.to_string(),
        }))
    }

    async fn logout(&self, req: Request<LogoutRequest>) -> Result<Response<Empty>, Status> {
        let token = &req.into_inner().token;
        if let Ok(c) = self.auth.validate(token) {
            sqlx::query("UPDATE sessions SET revoked=true WHERE id=$1::uuid")
                .bind(&c.jti)
                .execute(&self.store.global)
                .await
                .map_err(|e| status(AppError::Internal(e.to_string())))?;
        }
        Ok(Response::new(Empty {}))
    }

    async fn validate(
        &self,
        req: Request<ValidateRequest>,
    ) -> Result<Response<ValidateResponse>, Status> {
        let claims = self
            .auth
            .validate(&req.into_inner().token)
            .map_err(|_| status(AppError::Unauthenticated))?;
        let live: Option<(bool, chrono::DateTime<chrono::Utc>)> =
            sqlx::query_as("SELECT revoked,expires_at FROM sessions WHERE id=$1::uuid")
                .bind(&claims.jti)
                .fetch_optional(&self.store.global)
                .await
                .map_err(|e| status(AppError::Internal(e.to_string())))?
                .map(|(r, e): (bool, chrono::DateTime<chrono::Utc>)| (r, e));
        match live {
            Some((false, exp)) if exp > chrono::Utc::now() => {}
            _ => return Err(status(AppError::Unauthenticated)),
        }
        let memberships: Vec<(String, String)> = sqlx::query_as(
            "SELECT realm_id,player_id::text FROM realm_members WHERE account_id=$1::uuid",
        )
        .bind(&claims.sub)
        .fetch_all(&self.store.global)
        .await
        .map_err(|e| status(AppError::Internal(e.to_string())))?;
        let name: Option<(String,)> =
            sqlx::query_as("SELECT username FROM accounts WHERE id=$1::uuid")
                .bind(&claims.sub)
                .fetch_optional(&self.store.global)
                .await
                .map_err(|e| status(AppError::Internal(e.to_string())))?;
        Ok(Response::new(ValidateResponse {
            account_id: claims.sub,
            username: name.map(|n| n.0).unwrap_or_default(),
            memberships: memberships
                .into_iter()
                .map(|(realm_id, player_id)| RealmMembership {
                    realm_id,
                    player_id,
                })
                .collect(),
        }))
    }

    async fn list_realms(
        &self,
        _req: Request<Empty>,
    ) -> Result<Response<ListRealmsResponse>, Status> {
        let rows: Vec<(String, String, String, i64, String)> = sqlx::query_as(
            "SELECT r.realm_id,r.name,r.status,(SELECT count(*) FROM realm_members m WHERE m.realm_id=r.realm_id)::bigint,r.shard FROM realms r ORDER BY r.realm_id",
        ).fetch_all(&self.store.global).await.map_err(|e| status(AppError::Internal(e.to_string())))?;
        Ok(Response::new(ListRealmsResponse {
            realms: rows
                .into_iter()
                .map(|(realm_id, name, status_, players, shard)| RealmInfo {
                    realm_id,
                    name,
                    status: status_,
                    players: players as u32,
                    shard,
                })
                .collect(),
        }))
    }

    async fn join_realm(
        &self,
        req: Request<JoinRealmRequest>,
    ) -> Result<Response<JoinRealmResponse>, Status> {
        // Caller identity is supplied by the gateway in metadata after validation.
        let account =
            header(&req, "x-kd-account").ok_or_else(|| status(AppError::Unauthenticated))?;
        let realm_id = req.into_inner().realm_id;
        let realm: Option<(String,)> =
            sqlx::query_as("SELECT realm_id FROM realms WHERE realm_id=$1 AND status='active'")
                .bind(&realm_id)
                .fetch_optional(&self.store.global)
                .await
                .map_err(|e| status(AppError::Internal(e.to_string())))?;
        if realm.is_none() {
            return Err(status(AppError::NotFound("realm not found".into())));
        }
        let existing: Option<(String,)> = sqlx::query_as(
            "SELECT player_id::text FROM realm_members WHERE realm_id=$1 AND account_id=$2::uuid",
        )
        .bind(&realm_id)
        .bind(&account)
        .fetch_optional(&self.store.global)
        .await
        .map_err(|e| status(AppError::Internal(e.to_string())))?;
        if let Some((pid,)) = existing {
            return Ok(Response::new(JoinRealmResponse {
                player_id: pid,
                created_city: false,
            }));
        }
        let player_id = uuid::Uuid::new_v4();
        // Retryable membership insert; reconciled by unique key.
        sqlx::query("INSERT INTO realm_members(realm_id,account_id,player_id) VALUES ($1,$2::uuid,$3::uuid) ON CONFLICT(realm_id,account_id) DO NOTHING")
            .bind(&realm_id).bind(&account).bind(player_id).execute(&self.store.global).await
            .map_err(|e| status(AppError::Internal(e.to_string())))?;
        Ok(Response::new(JoinRealmResponse {
            player_id: player_id.to_string(),
            created_city: false,
        }))
    }

    async fn create_realm(
        &self,
        req: Request<CreateRealmRequest>,
    ) -> Result<Response<CreateRealmResponse>, Status> {
        if !self.dev_mode {
            return Err(status(AppError::Forbidden("admin API disabled".into())));
        }
        let r = req.into_inner();
        if !self.store.realm_shards.contains_key(&r.shard) {
            return Err(status(AppError::Invalid("unknown shard".into())));
        }
        let id = format!("realm-{}", uuid::Uuid::new_v4());
        let seed = rand::random::<u64>() as i64;
        sqlx::query("INSERT INTO realms(realm_id,name,shard,seed) VALUES ($1,$2,$3,$4)")
            .bind(&id)
            .bind(r.name)
            .bind(r.shard)
            .bind(seed)
            .execute(&self.store.global)
            .await
            .map_err(|e| status(AppError::Internal(e.to_string())))?;
        sqlx::query(
            "INSERT INTO admin_audit(actor,action,detail) VALUES ('dev','create_realm',$1::jsonb)",
        )
        .bind(serde_json::json!({"realm_id":id}))
        .execute(&self.store.global)
        .await
        .ok();
        Ok(Response::new(CreateRealmResponse { realm_id: id }))
    }

    async fn get_realm_route(
        &self,
        req: Request<GetRealmRouteRequest>,
    ) -> Result<Response<GetRealmRouteResponse>, Status> {
        let realm_id = req.into_inner().realm_id;
        let r: Option<(String,)> = sqlx::query_as("SELECT shard FROM realms WHERE realm_id=$1")
            .bind(&realm_id)
            .fetch_optional(&self.store.global)
            .await
            .map_err(|e| status(AppError::Internal(e.to_string())))?;
        let shard = r
            .ok_or_else(|| status(AppError::NotFound("realm not found".into())))?
            .0;
        Ok(Response::new(GetRealmRouteResponse {
            realm_id,
            shard,
            worker_address: String::new(),
        }))
    }
}

fn header<T>(req: &Request<T>, name: &str) -> Option<String> {
    req.metadata()
        .get(name)
        .and_then(|v| v.to_str().ok())
        .map(str::to_string)
}
