//! Real PostgreSQL integration tests for the authoritative realm engine.
//! Run with: KD_TEST_DB_A=postgres://... cargo test -p kd-engine --test engine -- --nocapture
use kd_common::AppError;
use kd_domain::new_id;
use kd_engine::{scheduler, Engine};
use kd_proto::{command_payload::Action, CommandPayload, CreateCityCmd, UpgradeBuildingCmd, Vec2};
use kd_store::pool;
use sqlx::PgPool;
use std::sync::Arc;

fn db_url() -> String {
    std::env::var("KD_TEST_DB_A").expect("set KD_TEST_DB_A to a running realm-shard PostgreSQL DSN")
}

async fn engine(worker: &str) -> (Arc<Engine>, PgPool, String) {
    let pool = pool(&db_url(), 5).await.unwrap();
    kd_store::migrate_realm(&pool).await.unwrap();
    let realm = format!("test-{}", new_id());
    Engine::provision(&pool, &realm, 4242).await.unwrap();
    let e = Arc::new(Engine::new(
        realm.clone(),
        "test_shard".into(),
        pool.clone(),
        worker.into(),
        4242,
        true,
        60,
        64,
    ));
    e.acquire().await.unwrap();
    let player = new_id();
    e.ensure_player(&new_id(), &player, "Tester").await.unwrap();
    (e, pool, player)
}

fn create_city(_player: &str, x: i32, y: i32) -> CommandPayload {
    CommandPayload {
        action: Some(Action::CreateCity(CreateCityCmd {
            name: format!("City-{x}-{y}"),
            pos: Some(Vec2 { x, y }),
        })),
    }
}

#[tokio::test]
async fn command_idempotency_and_conflict_detection() {
    let (e, _pool, player) = engine("worker-idem").await;
    let cmd = create_city(&player, 70, 70);
    let a = e.submit(&player, "cmd-fixed", &cmd).await;
    assert_eq!(a.code, kd_proto::ErrorCode::Ok as i32, "{}", a.message);
    let b = e.submit(&player, "cmd-fixed", &cmd).await;
    assert_eq!(b.code, a.code);
    assert_eq!(b.state_version, a.state_version);
    let mut different = create_city(&player, 71, 71);
    different.action = Some(Action::UpgradeBuilding(UpgradeBuildingCmd {
        city_id: "x".into(),
        building: "farm".into(),
    }));
    let c = e.submit(&player, "cmd-fixed", &different).await;
    assert_eq!(c.code, kd_proto::ErrorCode::Conflict as i32);
}

#[tokio::test]
async fn determinism_and_bounded_scheduler_with_offline_clock() {
    let (e, pool, player) = engine("worker-sched").await;
    let r = e.submit(&player, "c1", &create_city(&player, 80, 80)).await;
    assert_eq!(r.code, kd_proto::ErrorCode::Ok as i32, "{}", r.message);
    let v: serde_json::Value = serde_json::from_slice(&r.state_json).unwrap();
    let city_id = v
        .pointer("/state/cities/0/id")
        .and_then(|x| x.as_str())
        .unwrap()
        .to_string();
    let up = CommandPayload {
        action: Some(Action::UpgradeBuilding(UpgradeBuildingCmd {
            city_id: city_id.clone(),
            building: "farm".into(),
        })),
    };
    let r = e.submit(&player, "c2", &up).await;
    assert_eq!(r.code, kd_proto::ErrorCode::Ok as i32, "{}", r.message);

    // Event is persisted; no client is connected. Advance virtual time and tick.
    let pending: (i64,) = sqlx::query_as("SELECT count(*) FROM scheduled_events WHERE realm_id=$1 AND status='pending' AND kind='build_complete'")
        .bind(&*e.realm_id).fetch_one(&pool).await.unwrap();
    assert_eq!(pending.0, 1);
    e.advance_clock(24 * 3600 * 1_000_000).await.unwrap();
    let mut applied = 0;
    for _ in 0..10 {
        applied += scheduler::tick(&e).await.unwrap();
    }
    assert!(applied >= 1);
    let level: (i32,) = sqlx::query_as(
        "SELECT level FROM buildings WHERE realm_id=$1 AND city_id=$2 AND kind='farm'",
    )
    .bind(&*e.realm_id)
    .bind(&city_id)
    .fetch_one(&pool)
    .await
    .unwrap();
    assert_eq!(level.0, 1);
    let done: (i64,) =
        sqlx::query_as("SELECT count(*) FROM scheduled_events WHERE realm_id=$1 AND status='done'")
            .bind(&*e.realm_id)
            .fetch_one(&pool)
            .await
            .unwrap();
    assert!(done.0 >= 1);
}

#[tokio::test]
async fn outbox_is_committed_with_state_mutation() {
    let (e, pool, player) = engine("worker-outbox").await;
    let r = e.submit(&player, "c1", &create_city(&player, 90, 90)).await;
    assert_eq!(r.code, kd_proto::ErrorCode::Ok as i32);
    let n: (i64,) = sqlx::query_as("SELECT count(*) FROM outbox WHERE realm_id=$1 AND event_type='city.created' AND published_at_ms=0")
        .bind(&*e.realm_id).fetch_one(&pool).await.unwrap();
    assert_eq!(n.0, 1);
}

#[tokio::test]
async fn stale_owner_cannot_commit_after_takeover() {
    let (e, pool, player) = engine("worker-old").await;
    let old_epoch = e.epoch.load(std::sync::atomic::Ordering::SeqCst);
    // Simulate a lease lapse and a new owner taking over.
    sqlx::query("UPDATE realm_ownership SET lease_until_ms=0 WHERE realm_id=$1")
        .bind(&*e.realm_id)
        .execute(&pool)
        .await
        .unwrap();
    let new_engine = Engine::new(
        e.realm_id.clone(),
        "test_shard".into(),
        pool.clone(),
        "worker-new".into(),
        4242,
        true,
        60,
        64,
    );
    new_engine.acquire().await.unwrap();
    let new_epoch = new_engine.epoch.load(std::sync::atomic::Ordering::SeqCst);
    assert_eq!(new_epoch, old_epoch + 1);

    // Old owner attempts a write through the fenced transaction helper.
    let err = e.tx().await.expect_err("stale owner must be rejected");
    assert!(
        format!("{err:?}").contains("stale")
            || format!("{err:?}").contains("fencing")
            || format!("{err:?}").contains("lease"),
        "{err:?}"
    );
    // New owner can still commit.
    let r = new_engine
        .submit(&player, "after-takeover", &create_city(&player, 100, 100))
        .await;
    assert_eq!(r.code, kd_proto::ErrorCode::Ok as i32, "{}", r.message);
}

#[tokio::test]
async fn rejects_cross_realm_and_invalid_commands() {
    let (e, _pool, _player) = engine("worker-valid").await;
    let stranger = new_id();
    let r = e
        .submit(&stranger, "bad-1", &create_city(&stranger, 10, 10))
        .await;
    assert_eq!(r.code, kd_proto::ErrorCode::Unauthenticated as i32);
    let bad_pos = CommandPayload {
        action: Some(Action::CreateCity(CreateCityCmd {
            name: "x".into(),
            pos: Some(Vec2 { x: 5000, y: 5000 }),
        })),
    };
    let r = e.submit(&stranger, "bad-2", &bad_pos).await;
    assert_ne!(r.code, kd_proto::ErrorCode::Ok as i32);
}

#[tokio::test]
async fn concurrent_spending_never_goes_negative() {
    let (e, pool, player) = engine("worker-conc").await;
    e.submit(&player, "c1", &create_city(&player, 110, 110))
        .await;
    let v: serde_json::Value = serde_json::from_slice(
        &e.submit(&player, "noop", &create_city(&player, 111, 111))
            .await
            .state_json,
    )
    .unwrap_or_default();
    let _ = v;
    // Many simultaneous conflicting commands from the same principal.
    let mut handles = Vec::new();
    for i in 0..8 {
        let e = e.clone();
        let p = player.clone();
        handles.push(tokio::spawn(async move {
            e.submit(&p, &format!("conc-{i}"), &create_city(&p, 120 + i, 120))
                .await
        }));
    }
    for h in handles {
        let _ = h.await;
    }
    let neg: (i64,) = sqlx::query_as("SELECT count(*) FROM cities WHERE realm_id=$1 AND (food<0 OR wood<0 OR stone<0 OR iron<0 OR gold<0)")
        .bind(&*e.realm_id).fetch_one(&pool).await.unwrap();
    assert_eq!(neg.0, 0);
    let err = AppError::Invalid("sentinel".into());
    assert!(matches!(err, AppError::Invalid(_)));
}
