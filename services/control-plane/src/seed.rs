//! Idempotent seeding of the realm directory from `KD_REALMS`.
use kd_common::auth::Auth;
use kd_common::config::Settings;
use kd_store::Store;

pub async fn seed_realms(store: &Store, cfg: &Settings) -> anyhow::Result<()> {
    let spec = std::env::var("KD_REALMS")
        .unwrap_or_else(|_| "realm-a:shard_a:12345,realm-b:shard_b:67890".into());
    for entry in spec.split(',') {
        let parts: Vec<&str> = entry.trim().split(':').collect();
        if parts.len() < 2 {
            continue;
        }
        let (realm, shard, seed) = (
            parts[0],
            parts[1],
            parts
                .get(2)
                .and_then(|s| s.parse::<i64>().ok())
                .unwrap_or(1),
        );
        if !store.realm_shards.contains_key(shard) {
            continue;
        }
        sqlx::query("INSERT INTO realms(realm_id,name,shard,seed) VALUES ($1,$2,$3,$4) ON CONFLICT(realm_id) DO NOTHING")
            .bind(realm).bind(realm).bind(shard).bind(seed).execute(&store.global).await?;
    }
    // Development accounts are created only in dev mode (Argon2id hashes).
    if cfg.dev_mode {
        for (u, p) in [("alice", "password123"), ("bob", "password123")] {
            let exists: Option<(i32,)> = sqlx::query_as("SELECT 1 FROM accounts WHERE username=$1")
                .bind(u)
                .fetch_optional(&store.global)
                .await?;
            if exists.is_none() {
                let hash = Auth::hash_password(p)?;
                sqlx::query("INSERT INTO accounts(id,username,password_hash,display_name) VALUES ($1,$2,$3,$4)")
                    .bind(uuid::Uuid::new_v4()).bind(u).bind(hash).bind(u).execute(&store.global).await?;
            }
        }
    }
    Ok(())
}
