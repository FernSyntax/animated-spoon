//! HTTP handlers for authentication, realm routing and bootstrap.
//!
//! Handlers validate the session, resolve the shard from the control plane and
//! delegate all gameplay reads to the authoritative realm worker.
use crate::app::{bearer, err, validate_token, worker_client, ApiError, App};
use axum::extract::{Path, Query, State, WebSocketUpgrade};
use axum::http::{HeaderMap, StatusCode};
use axum::response::{IntoResponse, Response};
use axum::Json;
use kd_proto::*;
use serde::Deserialize;
use tonic::metadata::MetadataValue;

pub async fn metrics_handler(State(app): State<App>) -> impl IntoResponse {
    match &app.prom {
        Some(h) => (StatusCode::OK, h.render()),
        None => (StatusCode::OK, String::new()),
    }
}

#[derive(Deserialize)]
pub(crate) struct RegisterBody {
    username: String,
    password: String,
    display_name: Option<String>,
}
#[derive(Deserialize)]
pub(crate) struct LoginBody {
    username: String,
    password: String,
}
pub async fn register(
    State(app): State<App>,
    Json(body): Json<RegisterBody>,
) -> Result<Json<serde_json::Value>, ApiError> {
    let mut cp = app.cp.clone();
    let resp = cp
        .register(RegisterRequest {
            username: body.username,
            password: body.password,
            display_name: body.display_name.unwrap_or_default(),
        })
        .await
        .map_err(|e| err(e.message().to_string()))?
        .into_inner();
    Ok(Json(serde_json::json!({"account_id": resp.account_id})))
}
pub async fn login(
    State(app): State<App>,
    Json(body): Json<LoginBody>,
) -> Result<Json<serde_json::Value>, ApiError> {
    let mut cp = app.cp.clone();
    let resp = cp
        .login(LoginRequest {
            username: body.username,
            password: body.password,
        })
        .await
        .map_err(|e| err(e.message().to_string()))?
        .into_inner();
    Ok(Json(
        serde_json::json!({"token": resp.token, "expires_at_unix": resp.expires_at_unix, "account_id": resp.account_id}),
    ))
}
pub async fn logout(
    State(app): State<App>,
    Json(body): Json<serde_json::Value>,
) -> Result<Json<serde_json::Value>, ApiError> {
    let token = body.get("token").and_then(|v| v.as_str()).unwrap_or("");
    let mut cp = app.cp.clone();
    cp.logout(LogoutRequest {
        token: token.into(),
    })
    .await
    .map_err(|e| err(e.message().to_string()))?;
    Ok(Json(serde_json::json!({"ok":true})))
}
pub async fn validate(
    State(app): State<App>,
    Json(body): Json<serde_json::Value>,
) -> Result<Json<serde_json::Value>, ApiError> {
    let token = body.get("token").and_then(|v| v.as_str()).unwrap_or("");
    let r = validate_token(&app, token).await?;
    Ok(Json(serde_json::json!({
        "account_id": r.account_id, "username": r.username,
        "memberships": r.memberships.iter().map(|m| serde_json::json!({"realm_id":m.realm_id,"player_id":m.player_id})).collect::<Vec<_>>()
    })))
}
pub async fn realms(State(app): State<App>) -> Result<Json<serde_json::Value>, ApiError> {
    let mut cp = app.cp.clone();
    let r = cp
        .list_realms(Empty {})
        .await
        .map_err(|e| err(e.message().to_string()))?
        .into_inner();
    Ok(Json(
        serde_json::json!({"realms": r.realms.iter().map(|x| serde_json::json!({
        "realm_id":x.realm_id,"name":x.name,"status":x.status,"players":x.players,"shard":x.shard
    })).collect::<Vec<_>>()}),
    ))
}

pub async fn join_realm(
    State(app): State<App>,
    headers: HeaderMap,
    Path(realm_id): Path<String>,
) -> Result<Json<serde_json::Value>, ApiError> {
    let token = bearer(&headers)?;
    let v = validate_token(&app, &token).await?;
    let mut req = tonic::Request::new(JoinRealmRequest { realm_id });
    req.metadata_mut().insert(
        "x-kd-account",
        MetadataValue::try_from(v.account_id.as_str()).map_err(|_| err("bad account"))?,
    );
    let mut cp = app.cp.clone();
    let r = cp
        .join_realm(req)
        .await
        .map_err(|e| err(e.message().to_string()))?
        .into_inner();
    Ok(Json(
        serde_json::json!({"player_id":r.player_id,"created_city":r.created_city}),
    ))
}

#[derive(Deserialize)]
pub(crate) struct BootstrapBody {
    pub(crate) token: String,
    realm_id: String,
    #[serde(default)]
    chunks: Vec<[i32; 2]>,
}
pub async fn bootstrap(
    State(app): State<App>,
    Json(body): Json<BootstrapBody>,
) -> Result<Json<serde_json::Value>, ApiError> {
    let v = validate_token(&app, &body.token).await?;
    let membership = v
        .memberships
        .iter()
        .find(|m| m.realm_id == body.realm_id)
        .ok_or_else(|| err("not a member of this realm; join first"))?;
    let mut cp = app.cp.clone();
    let route = cp
        .get_realm_route(GetRealmRouteRequest {
            realm_id: body.realm_id.clone(),
        })
        .await
        .map_err(|e| err(e.message().to_string()))?
        .into_inner();
    let mut worker = worker_client(&app, &route.shard).await?;
    let _ = worker
        .ensure_player(EnsurePlayerRequest {
            realm_id: body.realm_id.clone(),
            account_id: v.account_id.clone(),
            player_id: membership.player_id.clone(),
            name: v.username.clone(),
        })
        .await
        .map_err(|e| err(e.message().to_string()))?;
    let chunks: Vec<Vec2> = if body.chunks.is_empty() {
        vec![Vec2 { x: 0, y: 0 }]
    } else {
        body.chunks
            .iter()
            .map(|c| Vec2 { x: c[0], y: c[1] })
            .collect()
    };
    let snap = worker
        .get_snapshot(SnapshotRequest {
            realm_id: body.realm_id.clone(),
            principal_player_id: membership.player_id.clone(),
            chunks,
        })
        .await
        .map_err(|e| err(e.message().to_string()))?
        .into_inner();
    let state: serde_json::Value =
        serde_json::from_slice(&snap.state_json).unwrap_or(serde_json::Value::Null);
    let map: serde_json::Value =
        serde_json::from_slice(&snap.map_json).unwrap_or(serde_json::Value::Null);
    Ok(Json(serde_json::json!({
        "token": body.token, "realm_id": snap.realm_id, "player_id": membership.player_id,
        "state": state, "map": map, "cursor": snap.cursor, "server_time_unix_ms": snap.server_time_unix_ms
    })))
}

#[derive(Deserialize)]
pub(crate) struct ClockBody {
    token: String,
    realm_id: String,
    delta_micros: i64,
}
pub async fn advance_clock(
    State(app): State<App>,
    Json(body): Json<ClockBody>,
) -> Result<Json<serde_json::Value>, ApiError> {
    if !app.cfg.dev_mode {
        return Err(err("clock control disabled"));
    }
    validate_token(&app, &body.token).await?;
    let mut cp = app.cp.clone();
    let route = cp
        .get_realm_route(GetRealmRouteRequest {
            realm_id: body.realm_id.clone(),
        })
        .await
        .map_err(|e| err(e.message().to_string()))?
        .into_inner();
    let mut worker = worker_client(&app, &route.shard).await?;
    let r = worker
        .advance_clock(AdvanceClockRequest {
            realm_id: body.realm_id,
            delta_micros: body.delta_micros,
        })
        .await
        .map_err(|e| err(e.message().to_string()))?
        .into_inner();
    Ok(Json(serde_json::json!({"clock_now_ms":r.clock_now_ms})))
}
#[derive(Deserialize)]
pub struct WsQuery {
    pub(crate) token: String,
    pub(crate) realm: String,
    #[serde(default)]
    pub(crate) chunks: Option<String>,
}
pub async fn ws_handler(
    State(app): State<App>,
    Query(q): Query<WsQuery>,
    ws: WebSocketUpgrade,
) -> Response {
    ws.on_upgrade(move |socket| crate::session::run(app, socket, q))
}
