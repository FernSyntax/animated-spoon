//! Environment-driven configuration shared by every service in the workspace.
use std::collections::HashMap;

#[derive(Clone, Debug)]
/// Environment-derived configuration shared by every service.
pub struct Settings {
    pub global_db_url: String,
    /// Shard name -> realm Postgres DSN. Realms route by explicit shard key.
    pub shard_dbs: HashMap<String, String>,
    pub nats_url: String,
    pub valkey_url: String,
    pub jwt_secret: String,
    pub dev_mode: bool,
    pub http_addr: String,
    pub grpc_addr: String,
    pub control_plane_grpc: String,
    pub gateway_http: String,
    pub worker_id: String,
    pub worker_grpc: String,
    pub worker_by_shard: HashMap<String, String>,
    pub lease_secs: u64,
    pub scheduler_batch: usize,
    pub scheduler_interval_ms: u64,
    pub outbox_batch: usize,
    pub outbox_interval_ms: u64,
    pub max_frame_bytes: usize,
    pub max_subscriptions: usize,
    pub rate_limit_per_sec: u32,
    /// Allowed browser origin. `*` is permitted only in dev mode.
    pub cors_origin: String,
    /// Shared secret for internal gRPC calls (gateway -> services).
    pub internal_secret: String,
}

fn env(key: &str, default: &str) -> String {
    std::env::var(format!("KD_{key}")).unwrap_or_else(|_| default.to_string())
}

fn env_map(prefix: &str) -> HashMap<String, String> {
    let mut out = HashMap::new();
    let needle = format!("KD_{prefix}__");
    for (k, v) in std::env::vars() {
        if let Some(rest) = k.strip_prefix(&needle) {
            out.insert(rest.to_ascii_lowercase(), v);
        }
    }
    out
}

impl Settings {
    pub fn load() -> anyhow::Result<Self> {
        Self::load_from(None)
    }

    pub fn load_from(_path: Option<&str>) -> anyhow::Result<Self> {
        let mut shard_dbs = env_map("SHARD_DBS");
        if shard_dbs.is_empty() {
            shard_dbs.insert(
                "shard_a".into(),
                "postgres://kd:kd@localhost:15433/kd_realm_a".into(),
            );
            shard_dbs.insert(
                "shard_b".into(),
                "postgres://kd:kd@localhost:15434/kd_realm_b".into(),
            );
        }
        let worker_by_shard = env_map("WORKER_BY_SHARD");
        let dev_mode = env("DEV_MODE", "true").eq_ignore_ascii_case("true");
        let jwt_secret = env("JWT_SECRET", "dev-only-secret-change-me");
        if !dev_mode {
            if jwt_secret == "dev-only-secret-change-me" {
                anyhow::bail!("jwt_secret must be set explicitly when dev_mode=false");
            }
            if env("CORS_ORIGIN", "*") == "*" {
                anyhow::bail!("CORS_ORIGIN must be an explicit origin when dev_mode=false");
            }
            if env("INTERNAL_SECRET", "dev-internal-secret-change-me")
                == "dev-internal-secret-change-me"
            {
                anyhow::bail!("internal_secret must be set explicitly when dev_mode=false");
            }
        }
        Ok(Self {
            global_db_url: env(
                "GLOBAL_DB_URL",
                "postgres://kd:kd@localhost:15432/kd_global",
            ),
            shard_dbs,
            nats_url: env("NATS_URL", "nats://localhost:4222"),
            valkey_url: env("VALKEY_URL", "redis://localhost:6379"),
            jwt_secret,
            dev_mode,
            http_addr: env("HTTP_ADDR", "0.0.0.0:8080"),
            grpc_addr: env("GRPC_ADDR", "0.0.0.0:50051"),
            control_plane_grpc: env("CONTROL_PLANE_GRPC", "http://localhost:50051"),
            gateway_http: env("GATEWAY_HTTP", "http://localhost:8080"),
            worker_id: env("WORKER_ID", "worker-1"),
            worker_grpc: env("WORKER_GRPC", "http://localhost:50052"),
            worker_by_shard,
            lease_secs: env("LEASE_SECS", "30").parse()?,
            scheduler_batch: env("SCHEDULER_BATCH", "64").parse()?,
            scheduler_interval_ms: env("SCHEDULER_INTERVAL_MS", "100").parse()?,
            outbox_batch: env("OUTBOX_BATCH", "128").parse()?,
            outbox_interval_ms: env("OUTBOX_INTERVAL_MS", "100").parse()?,
            max_frame_bytes: env("MAX_FRAME_BYTES", "65536").parse()?,
            max_subscriptions: env("MAX_SUBSCRIPTIONS", "64").parse()?,
            rate_limit_per_sec: env("RATE_LIMIT_PER_SEC", "40").parse()?,
            cors_origin: env("CORS_ORIGIN", "*"),
            internal_secret: env("INTERNAL_SECRET", "dev-internal-secret-change-me"),
        })
    }
}
