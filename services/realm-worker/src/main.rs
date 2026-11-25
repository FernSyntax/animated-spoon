//! Fenced realm worker: the single mutation owner per realm and host of the durable scheduler.
// tonic::Status is intentionally a rich error type; the interceptor
// closure must return it for gRPC semantics.
#![allow(clippy::result_large_err)]
mod service;

use kd_common::config::Settings;
use kd_engine::{scheduler, Engine};
use kd_proto::realm_service_server::RealmServiceServer;
use kd_store::Store;
use service::Worker;
use std::collections::HashMap;
use std::sync::Arc;
use std::time::Duration;
use tonic::transport::Server;
use tonic::Request;

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    kd_common::obs::init("realm-worker");
    kd_common::obs::install_prometheus();
    let cfg = Settings::load()?;
    let store = Store::from_config(&cfg).await?;
    let worker_id = cfg.worker_id.clone();
    let spec = std::env::var("KD_REALMS")
        .unwrap_or_else(|_| "realm-a:shard_a:12345,realm-b:shard_b:67890".into());
    let only: Vec<String> = std::env::var("KD_WORKER_REALMS")
        .unwrap_or_default()
        .split(',')
        .filter(|s| !s.is_empty())
        .map(str::to_string)
        .collect();

    let mut engines = HashMap::new();
    for entry in spec.split(',') {
        let p: Vec<&str> = entry.trim().split(':').collect();
        if p.len() < 2 {
            continue;
        }
        let (realm, shard, seed) = (
            p[0],
            p[1],
            p.get(2).and_then(|v| v.parse::<u64>().ok()).unwrap_or(1),
        );
        if !only.is_empty() && !only.iter().any(|r| r == realm) {
            continue;
        }
        let pool = store.realm(shard)?;
        Engine::provision(pool, realm, seed).await?;
        kd_engine::commands::seed_entities(pool, realm, seed, kd_domain::world::CHUNK_SIZE).await?;
        let engine = Arc::new(Engine::new(
            realm.into(),
            shard.into(),
            pool.clone(),
            worker_id.clone(),
            seed,
            cfg.dev_mode,
            cfg.lease_secs as i64,
            cfg.scheduler_batch,
        ));
        // Acquire ownership before serving; a standby retries until the lease frees.
        loop {
            match engine.acquire().await {
                Ok(epoch) => {
                    tracing::info!(realm, epoch, "ownership acquired");
                    break;
                }
                Err(e) => {
                    tracing::warn!(realm, error = %e, "waiting for realm ownership");
                    tokio::time::sleep(Duration::from_secs(1)).await;
                }
            }
        }
        let e = engine.clone();
        tokio::spawn(async move {
            let mut interval =
                tokio::time::interval(Duration::from_secs(((e.lease_secs / 3).max(2)) as u64));
            loop {
                interval.tick().await;
                if let Err(err) = e.renew().await {
                    tracing::error!(error=%err, "lease renewal failed");
                }
            }
        });
        let e = engine.clone();
        tokio::spawn(async move {
            let mut interval =
                tokio::time::interval(Duration::from_millis(cfg.scheduler_interval_ms));
            loop {
                interval.tick().await;
                match scheduler::tick(&e).await {
                    Ok(n) if n > 0 => {
                        metrics::counter!("kd_events_processed_total").increment(n as u64)
                    }
                    Err(err) => tracing::error!(error=%err, "scheduler tick failed"),
                    _ => {}
                }
                let _ = scheduler::backlog(&e).await.map(|(n, lag)| {
                    metrics::gauge!("kd_scheduler_backlog").set(n as f64);
                    metrics::gauge!("kd_scheduler_lag_ms").set(lag as f64);
                });
            }
        });
        engines.insert(realm.into(), engine);
    }
    if engines.is_empty() {
        anyhow::bail!("no realms assigned to this worker");
    }

    let ready = Arc::new(std::sync::atomic::AtomicBool::new(true));
    let addr = cfg.grpc_addr.parse()?;
    let worker = Worker {
        engines: Arc::new(engines),
        ready,
        worker_id,
    };
    tracing::info!(%addr, "realm-worker grpc listening");
    // Every gameplay mutation arrives over this port; require the shared
    // internal credential so a network peer cannot impersonate the gateway.
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
        .add_service(RealmServiceServer::new(worker))
        .serve(addr)
        .await?;
    Ok(())
}
