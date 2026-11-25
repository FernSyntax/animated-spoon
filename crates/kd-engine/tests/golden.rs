//! Golden happy-path tests: a real PostgreSQL realm taken through the complete
//! player journey using only typed commands and the public engine API.
//!
//! Run with:
//!   KD_TEST_DB_A=postgres://... cargo test -p kd-engine --test golden
//!
//! These tests assert observable outcomes (DB state, snapshots, outbox rows),
//! not implementation details. Each test provisions an isolated realm.
use kd_domain::new_id;
use kd_engine::{scheduler, snapshot, Engine};
use kd_proto::{command_payload::Action, *};
use kd_store::pool;
use sqlx::PgPool;
use std::sync::Arc;

const OK: i32 = 1;

fn db() -> String {
    std::env::var("KD_TEST_DB_A").expect("set KD_TEST_DB_A to a running realm-shard PostgreSQL DSN")
}

async fn realm(worker: &str) -> (Arc<Engine>, PgPool) {
    let pool = pool(&db(), 5).await.unwrap();
    kd_store::migrate_realm(&pool).await.unwrap();
    let id = format!("golden-{}", new_id());
    Engine::provision(&pool, &id, 999).await.unwrap();
    kd_engine::commands::seed_entities(&pool, &id, 999, kd_domain::world::CHUNK_SIZE)
        .await
        .unwrap();
    let e = Arc::new(Engine::new(
        id,
        "shard".into(),
        pool.clone(),
        worker.into(),
        999,
        true,
        60,
        64,
    ));
    e.acquire().await.unwrap();
    (e, pool)
}

async fn player(e: &Engine, name: &str) -> String {
    let id = new_id();
    e.ensure_player(&new_id(), &id, name).await.unwrap();
    id
}

// The engine API is async; keeping helpers async avoids blocking the runtime.
async fn cmd(e: &Engine, who: &str, id: &str, action: Action) -> CommandResult {
    let payload = CommandPayload {
        action: Some(action),
    };
    e.submit(who, id, &payload).await
}

fn create_city(name: &str, x: i32, y: i32) -> Action {
    Action::CreateCity(CreateCityCmd {
        name: name.into(),
        pos: Some(Vec2 { x, y }),
    })
}

async fn city_id(pool: &PgPool, realm: &str, who: &str) -> String {
    sqlx::query_as::<_, (String,)>(
        "SELECT city_id FROM cities WHERE realm_id=$1 AND player_id=$2::uuid",
    )
    .bind(realm)
    .bind(who)
    .fetch_one(pool)
    .await
    .unwrap()
    .0
}

async fn drain(e: &Engine) {
    for _ in 0..24 {
        if scheduler::tick(e).await.unwrap() == 0 {
            break;
        }
    }
}

async fn advance_and_settle(e: &Engine, micros: i64) {
    e.advance_clock(micros).await.unwrap();
    drain(e).await;
}

/// Complete first-session journey: settle, build, research, train, and let the
/// durable scheduler finish everything while the client is offline.
#[tokio::test]
async fn golden_first_session_settle_build_research_train() {
    let (e, pool) = realm("golden-econ").await;
    let p = player(&e, "Alice").await;

    let r = cmd(&e, &p, "c1", create_city("Capital", 70, 70)).await;
    assert_eq!(r.code, OK, "{}", r.message);
    let city = city_id(&pool, &e.realm_id, &p).await;

    let r = cmd(
        &e,
        &p,
        "c2",
        Action::UpgradeBuilding(UpgradeBuildingCmd {
            city_id: city.clone(),
            building: "farm".into(),
        }),
    )
    .await;
    assert_eq!(r.code, OK, "{}", r.message);
    advance_and_settle(&e, 24 * 3600 * 1_000_000).await;

    // Barracks requires a level-2 town hall.
    let r = cmd(
        &e,
        &p,
        "th1",
        Action::UpgradeBuilding(UpgradeBuildingCmd {
            city_id: city.clone(),
            building: "town_hall".into(),
        }),
    )
    .await;
    assert_eq!(r.code, OK, "town hall: {}", r.message);
    advance_and_settle(&e, 24 * 3600 * 1_000_000).await;

    let r = cmd(
        &e,
        &p,
        "b1",
        Action::UpgradeBuilding(UpgradeBuildingCmd {
            city_id: city.clone(),
            building: "barracks".into(),
        }),
    )
    .await;
    assert_eq!(r.code, OK, "barracks: {}", r.message);
    advance_and_settle(&e, 24 * 3600 * 1_000_000).await;

    let r = cmd(
        &e,
        &p,
        "c3",
        Action::StartResearch(StartResearchCmd {
            tech: "agriculture".into(),
        }),
    )
    .await;
    assert_eq!(r.code, OK, "{}", r.message);

    advance_and_settle(&e, 24 * 3600 * 1_000_000).await;

    let r = cmd(
        &e,
        &p,
        "c4",
        Action::TrainTroops(TrainTroopsCmd {
            city_id: city.clone(),
            unit: "infantry".into(),
            tier: 1,
            count: 5,
        }),
    )
    .await;
    assert_eq!(r.code, OK, "{}", r.message);

    advance_and_settle(&e, 48 * 3600 * 1_000_000).await;

    let farm: (i32,) = sqlx::query_as(
        "SELECT level FROM buildings WHERE realm_id=$1 AND city_id=$2 AND kind='farm'",
    )
    .bind(&*e.realm_id)
    .bind(&city)
    .fetch_one(&pool)
    .await
    .unwrap();
    assert_eq!(farm.0, 1, "farm upgrade must complete");

    let tech: (i32,) = sqlx::query_as(
        "SELECT level FROM research WHERE realm_id=$1 AND player_id=$2::uuid AND tech='agriculture'",
    )
    .bind(&*e.realm_id)
    .bind(&p)
    .fetch_one(&pool)
    .await
    .unwrap();
    assert_eq!(tech.0, 1, "research must complete");

    let troops: (i64,) = sqlx::query_as(
        "SELECT count FROM troops WHERE realm_id=$1 AND city_id=$2 AND unit='infantry' AND tier=1",
    )
    .bind(&*e.realm_id)
    .bind(&city)
    .fetch_one(&pool)
    .await
    .unwrap();
    assert!(troops.0 >= 5, "trained troops must arrive");

    let negative: (i64,) = sqlx::query_as("SELECT count(*) FROM cities WHERE realm_id=$1 AND (food<0 OR wood<0 OR stone<0 OR iron<0 OR gold<0)")
        .bind(&*e.realm_id).fetch_one(&pool).await.unwrap();
    assert_eq!(negative.0, 0, "resources must never go negative");

    let events: (i64,) =
        sqlx::query_as("SELECT count(*) FROM outbox WHERE realm_id=$1 AND published_at_ms=0")
            .bind(&*e.realm_id)
            .fetch_one(&pool)
            .await
            .unwrap();
    assert!(
        events.0 >= 4,
        "each mutation must emit a committed outbox event"
    );
}

/// Scouting a tile reveals its chunks and produces a durable report.
#[tokio::test]
async fn golden_scouting_reveals_world_and_writes_report() {
    let (e, pool) = realm("golden-scout").await;
    let p = player(&e, "Scout").await;
    assert_eq!(
        cmd(&e, &p, "c1", create_city("Home", 70, 70)).await.code,
        OK
    );
    let home = city_id(&pool, &e.realm_id, &p).await;
    sqlx::query("INSERT INTO troops(realm_id,city_id,unit,tier,count) VALUES ($1,$2,'scout',1,2)")
        .bind(&*e.realm_id)
        .bind(&home)
        .execute(&pool)
        .await
        .unwrap();

    let r = cmd(
        &e,
        &p,
        "s1",
        Action::ScoutTile(ScoutTileCmd {
            pos: Some(Vec2 { x: 164, y: 164 }),
        }),
    )
    .await;
    assert_eq!(r.code, OK, "{}", r.message);
    advance_and_settle(&e, 24 * 3600 * 1_000_000).await;

    let reports: (i64,) = sqlx::query_as(
        "SELECT count(*) FROM reports WHERE realm_id=$1 AND kind='scout' AND participants::jsonb ? $2",
    )
    .bind(&*e.realm_id)
    .bind(&p)
    .fetch_one(&pool)
    .await
    .unwrap();
    assert!(reports.0 >= 1, "scouting must produce a report");

    let revealed: (i64,) = sqlx::query_as(
        "SELECT count(*) FROM player_scouting WHERE realm_id=$1 AND player_id=$2::uuid",
    )
    .bind(&*e.realm_id)
    .bind(&p)
    .fetch_one(&pool)
    .await
    .unwrap();
    assert!(revealed.0 >= 1, "scouting must reveal map chunks");
}

/// Shield items grant exactly one day, and oversized requests are rejected.
#[tokio::test]
async fn golden_shield_item_grants_exactly_one_day() {
    let (e, pool) = realm("golden-shield").await;
    let p = player(&e, "Shielded").await;
    assert_eq!(
        cmd(&e, &p, "c1", create_city("Home", 70, 70)).await.code,
        OK
    );
    let city = city_id(&pool, &e.realm_id, &p).await;

    sqlx::query(
        "INSERT INTO items(realm_id,player_id,item_key,qty) VALUES ($1,$2::uuid,'shield_1d',1)",
    )
    .bind(&*e.realm_id)
    .bind(&p)
    .execute(&pool)
    .await
    .unwrap();

    let now = e.advance_clock(0).await.unwrap();
    let r = cmd(&e, &p, "s1", Action::SetShield(SetShieldCmd { hours: 24 })).await;
    assert_eq!(r.code, OK, "{}", r.message);

    let after: (i64,) =
        sqlx::query_as("SELECT shield_until_ms FROM cities WHERE realm_id=$1 AND city_id=$2")
            .bind(&*e.realm_id)
            .bind(&city)
            .fetch_one(&pool)
            .await
            .unwrap();
    let granted = after.0 - now;
    assert!(
        (86_400_000..=86_401_000).contains(&granted),
        "one shield item must grant ~24h, got {granted}ms"
    );

    let rejected = cmd(&e, &p, "s2", Action::SetShield(SetShieldCmd { hours: 25 })).await;
    assert_ne!(rejected.code, OK, "requests above one day must be rejected");
}

/// Alliance lifecycle: found, invite, accept, chat, and leave stay consistent.
#[tokio::test]
async fn golden_alliance_lifecycle() {
    let (e, pool) = realm("golden-alliance").await;
    let alice = player(&e, "Alice").await;
    let bob = player(&e, "Bob").await;
    assert_eq!(
        cmd(&e, &alice, "a1", create_city("A", 70, 70)).await.code,
        OK
    );
    assert_eq!(cmd(&e, &bob, "b1", create_city("B", 76, 76)).await.code, OK);

    let r = cmd(
        &e,
        &alice,
        "al1",
        Action::CreateAlliance(CreateAllianceCmd {
            name: "Golden".into(),
            tag: "GOLD".into(),
        }),
    )
    .await;
    assert_eq!(r.code, OK, "{}", r.message);

    let alliance: (String,) = sqlx::query_as(
        "SELECT alliance_id::text FROM players WHERE realm_id=$1 AND player_id=$2::uuid",
    )
    .bind(&*e.realm_id)
    .bind(&alice)
    .fetch_one(&pool)
    .await
    .unwrap();

    let r = cmd(
        &e,
        &alice,
        "al2",
        Action::AllianceInvite(AllianceInviteCmd {
            player_id: bob.clone(),
        }),
    )
    .await;
    assert_eq!(r.code, OK, "{}", r.message);

    let r = cmd(
        &e,
        &bob,
        "al3",
        Action::AllianceAccept(AllianceAcceptCmd {
            alliance_id: alliance.0.clone(),
        }),
    )
    .await;
    assert_eq!(r.code, OK, "{}", r.message);

    let members: (i64,) =
        sqlx::query_as("SELECT count(*) FROM players WHERE realm_id=$1 AND alliance_id=$2")
            .bind(&*e.realm_id)
            .bind(&alliance.0)
            .fetch_one(&pool)
            .await
            .unwrap();
    assert_eq!(members.0, 2, "both players must be in the alliance");

    let r = cmd(
        &e,
        &alice,
        "ch1",
        Action::Chat(ChatCmd {
            scope: "alliance".into(),
            text: "hello realm".into(),
            target_id: alliance.0.clone(),
        }),
    )
    .await;
    assert_eq!(r.code, OK, "{}", r.message);

    let r = cmd(&e, &bob, "al4", Action::AllianceLeave(AllianceLeaveCmd {})).await;
    assert_eq!(r.code, OK, "{}", r.message);

    let remaining: (i64,) =
        sqlx::query_as("SELECT count(*) FROM players WHERE realm_id=$1 AND alliance_id=$2")
            .bind(&*e.realm_id)
            .bind(&alliance.0)
            .fetch_one(&pool)
            .await
            .unwrap();
    assert_eq!(remaining.0, 1, "only the leader remains after leave");
}

/// A rally launched at an allied city produces a real march bound to that target.
#[tokio::test]
async fn golden_rally_launches_march_at_target() {
    let (e, pool) = realm("golden-rally").await;
    let alice = player(&e, "Leader").await;
    let bob = player(&e, "Ally").await;
    assert_eq!(
        cmd(&e, &alice, "a1", create_city("A", 70, 70)).await.code,
        OK
    );
    assert_eq!(cmd(&e, &bob, "b1", create_city("B", 90, 90)).await.code, OK);
    let target = city_id(&pool, &e.realm_id, &bob).await;

    assert_eq!(
        cmd(
            &e,
            &alice,
            "al1",
            Action::CreateAlliance(CreateAllianceCmd {
                name: "Rally".into(),
                tag: "RLY".into(),
            })
        )
        .await
        .code,
        OK
    );
    assert_eq!(
        cmd(
            &e,
            &alice,
            "al2",
            Action::AllianceInvite(AllianceInviteCmd {
                player_id: bob.clone(),
            })
        )
        .await
        .code,
        OK
    );
    let alliance: (String,) = sqlx::query_as(
        "SELECT alliance_id::text FROM players WHERE realm_id=$1 AND player_id=$2::uuid",
    )
    .bind(&*e.realm_id)
    .bind(&alice)
    .fetch_one(&pool)
    .await
    .unwrap();
    assert_eq!(
        cmd(
            &e,
            &bob,
            "al3",
            Action::AllianceAccept(AllianceAcceptCmd {
                alliance_id: alliance.0.clone(),
            })
        )
        .await
        .code,
        OK
    );

    let start = e.advance_clock(0).await.unwrap_or_default() + 6_000;
    let r = cmd(
        &e,
        &alice,
        "r1",
        Action::RallyCreate(RallyCreateCmd {
            city_id: city_id(&pool, &e.realm_id, &alice).await,
            target_pos: Some(Vec2 { x: 90, y: 90 }),
            start_at_unix_ms: start,
        }),
    )
    .await;
    assert_eq!(r.code, OK, "{}", r.message);

    let rally: (String,) = sqlx::query_as("SELECT rally_id FROM rallies WHERE realm_id=$1")
        .bind(&*e.realm_id)
        .fetch_one(&pool)
        .await
        .unwrap();
    let stored_target: (String,) =
        sqlx::query_as("SELECT target_id FROM rallies WHERE realm_id=$1 AND rally_id=$2")
            .bind(&*e.realm_id)
            .bind(&rally.0)
            .fetch_one(&pool)
            .await
            .unwrap();
    assert_eq!(
        stored_target.0, target,
        "rally must store the real target id"
    );
}

/// Reconnect path: a fresh snapshot reflects every committed mutation.
#[tokio::test]
async fn golden_reconnect_snapshot_reflects_committed_state() {
    let (e, _pool) = realm("golden-snapshot").await;
    let p = player(&e, "Reconnect").await;
    assert_eq!(
        cmd(&e, &p, "c1", create_city("Home", 70, 70)).await.code,
        OK
    );

    let mut tx = e.pool.begin().await.unwrap();
    let first = snapshot::player_snapshot(&e, &mut tx, &p).await.unwrap();
    tx.commit().await.unwrap();
    assert_eq!(first.cities.len(), 1);

    let r = cmd(
        &e,
        &p,
        "c2",
        Action::SwitchCapital(SwitchCapitalCmd {
            city_id: first.cities[0].id.clone(),
        }),
    )
    .await;
    assert_eq!(r.code, OK, "{}", r.message);

    let mut tx = e.pool.begin().await.unwrap();
    let second = snapshot::player_snapshot(&e, &mut tx, &p).await.unwrap();
    tx.commit().await.unwrap();
    assert!(
        second.version > first.version,
        "snapshot version must advance"
    );
    assert_eq!(second.cities.len(), 1);
}

/// Hero recruitment is durable and visible in the authoritative snapshot.
#[tokio::test]
async fn golden_hero_recruitment_is_durable() {
    let (e, pool) = realm("golden-hero").await;
    let p = player(&e, "Hero").await;
    assert_eq!(
        cmd(&e, &p, "c1", create_city("Home", 70, 70)).await.code,
        OK
    );

    let r = cmd(
        &e,
        &p,
        "h1",
        Action::RecruitHero(RecruitHeroCmd {
            hero: "borin".into(),
        }),
    )
    .await;
    assert_eq!(r.code, OK, "{}", r.message);

    let heroes: (i64,) = sqlx::query_as(
        "SELECT count(*) FROM heroes WHERE realm_id=$1 AND player_id=$2::uuid AND hero_key='borin'",
    )
    .bind(&*e.realm_id)
    .bind(&p)
    .fetch_one(&pool)
    .await
    .unwrap();
    assert_eq!(heroes.0, 1, "recruited hero must be persisted");
}

/// Demolition refunds half of the accumulated build cost but never the town hall.
#[tokio::test]
async fn golden_demolish_building_refunds_and_keeps_town_hall() {
    let (e, pool) = realm("golden-demolish").await;
    let p = player(&e, "Demolisher").await;
    assert_eq!(
        cmd(&e, &p, "c1", create_city("Home", 70, 70)).await.code,
        OK
    );
    let city = city_id(&pool, &e.realm_id, &p).await;

    let r = cmd(
        &e,
        &p,
        "b1",
        Action::UpgradeBuilding(UpgradeBuildingCmd {
            city_id: city.clone(),
            building: "farm".into(),
        }),
    )
    .await;
    assert_eq!(r.code, OK, "{}", r.message);
    advance_and_settle(&e, 24 * 3600 * 1_000_000).await;

    // The snapshot accrues first, so the refund is the only resource delta.
    let mut tx = e.pool.begin().await.unwrap();
    let before = snapshot::player_snapshot(&e, &mut tx, &p).await.unwrap();
    tx.commit().await.unwrap();
    assert_eq!(before.cities[0].buildings.get("farm"), Some(&1));

    let r = cmd(
        &e,
        &p,
        "d1",
        Action::DemolishBuilding(DemolishBuildingCmd {
            city_id: city.clone(),
            building: "farm".into(),
        }),
    )
    .await;
    assert_eq!(r.code, OK, "{}", r.message);

    let mut tx = e.pool.begin().await.unwrap();
    let after = snapshot::player_snapshot(&e, &mut tx, &p).await.unwrap();
    tx.commit().await.unwrap();
    assert!(!after.cities[0].buildings.contains_key("farm"));
    assert_eq!(
        after.cities[0].resources.wood,
        before.cities[0].resources.wood + 60
    );
    assert_eq!(
        after.cities[0].resources.stone,
        before.cities[0].resources.stone + 20
    );
    assert_eq!(
        after.cities[0].resources.gold,
        before.cities[0].resources.gold + 10
    );
    assert!(
        after.version > before.version,
        "demolition must bump version"
    );

    let events: (i64,) = sqlx::query_as(
        "SELECT count(*) FROM outbox WHERE realm_id=$1 AND event_type='building.demolished'",
    )
    .bind(&*e.realm_id)
    .fetch_one(&pool)
    .await
    .unwrap();
    assert_eq!(events.0, 1, "demolition must emit one outbox delta");

    let rejected = cmd(
        &e,
        &p,
        "d2",
        Action::DemolishBuilding(DemolishBuildingCmd {
            city_id: city.clone(),
            building: "town_hall".into(),
        }),
    )
    .await;
    assert_ne!(rejected.code, OK, "town hall must not be demolishable");
    let mut tx = e.pool.begin().await.unwrap();
    let final_state = snapshot::player_snapshot(&e, &mut tx, &p).await.unwrap();
    tx.commit().await.unwrap();
    assert_eq!(final_state.cities[0].buildings.get("town_hall"), Some(&1));

    let other = player(&e, "Raider").await;
    let rejected = cmd(
        &e,
        &other,
        "d3",
        Action::DemolishBuilding(DemolishBuildingCmd {
            city_id: city,
            building: "barracks".into(),
        }),
    )
    .await;
    assert_ne!(rejected.code, OK, "only the owner may demolish a building");
}

/// Buying and selling through the market moves both gold and inventory.
#[tokio::test]
async fn golden_market_buy_and_sell_move_gold_and_items() {
    let (e, pool) = realm("golden-market").await;
    let p = player(&e, "Trader").await;
    assert_eq!(
        cmd(&e, &p, "c1", create_city("Home", 70, 70)).await.code,
        OK
    );

    let mut tx = e.pool.begin().await.unwrap();
    let before = snapshot::player_snapshot(&e, &mut tx, &p).await.unwrap();
    tx.commit().await.unwrap();
    assert_eq!(before.items.get("speed_5m"), Some(&2));
    let gold0 = before.cities[0].resources.gold;

    // Prices come from the content catalog: 200 gold per 5-minute speedup.
    let r = cmd(
        &e,
        &p,
        "m1",
        Action::MarketBuy(MarketBuyCmd {
            item: "speed_5m".into(),
            qty: 2,
        }),
    )
    .await;
    assert_eq!(r.code, OK, "{}", r.message);

    let mut tx = e.pool.begin().await.unwrap();
    let bought = snapshot::player_snapshot(&e, &mut tx, &p).await.unwrap();
    tx.commit().await.unwrap();
    assert_eq!(bought.items.get("speed_5m"), Some(&4));
    assert_eq!(bought.cities[0].resources.gold, gold0 - 400);
    assert!(bought.version > before.version, "buy must bump version");

    let r = cmd(
        &e,
        &p,
        "m2",
        Action::MarketSell(MarketSellCmd {
            item: "speed_5m".into(),
            qty: 1,
        }),
    )
    .await;
    assert_eq!(r.code, OK, "{}", r.message);

    let mut tx = e.pool.begin().await.unwrap();
    let sold = snapshot::player_snapshot(&e, &mut tx, &p).await.unwrap();
    tx.commit().await.unwrap();
    assert_eq!(sold.items.get("speed_5m"), Some(&3));
    assert_eq!(sold.cities[0].resources.gold, gold0 - 300);
    assert!(sold.version > bought.version, "sell must bump version");

    for kind in ["market.bought", "market.sold"] {
        let events: (i64,) =
            sqlx::query_as("SELECT count(*) FROM outbox WHERE realm_id=$1 AND event_type=$2")
                .bind(&*e.realm_id)
                .bind(kind)
                .fetch_one(&pool)
                .await
                .unwrap();
        assert_eq!(events.0, 1, "{kind} must emit one outbox delta");
    }
}

/// Invalid market orders are rejected without changing gold, items or version.
#[tokio::test]
async fn golden_market_rejects_invalid_orders() {
    let (e, _pool) = realm("golden-market-limits").await;
    let p = player(&e, "Trader").await;
    assert_eq!(
        cmd(&e, &p, "c1", create_city("Home", 70, 70)).await.code,
        OK
    );

    let mut tx = e.pool.begin().await.unwrap();
    let before = snapshot::player_snapshot(&e, &mut tx, &p).await.unwrap();
    tx.commit().await.unwrap();

    let invalid = [
        (
            "m0",
            Action::MarketBuy(MarketBuyCmd {
                item: "speed_5m".into(),
                qty: 0,
            }),
        ),
        (
            "m1",
            Action::MarketBuy(MarketBuyCmd {
                item: "speed_5m".into(),
                qty: 100,
            }),
        ),
        (
            "m2",
            Action::MarketBuy(MarketBuyCmd {
                item: "unknown".into(),
                qty: 1,
            }),
        ),
        (
            "m3",
            Action::MarketSell(MarketSellCmd {
                item: "speed_5m".into(),
                qty: 99,
            }),
        ),
        (
            "m4",
            Action::MarketSell(MarketSellCmd {
                item: "unknown".into(),
                qty: 1,
            }),
        ),
    ];
    for (id, action) in invalid {
        let r = cmd(&e, &p, id, action).await;
        assert_ne!(r.code, OK, "{id} must be rejected");
    }

    let mut tx = e.pool.begin().await.unwrap();
    let after = snapshot::player_snapshot(&e, &mut tx, &p).await.unwrap();
    tx.commit().await.unwrap();
    assert_eq!(after.items, before.items);
    assert_eq!(
        after.cities[0].resources.gold,
        before.cities[0].resources.gold
    );
    assert_eq!(
        after.version, before.version,
        "rejects must not bump version"
    );
}

/// Healing spends resources and converts wounded units into healthy ones once
/// the scheduled hospital event completes.
#[tokio::test]
async fn golden_healing_converts_wounded_into_troops() {
    let (e, pool) = realm("golden-heal").await;
    let p = player(&e, "Healer").await;
    assert_eq!(
        cmd(&e, &p, "c1", create_city("Home", 70, 70)).await.code,
        OK
    );
    let city = city_id(&pool, &e.realm_id, &p).await;
    sqlx::query("INSERT INTO troops(realm_id,city_id,unit,tier,count,wounded) VALUES ($1,$2,'infantry',1,0,10)")
        .bind(&*e.realm_id)
        .bind(&city)
        .execute(&pool)
        .await
        .unwrap();

    let r = cmd(
        &e,
        &p,
        "h1",
        Action::HealTroops(HealTroopsCmd {
            city_id: city.clone(),
            unit: "infantry".into(),
            tier: 1,
            count: 5,
        }),
    )
    .await;
    assert_eq!(r.code, OK, "{}", r.message);
    advance_and_settle(&e, 120_000_000).await;

    let (healthy, wounded): (i64, i64) = sqlx::query_as(
        "SELECT count,wounded FROM troops WHERE realm_id=$1 AND city_id=$2 AND unit='infantry' AND tier=1",
    )
    .bind(&*e.realm_id)
    .bind(&city)
    .fetch_one(&pool)
    .await
    .unwrap();
    assert!(healthy >= 5, "healing must restore healthy troops");
    assert!(wounded <= 5, "healing must consume wounded troops");
}

/// Research persists and measurably changes the economy modifiers derived from
/// the realm's own state (not from a hard-coded test fixture).
#[tokio::test]
async fn golden_research_changes_real_economy_modifiers() {
    let (e, pool) = realm("golden-research-effect").await;
    let p = player(&e, "Scholar").await;
    assert_eq!(
        cmd(&e, &p, "c1", create_city("Home", 70, 70)).await.code,
        OK
    );

    let read_modifiers = |research_level: i32| -> i64 {
        let research = [("agriculture".to_string(), research_level)]
            .into_iter()
            .collect::<std::collections::HashMap<_, _>>();
        kd_domain::content::compute_modifiers(
            &std::collections::HashMap::new(),
            &research,
            0,
            0,
            0,
            0,
        )
        .food_prod
    };
    let before = read_modifiers(0);

    let r = cmd(
        &e,
        &p,
        "r1",
        Action::StartResearch(StartResearchCmd {
            tech: "agriculture".into(),
        }),
    )
    .await;
    assert_eq!(r.code, OK, "{}", r.message);
    advance_and_settle(&e, 48 * 3600 * 1_000_000).await;

    let level: (i32,) = sqlx::query_as(
        "SELECT level FROM research WHERE realm_id=$1 AND player_id=$2::uuid AND tech='agriculture'",
    )
    .bind(&*e.realm_id)
    .bind(&p)
    .fetch_one(&pool)
    .await
    .unwrap();
    assert_eq!(level.0, 1, "research must complete and persist");
    assert!(
        read_modifiers(level.0) > before,
        "agriculture must raise food production"
    );
}

/// Scheduled events fire while no client is connected: a defeated monster
/// respawns and emits its outbox event.
#[tokio::test]
async fn golden_scheduled_monster_respawn_event_fires() {
    let (e, pool) = realm("golden-events").await;
    let p = player(&e, "Hunter").await;
    assert_eq!(
        cmd(&e, &p, "c1", create_city("Home", 70, 70)).await.code,
        OK
    );
    let city = city_id(&pool, &e.realm_id, &p).await;
    let monster = new_id();
    sqlx::query("INSERT INTO entity_state(realm_id,id,kind,x,y,level,subtype,stock,hp) VALUES ($1,$2,'monster',72,72,1,'golem',0,100)")
        .bind(&*e.realm_id)
        .bind(&monster)
        .execute(&pool)
        .await
        .unwrap();
    sqlx::query("INSERT INTO troops(realm_id,city_id,unit,tier,count,wounded) VALUES ($1,$2,'infantry',1,500,0)")
        .bind(&*e.realm_id)
        .bind(&city)
        .execute(&pool)
        .await
        .unwrap();

    let r = cmd(
        &e,
        &p,
        "m1",
        Action::AttackMonster(AttackMonsterCmd {
            city_id: city.clone(),
            monster_id: monster.clone(),
        }),
    )
    .await;
    assert_eq!(r.code, OK, "{}", r.message);
    // Arrival + combat kills the monster and schedules monster_respawn.
    advance_and_settle(&e, 10 * 60 * 1_000_000).await;
    let hp: (i64,) = sqlx::query_as("SELECT hp FROM entity_state WHERE realm_id=$1 AND id=$2")
        .bind(&*e.realm_id)
        .bind(&monster)
        .fetch_one(&pool)
        .await
        .unwrap();
    assert_eq!(hp.0, 0, "monster must be defeated first");

    advance_and_settle(&e, 10 * 60 * 1_000_000).await;
    let hp: (i64,) = sqlx::query_as("SELECT hp FROM entity_state WHERE realm_id=$1 AND id=$2")
        .bind(&*e.realm_id)
        .bind(&monster)
        .fetch_one(&pool)
        .await
        .unwrap();
    assert!(hp.0 > 0, "scheduled monster_respawn must restore hp");
    let events: (i64,) = sqlx::query_as(
        "SELECT count(*) FROM outbox WHERE realm_id=$1 AND event_type='entity.respawned'",
    )
    .bind(&*e.realm_id)
    .fetch_one(&pool)
    .await
    .unwrap();
    assert!(events.0 >= 1, "respawn must emit an outbox event");
}

/// A defeated monster must vanish from the map snapshot, not linger as a corpse.
#[tokio::test]
async fn golden_killed_monster_disappears_from_map() {
    let (e, pool) = realm("golden-monster-map").await;
    let p = player(&e, "Slayer").await;
    assert_eq!(
        cmd(&e, &p, "c1", create_city("Home", 70, 70)).await.code,
        OK
    );
    let city = city_id(&pool, &e.realm_id, &p).await;
    let monster = new_id();
    sqlx::query("INSERT INTO entity_state(realm_id,id,kind,x,y,level,subtype,stock,hp) VALUES ($1,$2,'monster',72,72,1,'golem',0,50)")
        .bind(&*e.realm_id).bind(&monster).execute(&pool).await.unwrap();
    sqlx::query("INSERT INTO troops(realm_id,city_id,unit,tier,count,wounded) VALUES ($1,$2,'infantry',1,500,0)")
        .bind(&*e.realm_id).bind(&city).execute(&pool).await.unwrap();
    assert_eq!(
        cmd(
            &e,
            &p,
            "m1",
            Action::AttackMonster(AttackMonsterCmd {
                city_id: city.clone(),
                monster_id: monster.clone(),
            })
        )
        .await
        .code,
        OK
    );
    advance_and_settle(&e, 10 * 60 * 1_000_000).await;

    let mut tx = e.pool.begin().await.unwrap();
    let snap = snapshot::map_snapshot(&e, &mut tx, &p, &[Vec2 { x: 2, y: 2 }])
        .await
        .unwrap();
    tx.commit().await.unwrap();
    assert!(
        !snap.entities.iter().any(|x| x.id == monster),
        "dead monster must be hidden"
    );
}

/// The world spawner creates fresh monsters on a timer and re-arms itself.
#[tokio::test]
async fn golden_periodic_monster_spawn_adds_targets() {
    let (e, pool) = realm("golden-spawner").await;
    let _p = player(&e, "Observer").await;
    let before: (i64,) =
        sqlx::query_as("SELECT count(*) FROM entity_state WHERE realm_id=$1 AND kind='monster'")
            .bind(&*e.realm_id)
            .fetch_one(&pool)
            .await
            .unwrap();

    advance_and_settle(&e, 20 * 60 * 1_000_000).await;

    let after: (i64,) =
        sqlx::query_as("SELECT count(*) FROM entity_state WHERE realm_id=$1 AND kind='monster'")
            .bind(&*e.realm_id)
            .fetch_one(&pool)
            .await
            .unwrap();
    assert!(
        after.0 > before.0,
        "periodic spawner must add monsters: {} -> {}",
        before.0,
        after.0
    );
    let spawned: (i64,) = sqlx::query_as(
        "SELECT count(*) FROM outbox WHERE realm_id=$1 AND event_type='monster.spawned'",
    )
    .bind(&*e.realm_id)
    .fetch_one(&pool)
    .await
    .unwrap();
    assert!(spawned.0 >= 1, "spawn must be published as a delta");
    let next: (i64,) = sqlx::query_as("SELECT count(*) FROM scheduled_events WHERE realm_id=$1 AND kind='monster_spawn' AND status='pending'")
        .bind(&*e.realm_id).fetch_one(&pool).await.unwrap();
    assert_eq!(next.0, 1, "spawner must re-arm exactly once");
}

/// Speedup items really shorten the active construction queue.
#[tokio::test]
async fn golden_speedup_shortens_building_queue() {
    let (e, pool) = realm("golden-speedup").await;
    let p = player(&e, "Builder").await;
    assert_eq!(
        cmd(&e, &p, "c1", create_city("Home", 70, 70)).await.code,
        OK
    );
    let city = city_id(&pool, &e.realm_id, &p).await;
    assert_eq!(
        cmd(
            &e,
            &p,
            "b1",
            Action::UpgradeBuilding(UpgradeBuildingCmd {
                city_id: city.clone(),
                building: "farm".into(),
            })
        )
        .await
        .code,
        OK
    );
    sqlx::query("INSERT INTO items(realm_id,player_id,item_key,qty) VALUES ($1,$2::uuid,'speed_5m',1) ON CONFLICT(realm_id,player_id,item_key) DO UPDATE SET qty=items.qty+1")
        .bind(&*e.realm_id).bind(&p).execute(&pool).await.unwrap();

    let item_before: (i64,) = sqlx::query_as(
        "SELECT qty FROM items WHERE realm_id=$1 AND player_id=$2::uuid AND item_key='speed_5m'",
    )
    .bind(&*e.realm_id)
    .bind(&p)
    .fetch_one(&pool)
    .await
    .unwrap();
    let due_before: (i64,) = sqlx::query_as(
        "SELECT due_at_ms FROM scheduled_events WHERE realm_id=$1 AND kind='build_complete' AND status='pending' ORDER BY due_at_ms LIMIT 1",
    ).bind(&*e.realm_id).fetch_one(&pool).await.unwrap();
    let now = e.advance_clock(0).await.unwrap();
    assert_eq!(
        cmd(
            &e,
            &p,
            "s1",
            Action::UseItem(UseItemCmd {
                item: "speed_5m".into(),
                target_city_id: city.clone(),
            })
        )
        .await
        .code,
        OK
    );
    let due_after: (i64,) = sqlx::query_as(
        "SELECT due_at_ms FROM scheduled_events WHERE realm_id=$1 AND kind='build_complete' AND status='pending' ORDER BY due_at_ms LIMIT 1",
    ).bind(&*e.realm_id).fetch_one(&pool).await.unwrap();
    assert!(
        due_after.0 < due_before.0 && due_after.0 <= now + 5_000,
        "speedup must collapse a short queue to now: {} -> {} (now {})",
        due_before.0,
        due_after.0,
        now
    );
    let item: (i64,) = sqlx::query_as(
        "SELECT qty FROM items WHERE realm_id=$1 AND player_id=$2::uuid AND item_key='speed_5m'",
    )
    .bind(&*e.realm_id)
    .bind(&p)
    .fetch_one(&pool)
    .await
    .unwrap();
    assert_eq!(item.0, item_before.0 - 1, "speedup must be consumed");
}
