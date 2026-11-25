//! Binary WebSocket sessions: command submission and visibility-filtered delta fanout.
use crate::app::{validate_token, worker_client, App, WorkerClient};
use crate::http::WsQuery;
use axum::extract::ws::{Message, WebSocket};
use futures::{SinkExt, StreamExt};
use kd_proto::*;
use prost::Message as _;
use serde_json::Value;
use std::collections::HashSet;
use std::sync::{Arc, Mutex};
use std::time::Duration;
use tokio::sync::mpsc;

type WsSink = futures::stream::SplitSink<WebSocket, Message>;

fn parse_chunks(s: &Option<String>) -> HashSet<(i32, i32)> {
    let mut set = HashSet::new();
    if let Some(s) = s {
        for part in s.split(';') {
            let p: Vec<&str> = part.trim().split(',').collect();
            if p.len() == 2 {
                if let (Ok(x), Ok(y)) = (p[0].parse(), p[1].parse()) {
                    set.insert((x, y));
                }
            }
        }
    }
    if set.is_empty() {
        set.insert((0, 0));
    }
    set
}

pub async fn run(app: App, socket: WebSocket, q: WsQuery) {
    let v = match validate_token(&app, &q.token).await {
        Ok(v) => v,
        Err(e) => {
            tracing::warn!(error=%e.error, "ws auth failed");
            return;
        }
    };
    // Membership must be established explicitly through the HTTP join endpoint,
    // exactly as `bootstrap` requires. Never auto-join from a socket upgrade:
    // the two entry points must enforce the same authorization rule.
    let membership = match v.memberships.iter().find(|m| m.realm_id == q.realm) {
        Some(m) => m.clone(),
        None => {
            tracing::warn!(realm=%q.realm, "ws rejected: not a member of realm");
            return;
        }
    };
    let player_id = membership.player_id.clone();
    let mut cp = app.cp.clone();
    let route = match cp
        .get_realm_route(GetRealmRouteRequest {
            realm_id: q.realm.clone(),
        })
        .await
    {
        Ok(r) => r.into_inner(),
        Err(e) => {
            tracing::warn!(error=%e.message(), "route failed");
            return;
        }
    };
    let mut worker = match worker_client(&app, &route.shard).await {
        Ok(w) => w,
        Err(e) => {
            tracing::warn!(error=%e.error, "no worker");
            return;
        }
    };
    match worker
        .ensure_player(EnsurePlayerRequest {
            realm_id: q.realm.clone(),
            account_id: v.account_id.clone(),
            player_id: player_id.clone(),
            name: v.username.clone(),
        })
        .await
    {
        Ok(_) => {}
        Err(e) => {
            tracing::warn!(error=%e.message(), player=%player_id, "ensure player failed");
            return;
        }
    }

    let (mut sink, mut source) = socket.split();
    let chunks = Arc::new(Mutex::new(parse_chunks(&q.chunks)));
    let (tx, mut rx) = mpsc::channel::<WsEnvelope>(256);
    let cursor = Arc::new(Mutex::new(String::new()));

    send_snapshot(
        &mut worker,
        &app,
        &q.realm,
        &player_id,
        &chunks,
        &cursor,
        &mut sink,
        &tx,
    )
    .await;

    // NATS -> filtered delta relay. Broker outage only affects live updates;
    // reconnect always resends an authoritative snapshot.
    let mut sub = match app.nats.subscribe(format!("kd.events.{}.*", q.realm)).await {
        Ok(s) => s,
        Err(e) => {
            tracing::warn!(error=%e, "nats subscribe failed");
            return;
        }
    };
    let relay_chunks = chunks.clone();
    let relay_cursor = cursor.clone();
    let relay_player = player_id.clone();
    let relay_realm = q.realm.clone();
    let relay_tx = tx.clone();
    let relay = tokio::spawn(async move {
        while let Some(msg) = sub.next().await {
            let body: Value = match serde_json::from_slice(&msg.payload) {
                Ok(v) => v,
                Err(_) => continue,
            };
            if body.get("realm_id").and_then(|v| v.as_str()) != Some(relay_realm.as_str()) {
                continue;
            }
            let private = body
                .get("private")
                .and_then(|v| v.as_bool())
                .unwrap_or(false);
            if private {
                let owner = body
                    .get("owner_player_id")
                    .and_then(|v| v.as_str())
                    .unwrap_or("");
                let visible: Vec<&str> = body
                    .get("visible_players")
                    .and_then(|v| v.as_array())
                    .map(|a| a.iter().filter_map(|x| x.as_str()).collect())
                    .unwrap_or_default();
                if owner != relay_player && !visible.contains(&relay_player.as_str()) {
                    continue;
                }
            }
            if let (Some(Some(x)), Some(Some(y))) = (
                body.get("pos_x").map(|v| v.as_i64()),
                body.get("pos_y").map(|v| v.as_i64()),
            ) {
                let c = (x.div_euclid(32) as i32, y.div_euclid(32) as i32);
                if !relay_chunks.lock().unwrap().contains(&c) {
                    continue;
                }
            }
            let event_id = body
                .get("event_id")
                .and_then(|v| v.as_str())
                .unwrap_or("")
                .to_string();
            let ev = DeltaEvent {
                event_id,
                realm_id: relay_realm.clone(),
                event_type: body
                    .get("event_type")
                    .and_then(|v| v.as_str())
                    .unwrap_or("")
                    .into(),
                pos: None,
                has_pos: false,
                owner_player_id: body
                    .get("owner_player_id")
                    .and_then(|v| v.as_str())
                    .unwrap_or("")
                    .into(),
                private,
                visible_players: body
                    .get("visible_players")
                    .and_then(|v| v.as_array())
                    .map(|a| {
                        a.iter()
                            .filter_map(|x| x.as_str().map(String::from))
                            .collect()
                    })
                    .unwrap_or_default(),
                server_time_unix_ms: chrono::Utc::now().timestamp_millis(),
                payload_json: serde_json::to_vec(&body).unwrap_or_default(),
                cursor: relay_cursor.lock().unwrap().clone(),
            };
            let env = WsEnvelope {
                seq: 0,
                body: Some(ws_envelope::Body::Delta(ev)),
            };
            if relay_tx.send(env).await.is_err() {
                break;
            }
        }
    });

    let mut commands = 0u32;
    let mut window = tokio::time::Instant::now();
    loop {
        tokio::select! {
            outgoing = rx.recv() => {
                if let Some(env) = outgoing {
                    let mut buf = Vec::new();
                    if env.encode(&mut buf).is_err() { continue; }
                    if sink.send(Message::Binary(buf.into())).await.is_err() { break; }
                }
            }
            incoming = source.next() => {
                match incoming {
                    Some(Ok(Message::Binary(data))) => {
                        if data.len() > app.cfg.max_frame_bytes { let _ = sink.close().await; break; }
                        if window.elapsed() >= Duration::from_secs(1) { commands = 0; window = tokio::time::Instant::now(); }
                        if commands >= app.cfg.rate_limit_per_sec {
                            let env = WsEnvelope { seq: 0, body: Some(ws_envelope::Body::Error(ErrorMessage { code: ErrorCode::RateLimited as i32, message: "rate limited".into() })) };
                            let mut buf = Vec::new();
                            if env.encode(&mut buf).is_err() { continue; }
                            let _ = sink.send(Message::Binary(buf.into())).await;
                            continue;
                        }
                        commands += 1;
                        let env = match WsEnvelope::decode(&data[..]) { Ok(e) => e, Err(_) => continue };
                        match env.body {
                            Some(ws_envelope::Body::Command(cmd)) => {
                                if cmd.realm_id != q.realm { let _ = send_error(&mut sink, ErrorCode::CrossRealm, "cross-realm command").await; continue; }
                                let res = worker.submit_command(SubmitCommandRequest {
                                    realm_id: q.realm.clone(), principal_player_id: player_id.clone(),
                                    command_id: cmd.command_id.clone(), payload: cmd.payload,
                                }).await;
                                let result = match res {
                                    Ok(r) => r.into_inner(),
                                    Err(e) => CommandResult { command_id: cmd.command_id, code: ErrorCode::Internal as i32, message: e.message().to_string(), ..Default::default() },
                                };
                                metrics::counter!("kd_ws_commands_total").increment(1);
                                let out = WsEnvelope { seq: env.seq, body: Some(ws_envelope::Body::CommandResult(result)) };
                                let mut buf = Vec::new();
                                if out.encode(&mut buf).is_err() { continue; }
                                if sink.send(Message::Binary(buf.into())).await.is_err() { break; }
                            }
                            Some(ws_envelope::Body::Heartbeat(_)) => {
                                let out = WsEnvelope { seq: env.seq, body: Some(ws_envelope::Body::Heartbeat(Heartbeat { client_time_unix_ms: chrono::Utc::now().timestamp_millis() })) };
                                let mut buf = Vec::new();
                                if out.encode(&mut buf).is_err() { continue; }
                                let _ = sink.send(Message::Binary(buf.into())).await;
                            }
                            Some(ws_envelope::Body::Subscription(sub)) => {
                                if sub.chunks.len() > app.cfg.max_subscriptions { continue; }
                                let newset: HashSet<(i32,i32)> = sub.chunks.iter().map(|c| (c.x, c.y)).collect();
                                *chunks.lock().unwrap() = newset;
                                if sub.cursor != *cursor.lock().unwrap() {
                                    send_snapshot(&mut worker, &app, &q.realm, &player_id, &chunks, &cursor, &mut sink, &tx).await;
                                }
                            }
                            _ => {}
                        }
                    }
                    Some(Ok(Message::Ping(p))) => { let _ = sink.send(Message::Pong(p)).await; }
                    Some(Ok(Message::Close(_))) | None => break,
                    Some(Err(_)) => break,
                    _ => {}
                }
            }
        }
    }
    relay.abort();
}

async fn send_snapshot(
    worker: &mut WorkerClient,
    app: &App,
    realm: &str,
    player: &str,
    chunks: &Arc<Mutex<HashSet<(i32, i32)>>>,
    cursor: &Arc<Mutex<String>>,
    sink: &mut WsSink,
    _tx: &mpsc::Sender<WsEnvelope>,
) {
    let cs: Vec<Vec2> = chunks
        .lock()
        .unwrap()
        .iter()
        .map(|(x, y)| Vec2 { x: *x, y: *y })
        .collect();
    if let Ok(snap) = worker
        .get_snapshot(SnapshotRequest {
            realm_id: realm.into(),
            principal_player_id: player.into(),
            chunks: cs,
        })
        .await
    {
        let snap = snap.into_inner();
        *cursor.lock().unwrap() = snap.cursor.clone();
        let env = WsEnvelope {
            seq: 0,
            body: Some(ws_envelope::Body::Snapshot(Snapshot {
                realm_id: snap.realm_id,
                version: snap.version,
                state_json: snap.state_json,
                map_json: snap.map_json,
                server_time_unix_ms: snap.server_time_unix_ms,
                cursor: snap.cursor,
            })),
        };
        let mut buf = Vec::new();
        if env.encode(&mut buf).is_err() {
            return;
        }
        let _ = sink.send(Message::Binary(buf.into())).await;
    }
    let _ = app;
}

async fn send_error(sink: &mut WsSink, code: ErrorCode, msg: &str) -> anyhow::Result<()> {
    let env = WsEnvelope {
        seq: 0,
        body: Some(ws_envelope::Body::Error(ErrorMessage {
            code: code as i32,
            message: msg.into(),
        })),
    };
    let mut buf = Vec::new();
    env.encode(&mut buf)?;
    sink.send(Message::Binary(buf.into())).await?;
    Ok(())
}
