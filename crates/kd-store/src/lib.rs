//! Persistence boundaries. Global DB holds identity/routing only; realm DBs hold
//! all gameplay. Connections are bounded; no in-memory authoritative state.
use sqlx::postgres::{PgPool, PgPoolOptions};
use std::collections::HashMap;
use std::time::Duration;

pub static GLOBAL_MIGRATOR: sqlx::migrate::Migrator = sqlx::migrate!("../../migrations/global");
pub static REALM_MIGRATOR: sqlx::migrate::Migrator = sqlx::migrate!("../../migrations/realm");

/// Build a bounded SQLx pool for one database.
pub async fn pool(url: &str, max: u32) -> anyhow::Result<PgPool> {
    Ok(PgPoolOptions::new()
        .max_connections(max)
        .acquire_timeout(Duration::from_secs(5))
        .connect(url)
        .await?)
}

/// Apply all global-schema migrations.
pub async fn migrate_global(p: &PgPool) -> anyhow::Result<()> {
    GLOBAL_MIGRATOR.run(p).await?;
    Ok(())
}

/// Apply all realm-shard migrations.
pub async fn migrate_realm(p: &PgPool) -> anyhow::Result<()> {
    REALM_MIGRATOR.run(p).await?;
    Ok(())
}

#[derive(Clone)]
/// Access to the global database and the configured realm shards.
pub struct Store {
    pub global: PgPool,
    pub realm_shards: HashMap<String, PgPool>,
}

impl Store {
    pub async fn from_config(cfg: &kd_common::config::Settings) -> anyhow::Result<Self> {
        let global = pool(&cfg.global_db_url, 30).await?;
        migrate_global(&global).await?;
        let mut realm_shards = HashMap::new();
        for (name, url) in &cfg.shard_dbs {
            let p = pool(url, 20).await?;
            migrate_realm(&p).await?;
            realm_shards.insert(name.clone(), p);
        }
        Ok(Self {
            global,
            realm_shards,
        })
    }

    pub fn realm(&self, shard: &str) -> anyhow::Result<&PgPool> {
        self.realm_shards
            .get(shard)
            .ok_or_else(|| anyhow::anyhow!("unknown realm shard: {shard}"))
    }
}
