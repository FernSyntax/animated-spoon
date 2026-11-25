//! Shared application state and transport helpers for the gateway.
//!
//! Keeping these in one place means handlers never construct clients or read
//! configuration directly; they go through [App] and the `connect_*` helpers.
use axum::http::{HeaderMap, StatusCode};
use axum::response::{IntoResponse, Response};
use axum::Json;
use kd_common::auth::Auth;
use kd_common::config::Settings;
use kd_proto::control_plane_client::ControlPlaneClient;
use kd_proto::realm_service_client::RealmServiceClient;
use kd_proto::*;
use serde::Serialize;
use std::sync::Arc;
use tonic::service::interceptor::InterceptedService;
use tonic::service::Interceptor;
use tonic::transport::Channel;

/// Attaches the shared internal credential to every outgoing gRPC call.
#[derive(Clone)]
pub struct InternalInterceptor(String);

impl Interceptor for InternalInterceptor {
    fn call(&mut self, mut req: tonic::Request<()>) -> Result<tonic::Request<()>, tonic::Status> {
        if let Ok(value) = self.0.parse() {
            req.metadata_mut().insert("x-kd-internal", value);
        }
        Ok(req)
    }
}

type CpClient = ControlPlaneClient<InterceptedService<Channel, InternalInterceptor>>;
pub type WorkerClient = RealmServiceClient<InterceptedService<Channel, InternalInterceptor>>;

#[derive(Clone)]
#[allow(dead_code)]
pub struct App {
    pub(crate) cfg: Arc<Settings>,
    pub(crate) auth: Arc<Auth>,
    pub(crate) cp: CpClient,
    pub(crate) store: kd_store::Store,
    pub(crate) nats: async_nats::Client,
    pub(crate) prom: Option<metrics_exporter_prometheus::PrometheusHandle>,
}

#[derive(Serialize)]
pub(crate) struct ApiError {
    pub(crate) error: String,
}
impl IntoResponse for ApiError {
    fn into_response(self) -> Response {
        (StatusCode::BAD_REQUEST, Json(self)).into_response()
    }
}
pub(crate) fn err(s: impl Into<String>) -> ApiError {
    ApiError { error: s.into() }
}
pub(crate) fn bearer(headers: &HeaderMap) -> Result<String, ApiError> {
    let auth = headers
        .get("authorization")
        .and_then(|v| v.to_str().ok())
        .unwrap_or("");
    let token = auth.strip_prefix("Bearer ").unwrap_or(auth);
    if token.is_empty() {
        return Err(err("missing bearer token"));
    }
    Ok(token.to_string())
}

pub(crate) async fn validate_token(app: &App, token: &str) -> Result<ValidateResponse, ApiError> {
    let mut cp = app.cp.clone();
    cp.validate(ValidateRequest {
        token: token.into(),
    })
    .await
    .map(|r| r.into_inner())
    .map_err(|_| err("unauthenticated"))
}
pub async fn worker_client(app: &App, shard: &str) -> Result<WorkerClient, ApiError> {
    let addr = app
        .cfg
        .worker_by_shard
        .get(shard)
        .or_else(|| app.cfg.worker_by_shard.get(&shard.replace('-', "_")))
        .cloned()
        .unwrap_or_else(|| app.cfg.worker_grpc.clone());
    for _ in 0..10 {
        match Channel::from_shared(addr.clone()) {
            Ok(endpoint) => match endpoint.connect().await {
                Ok(channel) => {
                    return Ok(RealmServiceClient::with_interceptor(
                        channel,
                        InternalInterceptor(app.cfg.internal_secret.clone()),
                    ))
                }
                Err(e) => tracing::warn!(error=%e, "realm worker not ready; retrying"),
            },
            Err(e) => tracing::warn!(error=%e, "invalid realm worker address"),
        }
        tokio::time::sleep(std::time::Duration::from_millis(200)).await;
    }
    Err(err(format!("realm worker unavailable at {addr}")))
}
pub async fn connect_control_plane(addr: &str, secret: &str) -> anyhow::Result<CpClient> {
    for _ in 0..40 {
        match Channel::from_shared(addr.to_string()) {
            Ok(endpoint) => match endpoint.connect().await {
                Ok(channel) => {
                    return Ok(ControlPlaneClient::with_interceptor(
                        channel,
                        InternalInterceptor(secret.to_string()),
                    ))
                }
                Err(e) => tracing::warn!(error=%e, "control-plane not ready; retrying"),
            },
            Err(e) => tracing::warn!(error=%e, "invalid control-plane address"),
        }
        tokio::time::sleep(std::time::Duration::from_millis(500)).await;
    }
    anyhow::bail!("control-plane unavailable at {addr}")
}

pub async fn connect_nats(addr: &str) -> anyhow::Result<async_nats::Client> {
    for _ in 0..40 {
        match async_nats::connect(addr.to_string()).await {
            Ok(c) => return Ok(c),
            Err(e) => {
                tracing::warn!(error=%e, "nats not ready; retrying");
                tokio::time::sleep(std::time::Duration::from_millis(500)).await;
            }
        }
    }
    anyhow::bail!("nats unavailable at {addr}")
}
