//! gRPC surface of the fenced realm worker.
//!
//! Every mutation is dispatched into the owning [Engine], which performs the
//! fencing check inside the same database transaction as the write.
use kd_engine::Engine;
use kd_proto::realm_service_server::RealmService;
use kd_proto::*;
use std::collections::HashMap;
use std::sync::Arc;
use tonic::{Request, Response, Status};

pub struct Worker {
    pub(crate) engines: Arc<HashMap<String, Arc<Engine>>>,
    pub(crate) ready: Arc<std::sync::atomic::AtomicBool>,
    pub(crate) worker_id: String,
}

#[tonic::async_trait]
impl RealmService for Worker {
    async fn submit_command(
        &self,
        req: Request<SubmitCommandRequest>,
    ) -> Result<Response<CommandResult>, Status> {
        let r = req.into_inner();
        let engine = self
            .engines
            .get(&r.realm_id)
            .ok_or_else(|| Status::not_found("realm not hosted here"))?;
        // Principal id is supplied by the gateway, whose call is authenticated by the internal shared-secret interceptor.
        let principal = r.principal_player_id;
        if principal.is_empty() || uuid::Uuid::parse_str(&principal).is_err() {
            return Err(Status::unauthenticated("invalid principal"));
        }
        let payload = r
            .payload
            .ok_or_else(|| Status::invalid_argument("missing payload"))?;
        let started = std::time::Instant::now();
        let result = engine.submit(&principal, &r.command_id, &payload).await;
        metrics::histogram!("kd_command_latency_ms")
            .record(started.elapsed().as_secs_f64() * 1000.0);
        metrics::counter!("kd_commands_total", "code" => result.code.to_string()).increment(1);
        Ok(Response::new(result))
    }

    async fn get_snapshot(
        &self,
        req: Request<SnapshotRequest>,
    ) -> Result<Response<SnapshotResponse>, Status> {
        let r = req.into_inner();
        let engine = self
            .engines
            .get(&r.realm_id)
            .ok_or_else(|| Status::not_found("realm not hosted here"))?;
        let mut tx = engine
            .tx()
            .await
            .map_err(|e| Status::failed_precondition(e.to_string()))?;
        let player = kd_engine::snapshot::player_snapshot(engine, &mut tx, &r.principal_player_id)
            .await
            .map_err(|e| Status::internal(e.to_string()))?;
        let map =
            kd_engine::snapshot::map_snapshot(engine, &mut tx, &r.principal_player_id, &r.chunks)
                .await
                .map_err(|e| Status::internal(e.to_string()))?;
        let version = player.version;
        let now = player.server_time_ms;
        tx.commit()
            .await
            .map_err(|e| Status::internal(e.to_string()))?;
        Ok(Response::new(SnapshotResponse {
            realm_id: r.realm_id,
            version,
            state_json: serde_json::to_vec(&player).unwrap_or_default(),
            map_json: serde_json::to_vec(&map).unwrap_or_default(),
            server_time_unix_ms: now,
            cursor: format!("{version}:{now}"),
        }))
    }

    async fn health(&self, _req: Request<Empty>) -> Result<Response<WorkerHealth>, Status> {
        Ok(Response::new(WorkerHealth {
            worker_id: self.worker_id.clone(),
            realms: self.engines.keys().cloned().collect(),
            ready: self.ready.load(std::sync::atomic::Ordering::SeqCst),
        }))
    }

    async fn ensure_player(
        &self,
        req: Request<EnsurePlayerRequest>,
    ) -> Result<Response<EnsurePlayerResponse>, Status> {
        let r = req.into_inner();
        let engine = self
            .engines
            .get(&r.realm_id)
            .ok_or_else(|| Status::not_found("realm not hosted here"))?;
        if uuid::Uuid::parse_str(&r.player_id).is_err() {
            return Err(Status::invalid_argument("bad player id"));
        }
        let created = engine
            .ensure_player(&r.account_id, &r.player_id, &r.name)
            .await
            .map_err(|e| Status::internal(e.to_string()))?;
        Ok(Response::new(EnsurePlayerResponse {
            player_id: r.player_id,
            created,
        }))
    }

    async fn advance_clock(
        &self,
        req: Request<AdvanceClockRequest>,
    ) -> Result<Response<AdvanceClockResponse>, Status> {
        if !self
            .engines
            .values()
            .next()
            .map(|e| e.dev_mode)
            .unwrap_or(false)
        {
            return Err(Status::permission_denied("clock control disabled"));
        }
        let r = req.into_inner();
        let engine = self
            .engines
            .get(&r.realm_id)
            .ok_or_else(|| Status::not_found("realm not hosted here"))?;
        let now = engine
            .advance_clock(r.delta_micros)
            .await
            .map_err(|e| Status::internal(e.to_string()))?;
        Ok(Response::new(AdvanceClockResponse { clock_now_ms: now }))
    }
}
