//! Real-DB multiplayer tests: fog of war, two-player PvP atomicity,
//! alliance lifecycle and exclusive hero/item use.
use kd_domain::new_id;
use kd_engine::{scheduler, Engine};
use kd_proto::{command_payload::Action, *};
use kd_store::pool;
use sqlx::PgPool;
use std::sync::Arc;

fn db() -> String {
    std::env::var("KD_TEST_DB_A").expect("set KD_TEST_DB_A")
}

async fn setup(worker: &str) -> (Arc<Engine>, PgPool, String, String) {
    let pool = pool(&db(), 5).await.unwrap();
    kd_store::migrate_realm(&pool).await.unwrap();
    let realm = format!("test-{}", new_id());
    Engine::provision(&pool, &realm, 777).await.unwrap();
    let e = Arc::new(Engine::new(
        realm.clone(),
        "shard".into(),
        pool.clone(),
        worker.into(),
        777,
        true,
        60,
        64,
    ));
    e.acquire().await.unwrap();
    let a = new_id();
    let b = new_id();
    e.ensure_player(&new_id(), &a, "Alice").await.unwrap();
    e.ensure_player(&new_id(), &b, "Bob").await.unwrap();
    (e, pool, a, b)
}

fn city(name: &str, x: i32, y: i32) -> CommandPayload {
    CommandPayload {
        action: Some(Action::CreateCity(CreateCityCmd {
            name: name.into(),
            pos: Some(Vec2 { x, y }),
        })),
    }
}

async fn troop(pool: &PgPool, realm: &str, city: &str, unit: &str, tier: i32, count: i64) {
    sqlx::query("INSERT INTO troops(realm_id,city_id,unit,tier,count) VALUES ($1,$2,$3,$4,$5) ON CONFLICT(realm_id,city_id,unit,tier) DO UPDATE SET count=troops.count+$5")
        .bind(realm).bind(city).bind(unit).bind(tier).bind(count).execute(pool).await.unwrap();
}

async fn city_id(pool: &PgPool, realm: &str, player: &str) -> String {
    sqlx::query_as::<_, (String,)>(
        "SELECT city_id FROM cities WHERE realm_id=$1 AND player_id=$2::uuid",
    )
    .bind(realm)
    .bind(player)
    .fetch_one(pool)
    .await
    .unwrap()
    .0
}

async fn drain(e: &Engine) {
    for _ in 0..12 {
        let _ = scheduler::tick(e).await.unwrap();
    }
}

#[tokio::test]
async fn fog_of_war_hidden_until_scouted() {
    let (e, pool, alice, _) = setup("fog-worker").await;
    assert_eq!(e.submit(&alice, "c1", &city("Home", 70, 70)).await.code, 1);
    let home = city_id(&pool, &e.realm_id, &alice).await;
    troop(&pool, &e.realm_id, &home, "scout", 1, 2).await;

    let mut tx = e.pool.begin().await.unwrap();
    let before = kd_engine::snapshot::map_snapshot(&e, &mut tx, &alice, &[Vec2 { x: 5, y: 5 }])
        .await
        .unwrap();
    assert!(before.fogged_chunks.contains(&(5, 5)));
    assert!(before
        .entities
        .iter()
        .all(|x| x.x.div_euclid(32) != 5 || x.y.div_euclid(32) != 5));
    tx.commit().await.unwrap();

    let scout = CommandPayload {
        action: Some(Action::ScoutTile(ScoutTileCmd {
            pos: Some(Vec2 {
                x: 5 * 32 + 4,
                y: 5 * 32 + 4,
            }),
        })),
    };
    assert_eq!(e.submit(&alice, "s1", &scout).await.code, 1);
    let march_hero: (String,) = sqlx::query_as(
        "SELECT hero FROM marches WHERE realm_id=$1 AND player_id=$2::uuid ORDER BY depart_at_ms DESC LIMIT 1",
    )
    .bind(&*e.realm_id)
    .bind(&alice)
    .fetch_one(&pool)
    .await
    .unwrap();
    assert_eq!(march_hero.0, "aurora", "a free hero accompanies the march");
    e.advance_clock(24 * 3600 * 1_000_000).await.unwrap();
    drain(&e).await;

    let mut tx = e.pool.begin().await.unwrap();
    let after = kd_engine::snapshot::map_snapshot(&e, &mut tx, &alice, &[Vec2 { x: 5, y: 5 }])
        .await
        .unwrap();
    assert!(
        !after.fogged_chunks.contains(&(5, 5)),
        "chunk should be revealed after scout"
    );
    tx.commit().await.unwrap();

    let n: (i64,) = sqlx::query_as(
        "SELECT count(*) FROM player_scouting WHERE realm_id=$1 AND player_id=$2::uuid",
    )
    .bind(&*e.realm_id)
    .bind(&alice)
    .fetch_one(&pool)
    .await
    .unwrap();
    assert!(n.0 >= 9);
}

#[tokio::test]
async fn two_player_pvp_changes_both_sides_atomically() {
    let (e, pool, alice, bob) = setup("pvp-worker").await;
    assert_eq!(
        e.submit(&alice, "a1", &city("Alice", 100, 100)).await.code,
        1
    );
    assert_eq!(e.submit(&bob, "b1", &city("Bob", 104, 104)).await.code, 1);
    let ac = city_id(&pool, &e.realm_id, &alice).await;
    let bc = city_id(&pool, &e.realm_id, &bob).await;
    troop(&pool, &e.realm_id, &ac, "scout", 1, 1).await;
    troop(&pool, &e.realm_id, &ac, "infantry", 1, 200).await;
    troop(&pool, &e.realm_id, &bc, "infantry", 1, 20).await;

    // Scout is required before attacking.
    let scout = CommandPayload {
        action: Some(Action::ScoutTile(ScoutTileCmd {
            pos: Some(Vec2 { x: 104, y: 104 }),
        })),
    };
    assert_eq!(e.submit(&alice, "a2", &scout).await.code, 1);
    e.advance_clock(48 * 3600 * 1_000_000).await.unwrap();
    drain(&e).await;
    e.advance_clock(3600 * 1_000_000).await.unwrap();
    drain(&e).await;
    let active: (i64,) = sqlx::query_as("SELECT count(*) FROM marches WHERE realm_id=$1 AND player_id=$2::uuid AND state<>'completed'")
        .bind(&*e.realm_id).bind(&alice).fetch_one(&pool).await.unwrap();
    assert_eq!(active.0, 0, "scout march must finish before attacking");

    let before: (i64,) = sqlx::query_as(
        "SELECT count FROM troops WHERE realm_id=$1 AND city_id=$2 AND unit='infantry' AND tier=1",
    )
    .bind(&*e.realm_id)
    .bind(&bc)
    .fetch_one(&pool)
    .await
    .unwrap();

    let attack = CommandPayload {
        action: Some(Action::AttackCity(AttackCityCmd {
            city_id: ac.clone(),
            target_city_id: bc.clone(),
        })),
    };
    let r = e.submit(&alice, "a3", &attack).await;
    assert_eq!(r.code, 1, "attack: {}", r.message);
    e.advance_clock(48 * 3600 * 1_000_000).await.unwrap();
    drain(&e).await;

    let after: (i64,) = sqlx::query_as(
        "SELECT count FROM troops WHERE realm_id=$1 AND city_id=$2 AND unit='infantry' AND tier=1",
    )
    .bind(&*e.realm_id)
    .bind(&bc)
    .fetch_one(&pool)
    .await
    .unwrap();
    assert!(
        after.0 < before.0,
        "defender troops must drop: {before:?} -> {after:?}"
    );

    let reports: (i64,) = sqlx::query_as("SELECT count(*) FROM reports WHERE realm_id=$1 AND kind='pvp' AND participants::jsonb ? $2 AND participants::jsonb ? $3")
        .bind(&*e.realm_id).bind(&alice).bind(&bob).fetch_one(&pool).await.unwrap();
    assert_eq!(reports.0, 1, "one PvP report visible to both participants");
}

#[tokio::test]
async fn alliance_lifecycle_and_item_consumption() {
    let (e, pool, alice, bob) = setup("social-worker").await;
    assert_eq!(e.submit(&alice, "a1", &city("A", 70, 70)).await.code, 1);
    assert_eq!(e.submit(&bob, "b1", &city("B", 73, 70)).await.code, 1);
    let create = CommandPayload {
        action: Some(Action::CreateAlliance(CreateAllianceCmd {
            name: "Test".into(),
            tag: "TST".into(),
        })),
    };
    assert_eq!(e.submit(&alice, "a2", &create).await.code, 1);
    let aid: (String,) =
        sqlx::query_as("SELECT alliance_id FROM players WHERE realm_id=$1 AND player_id=$2::uuid")
            .bind(&*e.realm_id)
            .bind(&alice)
            .fetch_one(&pool)
            .await
            .unwrap();
    let invite = CommandPayload {
        action: Some(Action::AllianceInvite(AllianceInviteCmd {
            player_id: bob.clone(),
        })),
    };
    let r = e.submit(&alice, "a3", &invite).await;
    assert_eq!(r.code, 1, "invite: {}", r.message);
    let accept = CommandPayload {
        action: Some(Action::AllianceAccept(AllianceAcceptCmd {
            alliance_id: aid.0.clone(),
        })),
    };
    let r = e.submit(&bob, "b2", &accept).await;
    assert_eq!(r.code, 1, "accept: {}", r.message);
    let role: (Option<String>,) = sqlx::query_as(
        "SELECT alliance_role FROM players WHERE realm_id=$1 AND player_id=$2::uuid",
    )
    .bind(&*e.realm_id)
    .bind(&bob)
    .fetch_one(&pool)
    .await
    .unwrap();
    assert_eq!(role.0.as_deref(), Some("member"));

    let recruit = CommandPayload {
        action: Some(Action::RecruitHero(RecruitHeroCmd {
            hero: "borin".into(),
        })),
    };
    let r = e.submit(&alice, "a4", &recruit).await;
    assert_eq!(r.code, 1, "recruit hero: {}", r.message);
    let recruited: (i64,) = sqlx::query_as(
        "SELECT count(*) FROM heroes WHERE realm_id=$1 AND player_id=$2::uuid AND hero_key='borin'",
    )
    .bind(&*e.realm_id)
    .bind(&alice)
    .fetch_one(&pool)
    .await
    .unwrap();
    assert_eq!(recruited.0, 1);

    let alice_city = city_id(&pool, &e.realm_id, &alice).await;
    sqlx::query("UPDATE cities SET food=1000000,wood=1000000,stone=1000000,iron=1000000,gold=1000000 WHERE realm_id=$1 AND city_id=$2")
        .bind(&*e.realm_id)
        .bind(&alice_city)
        .execute(&pool)
        .await
        .unwrap();
    let upgrade = CommandPayload {
        action: Some(Action::UpgradeBuilding(UpgradeBuildingCmd {
            city_id: alice_city.clone(),
            building: "farm".into(),
        })),
    };
    let r = e.submit(&alice, "a5", &upgrade).await;
    assert_eq!(r.code, 1, "start construction: {}", r.message);
    let due_before: (i64,) = sqlx::query_as("SELECT due_at_ms FROM scheduled_events WHERE realm_id=$1 AND kind='build_complete' AND status='pending' AND payload->>'city_id'=$2 ORDER BY due_at_ms LIMIT 1")
        .bind(&*e.realm_id).bind(&alice_city).fetch_one(&pool).await.unwrap();

    let help = CommandPayload {
        action: Some(Action::AllianceHelp(AllianceHelpCmd {
            target_player_id: alice.clone(),
        })),
    };
    let r = e.submit(&bob, "b3", &help).await;
    assert_eq!(r.code, 1, "alliance help: {}", r.message);
    let due_after_help: (i64,) = sqlx::query_as("SELECT due_at_ms FROM scheduled_events WHERE realm_id=$1 AND kind='build_complete' AND status='pending' AND payload->>'city_id'=$2 ORDER BY due_at_ms LIMIT 1")
        .bind(&*e.realm_id).bind(&alice_city).fetch_one(&pool).await.unwrap();
    assert!(
        due_after_help.0 < due_before.0,
        "alliance help shortens the queue"
    );

    let speedup = CommandPayload {
        action: Some(Action::UseItem(UseItemCmd {
            item: "speed_5m".into(),
            target_city_id: alice_city.clone(),
        })),
    };
    let r = e.submit(&alice, "a6", &speedup).await;
    assert_eq!(r.code, 1, "speed up construction: {}", r.message);
    let due_after_speedup: (i64,) = sqlx::query_as("SELECT due_at_ms FROM scheduled_events WHERE realm_id=$1 AND kind='build_complete' AND status='pending' AND payload->>'city_id'=$2 ORDER BY due_at_ms LIMIT 1")
        .bind(&*e.realm_id).bind(&alice_city).fetch_one(&pool).await.unwrap();
    assert!(due_after_speedup.0 <= due_after_help.0);

    sqlx::query(
        "INSERT INTO items(realm_id,player_id,item_key,qty) VALUES ($1,$2::uuid,'scout_kit',1)",
    )
    .bind(&*e.realm_id)
    .bind(&alice)
    .execute(&pool)
    .await
    .unwrap();
    let scout_kit = CommandPayload {
        action: Some(Action::UseItem(UseItemCmd {
            item: "scout_kit".into(),
            target_city_id: String::new(),
        })),
    };
    let r = e.submit(&alice, "a7", &scout_kit).await;
    assert_eq!(r.code, 1, "scout kit: {}", r.message);
    let revealed: (i64,) = sqlx::query_as(
        "SELECT count(*) FROM player_scouting WHERE realm_id=$1 AND player_id=$2::uuid",
    )
    .bind(&*e.realm_id)
    .bind(&alice)
    .fetch_one(&pool)
    .await
    .unwrap();
    assert_eq!(revealed.0, 9, "scout kit reveals the nearby 3x3 chunks");

    // Item consumption is atomic and cannot go below zero.
    let use_item = CommandPayload {
        action: Some(Action::UseItem(UseItemCmd {
            item: "bundle_small".into(),
            target_city_id: String::new(),
        })),
    };
    assert_eq!(e.submit(&alice, "a8", &use_item).await.code, 1);
    assert_ne!(e.submit(&alice, "a9", &use_item).await.code, 1); // second bundle none -> rejected
    let qty: (i64,) = sqlx::query_as("SELECT qty FROM items WHERE realm_id=$1 AND player_id=$2::uuid AND item_key='bundle_small'")
        .bind(&*e.realm_id).bind(&alice).fetch_one(&pool).await.unwrap();
    assert_eq!(qty.0, 0);
}

#[tokio::test]
async fn reconnect_snapshot_reflects_committed_state() {
    let (e, _pool, alice, _) = setup("resync-worker").await;
    assert_eq!(e.submit(&alice, "c1", &city("Home", 70, 70)).await.code, 1);
    let mut tx = e.pool.begin().await.unwrap();
    let before = kd_engine::snapshot::player_snapshot(&e, &mut tx, &alice)
        .await
        .unwrap();
    let before_count = before.cities.len();
    tx.commit().await.unwrap();
    assert_eq!(before_count, 1);

    let found = CommandPayload {
        action: Some(Action::CreateCity(CreateCityCmd {
            name: "Second".into(),
            pos: Some(Vec2 { x: 80, y: 80 }),
        })),
    };
    assert_eq!(e.submit(&alice, "c2", &found).await.code, 1);
    let mut tx = e.pool.begin().await.unwrap();
    let after = kd_engine::snapshot::player_snapshot(&e, &mut tx, &alice)
        .await
        .unwrap();
    tx.commit().await.unwrap();
    assert_eq!(
        after.cities.len(),
        2,
        "fresh snapshot after reconnect must include committed city"
    );
    assert!(after.version >= before.version);
}
