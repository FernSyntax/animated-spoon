//! Binary entry point for the payments service.
use payments::{api, config::Config, store::Store};
use std::net::SocketAddr;
use tokio::net::TcpListener;

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    let filter =
        tracing_subscriber::EnvFilter::try_from_default_env().unwrap_or_else(|_| "info".into());
    tracing_subscriber::fmt().with_env_filter(filter).init();

    let config = Config::from_env()?;
    let addr: SocketAddr = config.http_addr.parse()?;
    let dev = config.is_dev();
    let store = Store::from_env().await?;
    let state = api::AppState::new(config, store, reqwest::Client::new());
    let router = api::router(state);

    if dev {
        tracing::warn!("KD_STRIPE_SECRET_KEY is unset: using the DEV stub checkout provider; no real payments are possible");
    } else {
        tracing::info!("KD_STRIPE_SECRET_KEY is set: using live Stripe Checkout");
    }
    tracing::info!(%addr, "payments http listening");
    axum::serve(TcpListener::bind(addr).await?, router).await?;
    Ok(())
}
