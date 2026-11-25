//! Global control plane: accounts, sessions, realm directory and membership provisioning.
// tonic::Status is intentionally a rich error type; the interceptor
// closure must return it for gRPC semantics.
#![allow(clippy::result_large_err)]
mod seed;
mod service;

use kd_common::auth::Auth;
use kd_common::config::Settings;
use kd_proto::control_plane_server::ControlPlaneServer;
use kd_store::Store;
use seed::seed_realms;
use service::Cp;
use std::sync::Arc;
use tonic::transport::Server;
use tonic::Request;

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    kd_common::obs::init("control-plane");
    kd_common::obs::install_prometheus();
    let cfg = Settings::load()?;
    let store = Store::from_config(&cfg).await?;
    seed_realms(&store, &cfg).await?;
    let auth = Arc::new(Auth::new(cfg.jwt_secret.clone()));
    let addr: std::net::SocketAddr = cfg.grpc_addr.parse()?;
    let http_addr: std::net::SocketAddr = cfg.http_addr.parse()?;
    let cp = Cp {
        store: store.clone(),
        auth,
        dev_mode: cfg.dev_mode,
    };
    tokio::spawn(async move {
        let app = axum::Router::new()
            .route("/health", axum::routing::get(|| async { "ok" }))
            .route("/ready", axum::routing::get(|| async { "ok" }));
        axum::serve(tokio::net::TcpListener::bind(http_addr).await.unwrap(), app)
            .await
            .unwrap();
    });
    tracing::info!(%addr, "control-plane grpc listening");
    // Internal gRPC is authenticated with a shared secret. The gateway is the
    // only intended caller; never expose this port to untrusted networks.
    let internal = cfg.internal_secret.clone();
    Server::builder()
        .layer(tonic::service::InterceptorLayer::new(
            move |req: Request<()>| {
                let got = req
                    .metadata()
                    .get("x-kd-internal")
                    .and_then(|v| v.to_str().ok())
                    .unwrap_or("");
                if got == internal {
                    Ok(req)
                } else {
                    Err(tonic::Status::unauthenticated(
                        "invalid internal credential",
                    ))
                }
            },
        ))
        .add_service(ControlPlaneServer::new(cp))
        .serve(addr)
        .await?;
    Ok(())
}
