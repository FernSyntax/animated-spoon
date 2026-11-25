//! Combat resolution when an attack or rally arrives at its target.
//!
//! Split out of `events.rs`; shared helpers live in the parent.
use super::*;

/// Resolve a combat between attacker and defender stacks deterministically.
pub async fn resolve_attack(
    engine: &Engine,
    tx: &mut Transaction<'_, Postgres>,
    march_id: &str,
    attacker: &str,
    attacker_hero: &str,
    target_id: &str,
    units: &mut Vec<ArmyUnit>,
    now: i64,
) -> AppResult<()> {
    let city_def: Option<(String, i64, i32, i64, i64, i64, i64, i64)> = sqlx::query_as(
        "SELECT player_id::text,shield_until_ms,town_hall_level,food,wood,stone,iron,gold FROM cities WHERE realm_id=$1 AND city_id=$2",
    ).bind(&engine.realm_id).bind(target_id).fetch_optional(&mut **tx).await.map_err(|e| AppError::Internal(e.to_string()))?;
    let (def_player, shield, wall, defender_res, is_city) = if let Some((
        p,
        s,
        w,
        f,
        wd,
        st,
        ir,
        g,
    )) = city_def
    {
        (
            p,
            s,
            w,
            ResVec {
                food: f,
                wood: wd,
                stone: st,
                iron: ir,
                gold: g,
            },
            true,
        )
    } else {
        let e: Option<(String, i64, i32)> = sqlx::query_as::<_, (String, i64, i32)>("SELECT COALESCE(owner_player_id::text,''),hp,level FROM entity_state WHERE realm_id=$1 AND id=$2")
            .bind(&engine.realm_id).bind(target_id).fetch_optional(&mut **tx).await.map_err(|e| AppError::Internal(e.to_string()))?;
        let e = e.unwrap_or_else(|| (String::new(), 0, 1));
        (
            e.0,
            0,
            e.2,
            ResVec {
                food: 10000,
                wood: 10000,
                stone: 5000,
                iron: 2000,
                gold: 3000,
            },
            false,
        )
    };
    if shield > now && !def_player.is_empty() && def_player != attacker {
        return Err(AppError::Shielded);
    }
    let defenders: Vec<ArmyUnit> = if is_city {
        load_troops(tx, &engine.realm_id, target_id).await?
    } else {
        vec![ArmyUnit {
            unit: "monster".into(),
            tier: wall as u32,
            count: 50 + wall as u64 * 20,
        }]
    };
    let attacker_hero_level = if attacker_hero.is_empty() {
        0
    } else {
        sqlx::query_as::<_, (i32,)>("SELECT COALESCE((SELECT level FROM heroes WHERE realm_id=$1 AND player_id=$2::uuid AND hero_key=$3 AND assignment=$4),0)")
            .bind(&engine.realm_id)
            .bind(attacker)
            .bind(attacker_hero)
            .bind(march_id)
            .fetch_one(&mut **tx)
            .await
            .map_err(|e| AppError::Internal(e.to_string()))?.0
    };
    let defender_hero_level: (i32,) = sqlx::query_as("SELECT COALESCE((SELECT level FROM heroes WHERE realm_id=$1 AND player_id=(SELECT player_id FROM cities WHERE realm_id=$1 AND city_id=$2) AND assignment=$2 ORDER BY level DESC LIMIT 1),0)")
        .bind(&engine.realm_id)
        .bind(target_id)
        .fetch_one(&mut **tx)
        .await
        .map_err(|e| AppError::Internal(e.to_string()))?;
    let input = CombatInput {
        attackers: units.clone(),
        defenders: defenders.clone(),
        attacker_attack_permille: 1000,
        attacker_defense_permille: 1000,
        defender_attack_permille: 1000,
        defender_defense_permille: 1000,
        wall_level: wall,
        terrain_defense_permille: 0,
        attacker_hero_level,
        defender_hero_level: defender_hero_level.0,
        defender_resources: defender_res,
        // FNV-1a of the march id mixed with time: two simultaneous battles
        // no longer share a seed merely because they started in the same ms.
        seed: {
            let mut id_hash = 0xcbf2_9ce4_8422_2325u64;
            for b in march_id.bytes() {
                id_hash = (id_hash ^ b as u64).wrapping_mul(0x0100_0000_01b3);
            }
            kd_domain::world::mix64(now as u64 ^ id_hash)
        },
    };
    let outcome = sim::resolve(&input);
    *units = sim::survivors(units, &outcome.attacker_losses);
    let def_survivors = sim::survivors(&defenders, &outcome.defender_losses);
    if is_city {
        let defeated = outcome.attacker_won;
        // Set defender troops to survivors and wounded.
        let existing = load_troops(tx, &engine.realm_id, target_id).await?;
        for u in &existing {
            adjust_troop(tx, &engine.realm_id, target_id, u, -(u.count as i64)).await?;
        }
        add_troop_list(tx, &engine.realm_id, target_id, &def_survivors).await?;
        for w in &outcome.defender_wounded {
            sqlx::query("UPDATE troops SET wounded=wounded+$4 WHERE realm_id=$1 AND city_id=$2 AND unit=$3 AND tier=$5")
                .bind(&engine.realm_id).bind(target_id).bind(&w.unit).bind(w.count as i64).bind(w.tier as i32)
                .execute(&mut **tx).await.map_err(|e| AppError::Internal(e.to_string()))?;
        }
        if defeated {
            // Bounded loot debit from defender city with conservation.
            let loot = outcome.loot.saturating_cap(defender_res);
            sqlx::query("UPDATE cities SET food=food-$2,wood=wood-$3,stone=stone-$4,iron=iron-$5,gold=gold-$6 WHERE realm_id=$1 AND city_id=$7")
                .bind(&engine.realm_id).bind(loot.food).bind(loot.wood).bind(loot.stone).bind(loot.iron).bind(loot.gold).bind(target_id)
                .execute(&mut **tx).await.map_err(|e| AppError::Internal(e.to_string()))?;
            sqlx::query("UPDATE marches SET resources=$3 WHERE realm_id=$1 AND id=$2")
                .bind(&engine.realm_id)
                .bind(march_id)
                .bind(serde_json::to_value(loot)?)
                .execute(&mut **tx)
                .await
                .map_err(|e| AppError::Internal(e.to_string()))?;
            bump_score(tx, &engine.realm_id, attacker, None, 200).await?;
            // Capturing a subordinate (non-capital) city requires it to be undefended.
            let cap: (bool,) =
                sqlx::query_as("SELECT is_capital FROM cities WHERE realm_id=$1 AND city_id=$2")
                    .bind(&engine.realm_id)
                    .bind(target_id)
                    .fetch_one(&mut **tx)
                    .await
                    .map_err(|e| AppError::Internal(e.to_string()))?;
            if !cap.0 && def_survivors.is_empty() && !def_player.is_empty() {
                sqlx::query("UPDATE cities SET player_id=$3::uuid,is_capital=false WHERE realm_id=$1 AND city_id=$2")
                    .bind(&engine.realm_id).bind(target_id).bind(attacker).execute(&mut **tx).await.map_err(|e| AppError::Internal(e.to_string()))?;
                delta(
                    engine,
                    tx,
                    "city.captured",
                    EventRouting {
                        pos: None,
                        aggregate_id: target_id.into(),
                        owner_player_id: Some(attacker.into()),
                        private: false,
                        visible_players: vec![],
                    },
                    json!({"city_id":target_id,"new_owner":attacker}),
                )
                .await?;
            }
        }
    } else {
        if outcome.attacker_won {
            sqlx::query("UPDATE entity_state SET hp=0,owner_player_id=$3::uuid,respawn_at_ms=$4 WHERE realm_id=$1 AND id=$2")
                .bind(&engine.realm_id).bind(target_id).bind(attacker).bind(now + 24 * 3_600_000)
                .execute(&mut **tx).await.map_err(|e| AppError::Internal(e.to_string()))?;
            sqlx::query("INSERT INTO territory(realm_id,entity_id,kind,x,y,owner_player_id,captured_at_ms) VALUES ($1,$2,'fort',0,0,$3::uuid,$4) ON CONFLICT(realm_id,entity_id) DO UPDATE SET owner_player_id=$3::uuid,captured_at_ms=$4")
                .bind(&engine.realm_id).bind(target_id).bind(attacker).bind(now).execute(&mut **tx).await.map_err(|e| AppError::Internal(e.to_string()))?;
            bump_score(tx, &engine.realm_id, attacker, None, 500).await?;
            let (_, ally, _) = player_exists(tx, &engine.realm_id, attacker).await?;
            if let Some(a) = ally {
                bump_score(tx, &engine.realm_id, attacker, Some(&a), 500).await?;
            }
        }
    }
    let mut participants = vec![attacker.to_string()];
    if !def_player.is_empty() {
        participants.push(def_player);
    }
    engine
        .report(
            tx,
            if is_city { "pvp" } else { "pve" },
            participants,
            serde_json::to_value(&outcome)?,
        )
        .await
        .map_err(|e| AppError::Internal(e.to_string()))?;
    Ok(())
}
