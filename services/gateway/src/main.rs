//! Stateless edge gateway: authentication, bootstrap, WS sessions, filtered
//! delta fanout. Never mutates gameplay tables; all writes go through realm RPC.
mod app;
mod http;
mod session;
use app::{connect_control_plane, connect_nats, App};
use axum::routing::{get, post};
use axum::Router;
use http::{
    advance_clock, bootstrap, join_realm, login, logout, metrics_handler, realms, register,
    validate, ws_handler,
};
use kd_common::auth::Auth;
use kd_common::config::Settings;
use std::sync::Arc;

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    kd_common::obs::init("gateway");
    let cfg = Settings::load()?;
    let store = kd_store::Store::from_config(&cfg).await?;
    let auth = Arc::new(Auth::new(cfg.jwt_secret.clone()));
    let cp = connect_control_plane(&cfg.control_plane_grpc, &cfg.internal_secret).await?;
    let nats = connect_nats(&cfg.nats_url).await?;
    let prom = kd_common::obs::install_prometheus();
    let app = App {
        cfg: Arc::new(cfg.clone()),
        auth,
        cp,
        store,
        nats,
        prom,
    };

    // Origin is explicit in production (Settings::load refuses "*" outside
    // dev mode); dev keeps permissive CORS so the local web client just works.
    let cors = tower_http::cors::CorsLayer::new()
        .allow_origin(cfg.cors_origin.parse::<axum::http::HeaderValue>()?)
        .allow_methods(tower_http::cors::Any)
        .allow_headers(tower_http::cors::Any);
    let router = Router::new()
        .route("/health", get(|| async { "ok" }))
        .route("/ready", get(|| async { "ok" }))
        .route("/metrics", get(metrics_handler))
        .route("/auth/register", post(register))
        .route("/auth/login", post(login))
        .route("/auth/logout", post(logout))
        .route("/auth/validate", post(validate))
        .route("/realms", get(realms))
        .route("/realms/{id}/join", post(join_realm))
        .route("/bootstrap", post(bootstrap))
        .route("/admin/clock/advance", post(advance_clock))
        .route("/ws", get(ws_handler))
        .layer(cors)
        .with_state(app);
    let addr: std::net::SocketAddr = cfg.http_addr.parse()?;
    tracing::info!(%addr, "gateway http/ws listening");
    axum::serve(tokio::net::TcpListener::bind(addr).await?, router).await?;
    Ok(())
}
