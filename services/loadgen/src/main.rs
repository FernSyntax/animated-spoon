//! Real headless load generator: uses production HTTP auth/bootstrap and
//! protobuf-over-WebSocket commands. No bypass of authoritative checks.
mod client;

use clap::Parser;
use client::{find_city_id, next_command, setup_account, Args, Stats};
use futures::{SinkExt, StreamExt};
use kd_proto::*;
use prost::Message as _;
use rand::rngs::StdRng;
use rand::Rng;
use rand::SeedableRng;
use serde_json::{json, Value};
use std::time::{Duration, Instant};
use tokio_tungstenite::{connect_async, tungstenite::Message};

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    tracing_subscriber::fmt::init();
    let args = Args::parse();
    let http = reqwest::Client::new();
    let base = args.gateway.trim_end_matches('/').to_string();
    let prefix = args
        .prefix
        .clone()
        .unwrap_or_else(|| format!("load{}", args.seed % 100000));
    let duration = args.duration;
    let a_per_s = args.actions_per_sec;
    let stats = std::sync::Arc::new(tokio::sync::Mutex::new(Stats::default()));
    let setup_gate = std::sync::Arc::new(tokio::sync::Semaphore::new(8));
    let mut handles = Vec::new();

    for i in 0..args.clients {
        let http = http.clone();
        let base = base.clone();
        let realm = args.realm.clone();
        let scenario = args.scenario.clone();
        let stats = stats.clone();
        let setup_gate = setup_gate.clone();
        let seed = args.seed;
        let username = format!("{}_{}_{}", prefix, i, seed % 10000);
        handles.push(tokio::spawn(async move {
            let _permit = setup_gate.acquire().await.unwrap();
            let token = match setup_account(&http, &base, &realm, &username).await {
                Ok(t) => t,
                Err(e) => {
                    stats.lock().await.errors += 1;
                    tracing::warn!(%username, error=%e, "setup failed");
                    return;
                }
            };
            drop(_permit);
            let ws_url = format!(
                "{}/ws?token={}&realm={}&chunks=0%2C0%3B1%2C0%3B0%2C1%3B1%2C1",
                base.replacen("http", "ws", 1),
                // JWTs use base64url + '.', all safe in a query component.
                token,
                realm
            );
            let (mut ws, _) = match connect_async(&ws_url).await {
                Ok(c) => c,
                Err(e) => {
                    stats.lock().await.errors += 1;
                    tracing::warn!(error=%e, "ws connect failed");
                    return;
                }
            };
            let mut rng = StdRng::seed_from_u64(seed + i as u64);
            let deadline = Instant::now() + Duration::from_secs(duration);
            let mut seq = 0u64;
            let mut city_id: Option<String> = None;
            while Instant::now() < deadline {
                let (req, label) = next_command(
                    &mut rng,
                    i,
                    &scenario,
                    seq,
                    &realm,
                    city_id.as_deref(),
                    seed,
                );
                seq += 1;
                let env = WsEnvelope {
                    seq,
                    body: Some(ws_envelope::Body::Command(req)),
                };
                let mut buf = Vec::new();
                let _ = env.encode(&mut buf);
                let start = Instant::now();
                if ws.send(Message::Binary(buf.into())).await.is_err() {
                    stats.lock().await.errors += 1;
                    if let Ok((w, _)) = connect_async(&ws_url).await {
                        ws = w;
                        stats.lock().await.reconnects += 1;
                    }
                    continue;
                }
                let mut got = false;
                for _ in 0..10 {
                    match tokio::time::timeout(Duration::from_secs(5), ws.next()).await {
                        Ok(Some(Ok(Message::Binary(d)))) => {
                            if let Ok(e) = WsEnvelope::decode(&d[..]) {
                                if let Some(ws_envelope::Body::CommandResult(r)) = e.body {
                                    let mut s = stats.lock().await;
                                    s.latencies.push(start.elapsed().as_secs_f64() * 1000.0);
                                    let code = ErrorCode::try_from(r.code)
                                        .map(|c| format!("{c:?}"))
                                        .unwrap_or_else(|_| r.code.to_string());
                                    if r.code == ErrorCode::Ok as i32 {
                                        s.accepted += 1;
                                        if label == "create_city" {
                                            if let Ok(v) =
                                                serde_json::from_slice::<Value>(&r.state_json)
                                            {
                                                if let Some(c) = find_city_id(&v) {
                                                    city_id = Some(c);
                                                } else {
                                                    eprintln!(
                                                        "DEBUG state keys: {:?}",
                                                        v.as_object()
                                                            .map(|o| o.keys().collect::<Vec<_>>())
                                                    );
                                                }
                                            }
                                        }
                                    } else {
                                        s.rejected += 1;
                                        *s.reject_codes.entry(code.clone()).or_default() += 1;
                                        if s.samples.len() < 12 {
                                            s.samples.push(format!("{code}: {}", r.message));
                                        }
                                    }
                                    got = true;
                                }
                            }
                        }
                        Ok(Some(Ok(Message::Ping(p)))) => {
                            let _ = ws.send(Message::Pong(p)).await;
                        }
                        Ok(Some(Err(_))) | Ok(None) | Err(_) => break,
                        _ => {}
                    }
                    if got {
                        break;
                    }
                }
                if !got {
                    stats.lock().await.errors += 1;
                }
                let jitter = rng.gen_range(0..200);
                tokio::time::sleep(Duration::from_millis(1000 / a_per_s.max(1) + jitter)).await;
            }
            let _ = ws.close(None).await;
        }));
    }
    for h in handles {
        let _ = h.await;
    }

    let s = stats.lock().await;
    let mut l = s.latencies.clone();
    l.sort_by(|a, b| a.total_cmp(b));
    let pct = |p: f64| -> f64 {
        if l.is_empty() {
            0.0
        } else {
            l[((l.len() as f64 - 1.0) * p).round() as usize]
        }
    };
    let report = json!({
        "scenario": args.scenario, "clients": args.clients, "duration_secs": args.duration,
        "seed": args.seed, "accepted": s.accepted, "rejected": s.rejected,
        "errors": s.errors, "reconnects": s.reconnects,
        "latency_ms": {"p50": pct(0.5), "p95": pct(0.95), "p99": pct(0.99)},
        "reject_codes": s.reject_codes,
        "samples": s.samples,
    });
    println!("{}", serde_json::to_string_pretty(&report)?);
    Ok(())
}
