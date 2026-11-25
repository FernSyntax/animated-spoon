//! Effects applied when scheduled events become due.
//!
//! Split out of `commands.rs`; shared helpers live in the parent module.
use super::*;

/// Dispatch a due scheduled event to its effect handler.
pub async fn handle_event(
    engine: &Engine,
    tx: &mut Transaction<'_, Postgres>,
    kind: &str,
    payload: &Value,
) -> AppResult<()> {
    match kind {
        "build_complete" => {
            let city_id = payload["city_id"]
                .as_str()
                .ok_or_else(|| AppError::Invalid("event payload".into()))?;
            let building = payload["building"].as_str().unwrap_or("");
            let level = payload["level"].as_i64().unwrap_or(1) as i32;
            sqlx::query("INSERT INTO buildings(realm_id,city_id,kind,level) VALUES ($1,$2,$3,$4) ON CONFLICT(realm_id,city_id,kind) DO UPDATE SET level=$4")
                .bind(&engine.realm_id).bind(city_id).bind(building).bind(level).execute(&mut **tx).await.map_err(|e| AppError::Internal(e.to_string()))?;
            let city = load_city(tx, &engine.realm_id, city_id).await?;
            if building == "town_hall" {
                sqlx::query(
                    "UPDATE cities SET town_hall_level=$3 WHERE realm_id=$1 AND city_id=$2",
                )
                .bind(&engine.realm_id)
                .bind(city_id)
                .bind(level)
                .execute(&mut **tx)
                .await
                .map_err(|e| AppError::Internal(e.to_string()))?;
            }
            clear_busy(tx, &engine.realm_id, city_id).await?;
            bump_version(tx, &engine.realm_id).await?;
            delta(
                engine,
                tx,
                "building.upgraded",
                EventRouting {
                    pos: Some((city.x, city.y)),
                    aggregate_id: city_id.into(),
                    owner_player_id: Some(city.player_id.clone()),
                    private: false,
                    visible_players: vec![],
                },
                json!({"city_id":city_id,"building":building,"level":level}),
            )
            .await?;
        }
        "research_complete" => {
            let player = payload["player_id"].as_str().unwrap_or("");
            let tech = payload["tech"].as_str().unwrap_or("");
            let level = payload["level"].as_i64().unwrap_or(1) as i32;
            sqlx::query("INSERT INTO research(realm_id,player_id,tech,level) VALUES ($1,$2::uuid,$3,$4) ON CONFLICT(realm_id,player_id,tech) DO UPDATE SET level=$4")
                .bind(&engine.realm_id).bind(player).bind(tech).bind(level).execute(&mut **tx).await.map_err(|e| AppError::Internal(e.to_string()))?;
            bump_version(tx, &engine.realm_id).await?;
            delta(
                engine,
                tx,
                "research.completed",
                EventRouting {
                    pos: None,
                    aggregate_id: player.into(),
                    owner_player_id: Some(player.into()),
                    private: true,
                    visible_players: vec![player.into()],
                },
                json!({"tech":tech,"level":level}),
            )
            .await?;
        }
        "train_complete" => {
            let city_id = payload["city_id"].as_str().unwrap_or("");
            let unit = ArmyUnit {
                unit: payload["unit"].as_str().unwrap_or("").into(),
                tier: payload["tier"].as_u64().unwrap_or(1) as u32,
                count: payload["count"].as_u64().unwrap_or(0),
            };
            add_troop_list(tx, &engine.realm_id, city_id, std::slice::from_ref(&unit)).await?;
            clear_busy(tx, &engine.realm_id, city_id).await?;
            bump_version(tx, &engine.realm_id).await?;
            let city = load_city(tx, &engine.realm_id, city_id).await?;
            delta(
                engine,
                tx,
                "troops.trained",
                EventRouting {
                    pos: Some((city.x, city.y)),
                    aggregate_id: city_id.into(),
                    owner_player_id: Some(city.player_id.clone()),
                    private: true,
                    visible_players: vec![city.player_id.clone()],
                },
                json!({"unit":unit}),
            )
            .await?;
        }
        "heal_complete" => {
            let city_id = payload["city_id"].as_str().unwrap_or("");
            let unit = ArmyUnit {
                unit: payload["unit"].as_str().unwrap_or("").into(),
                tier: payload["tier"].as_u64().unwrap_or(1) as u32,
                count: payload["count"].as_u64().unwrap_or(0),
            };
            let n = unit.count as i64;
            sqlx::query("UPDATE troops SET count=count+$3 WHERE realm_id=$1 AND city_id=$2 AND unit=$4 AND tier=$5")
                .bind(&engine.realm_id).bind(city_id).bind(n).bind(&unit.unit).bind(unit.tier as i32)
                .execute(&mut **tx).await.map_err(|e| AppError::Internal(e.to_string()))?;
            sqlx::query("UPDATE troops SET wounded=GREATEST(wounded-$3,0) WHERE realm_id=$1 AND city_id=$2 AND unit=$4 AND tier=$5")
                .bind(&engine.realm_id).bind(city_id).bind(n).bind(&unit.unit).bind(unit.tier as i32)
                .execute(&mut **tx).await.map_err(|e| AppError::Internal(e.to_string()))?;
            clear_busy(tx, &engine.realm_id, city_id).await?;
            bump_version(tx, &engine.realm_id).await?;
        }
        "march_arrival" => resolve_arrival(engine, tx, payload).await?,
        "gather_complete" => resolve_gather(engine, tx, payload).await?,
        "march_return" => resolve_return(engine, tx, payload).await?,
        "monster_respawn" => {
            let id = payload["entity_id"].as_str().unwrap_or("");
            sqlx::query("UPDATE entity_state SET hp=(level*100),respawn_at_ms=0 WHERE realm_id=$1 AND id=$2")
                .bind(&engine.realm_id).bind(id).execute(&mut **tx).await.map_err(|e| AppError::Internal(e.to_string()))?;
            delta(
                engine,
                tx,
                "entity.respawned",
                EventRouting {
                    pos: None,
                    aggregate_id: id.into(),
                    private: false,
                    visible_players: vec![],
                    owner_player_id: None,
                },
                json!({"entity_id":id}),
            )
            .await?;
        }
        "node_replenish" => {
            let id = payload["entity_id"].as_str().unwrap_or("");
            sqlx::query("UPDATE entity_state SET stock=(level*5000),respawn_at_ms=0 WHERE realm_id=$1 AND id=$2")
                .bind(&engine.realm_id).bind(id).execute(&mut **tx).await.map_err(|e| AppError::Internal(e.to_string()))?;
            delta(
                engine,
                tx,
                "entity.replenished",
                EventRouting {
                    pos: None,
                    aggregate_id: id.into(),
                    private: false,
                    visible_players: vec![],
                    owner_player_id: None,
                },
                json!({"entity_id":id}),
            )
            .await?;
        }
        "monster_spawn" => {
            let seq = payload["seq"].as_u64().unwrap_or(0);
            let (seed,): (i64,) = sqlx::query_as("SELECT seed FROM realm_state WHERE realm_id=$1")
                .bind(&engine.realm_id)
                .fetch_one(&mut **tx)
                .await
                .map_err(|e| AppError::Internal(e.to_string()))?;
            // Deterministic but ever-changing candidate: 16 tries give the
            // spawner room to find free, passable ground.
            let mut placed = false;
            for attempt in 0..16u64 {
                let h = world::mix64(seed as u64 ^ (seq * 0x9E37_79B9_7F4A_7C15) ^ attempt);
                let x = ((h % 1900) as i32) - 950;
                let y = (((h >> 32) % 1900) as i32) - 950;
                if !world::terrain(seed as u64, x, y).passable() {
                    continue;
                }
                let occupied: (i64,) = sqlx::query_as(
                    "SELECT (SELECT count(*) FROM entity_state WHERE realm_id=$1 AND abs(x-$2)<=3 AND abs(y-$3)<=3) + (SELECT count(*) FROM cities WHERE realm_id=$1 AND abs(x-$2)<=5 AND abs(y-$3)<=5)",
                )
                .bind(&engine.realm_id)
                .bind(x)
                .bind(y)
                .fetch_one(&mut **tx)
                .await
                .map_err(|e| AppError::Internal(e.to_string()))?;
                if occupied.0 > 0 {
                    continue;
                }
                // Stronger monsters appear farther from the world centre.
                let distance = x.unsigned_abs().max(y.unsigned_abs());
                let level = 1 + (distance / 160).min(9) as i32;
                let id = format!("monster:{x}:{y}");
                sqlx::query("INSERT INTO entity_state(realm_id,id,kind,x,y,level,subtype,stock,hp,owner_player_id) VALUES ($1,$2,'monster',$3,$4,$5,'monster',0,$6,NULL) ON CONFLICT DO NOTHING")
                    .bind(&engine.realm_id)
                    .bind(&id)
                    .bind(x)
                    .bind(y)
                    .bind(level)
                    .bind(level * 100)
                    .execute(&mut **tx)
                    .await
                    .map_err(|e| AppError::Internal(e.to_string()))?;
                delta(
                    engine,
                    tx,
                    "monster.spawned",
                    EventRouting {
                        pos: Some((x, y)),
                        aggregate_id: id.clone(),
                        owner_player_id: None,
                        ..Default::default()
                    },
                    json!({"entity_id":id,"x":x,"y":y,"level":level}),
                )
                .await?;
                placed = true;
                break;
            }
            let _ = placed;
            let now = engine
                .now_ms(tx)
                .await
                .map_err(|e| AppError::Internal(e.to_string()))?;
            engine
                .schedule(
                    tx,
                    now + 15 * 60 * 1_000_000,
                    250,
                    "monster_spawn",
                    json!({"seq": seq + 1}),
                )
                .await
                .map_err(|e| AppError::Internal(e.to_string()))?;
        }
        "rally_launch" => resolve_rally(engine, tx, payload).await?,
        other => return Err(AppError::Invalid(format!("unknown event {other}"))),
    }
    Ok(())
}

/// Launch or cancel a rally once its departure time arrives.
pub async fn resolve_rally(
    engine: &Engine,
    tx: &mut Transaction<'_, Postgres>,
    payload: &Value,
) -> AppResult<()> {
    let rally_id = payload["rally_id"]
        .as_str()
        .ok_or_else(|| AppError::Invalid("rally".into()))?;
    let row: Option<(String, String, String, i32, i32, String)> = sqlx::query_as("SELECT leader_id,from_city_id,state,to_x,to_y,target_id FROM rallies WHERE realm_id=$1 AND rally_id=$2")
        .bind(&engine.realm_id).bind(rally_id).fetch_optional(&mut **tx).await.map_err(|e| AppError::Internal(e.to_string()))?;
    let (leader, from_city, state, x, y, target) =
        row.ok_or_else(|| AppError::NotFound("rally not found".into()))?;
    if state != "forming" {
        return Ok(());
    }
    sqlx::query("UPDATE rallies SET state='launched' WHERE realm_id=$1 AND rally_id=$2")
        .bind(&engine.realm_id)
        .bind(rally_id)
        .execute(&mut **tx)
        .await
        .map_err(|e| AppError::Internal(e.to_string()))?;
    let members: Vec<(String, Value)> = sqlx::query_as(
        "SELECT player_id::text,troops FROM rally_members WHERE realm_id=$1 AND rally_id=$2",
    )
    .bind(&engine.realm_id)
    .bind(rally_id)
    .fetch_all(&mut **tx)
    .await
    .map_err(|e| AppError::Internal(e.to_string()))?;
    let mut combined: Vec<ArmyUnit> = Vec::new();
    for (_, troops) in &members {
        let units: Vec<ArmyUnit> = serde_json::from_value(troops.clone()).unwrap_or_default();
        for u in units {
            if let Some(e) = combined
                .iter_mut()
                .find(|e| e.unit == u.unit && e.tier == u.tier)
            {
                e.count += u.count;
            } else {
                combined.push(u);
            }
        }
    }
    if combined.is_empty() {
        // No participants: return leader's reserved troops (none) and close.
        return Ok(());
    }
    // Member troops were already reserved atomically at rally_join; build the
    // march from those reservations without debiting them a second time.
    let from = load_city(tx, &engine.realm_id, &from_city).await?;
    let mods = modifiers_for(tx, &engine.realm_id, &leader, &from_city).await?;
    let speed = march_speed(&combined, &mods);
    let plan = MarchPlan {
        from_city: from,
        to: (x, y),
        target_id: target,
        units: combined,
        speed,
        mods,
    };
    dispatch_march(
        engine,
        tx,
        &leader,
        plan,
        "rally_attack",
        ResVec::default(),
        "",
        "attack_fort",
        false,
    )
    .await?;
    Ok(())
}

/// Apply the effects of a march reaching its destination.
pub async fn resolve_arrival(
    engine: &Engine,
    tx: &mut Transaction<'_, Postgres>,
    payload: &Value,
) -> AppResult<()> {
    let march_id = payload["march_id"]
        .as_str()
        .ok_or_else(|| AppError::Invalid("march".into()))?;
    let kind = payload["kind"].as_str().unwrap_or("");
    let row: Option<(String, String, String, String, i32, i32, Value, Value, i64, i32, i32, String)> = sqlx::query_as(
        "SELECT player_id::text,state,mission,target_id,to_x,to_y,troops,resources,depart_at_ms,from_x,from_y,hero FROM marches WHERE realm_id=$1 AND id=$2",
    ).bind(&engine.realm_id).bind(march_id).fetch_optional(&mut **tx).await.map_err(|e| AppError::Internal(e.to_string()))?;
    let (player, state, mission, target_id, tx_, ty, troops_json, cargo_json, depart, fx, fy, hero) =
        row.ok_or_else(|| AppError::NotFound("march missing".into()))?;
    if state != "traveling" {
        return Ok(());
    }
    let mut units: Vec<ArmyUnit> = serde_json::from_value(troops_json).unwrap_or_default();
    let cargo: ResVec = serde_json::from_value(cargo_json).unwrap_or_default();
    let now = engine
        .now_ms(tx)
        .await
        .map_err(|e| AppError::Internal(e.to_string()))?;
    let attacker_hero_level = if hero.is_empty() {
        0
    } else {
        sqlx::query_as::<_, (i32,)>("SELECT COALESCE((SELECT level FROM heroes WHERE realm_id=$1 AND player_id=$2::uuid AND hero_key=$3 AND assignment=$4),0)")
            .bind(&engine.realm_id)
            .bind(&player)
            .bind(&hero)
            .bind(march_id)
            .fetch_one(&mut **tx)
            .await
            .map_err(|e| AppError::Internal(e.to_string()))?.0
    };

    match kind {
        "scout" => {
            let nearby: Vec<(i32, i32)> = sqlx::query_as(
                "SELECT x,y FROM cities WHERE realm_id=$1 AND x BETWEEN $2-10 AND $2+10 AND y BETWEEN $3-10 AND $3+10 LIMIT 50",
            )
            .bind(&engine.realm_id)
            .bind(tx_)
            .bind(ty)
            .fetch_all(&mut **tx)
            .await
            .unwrap_or_default();
            let reports: Vec<(i32, i32, String)> = nearby
                .iter()
                .map(|&(x, y)| (x, y, world::terrain(engine.seed, x, y).key().to_string()))
                .collect();
            let scout_city: Option<(String,)> = sqlx::query_as(
                "SELECT city_id FROM cities WHERE realm_id=$1 AND x=$2 AND y=$3 LIMIT 1",
            )
            .bind(&engine.realm_id)
            .bind(tx_)
            .bind(ty)
            .fetch_optional(&mut **tx)
            .await
            .map_err(|e| AppError::Internal(e.to_string()))?;
            let scout_target = if target_id.is_empty() {
                scout_city.map(|c| c.0).unwrap_or_default()
            } else {
                target_id.clone()
            };
            engine
                .report(
                    tx,
                    "scout",
                    vec![player.clone()],
                    json!({"target":[tx_,ty],"nearby":reports,"target_city_id":scout_target}),
                )
                .await
                .map_err(|e| AppError::Internal(e.to_string()))?;
            // Scouting reveals a 3x3 chunk area around the target.
            let cx = tx_.div_euclid(32);
            let cy = ty.div_euclid(32);
            for dx in -1..=1 {
                for dy in -1..=1 {
                    sqlx::query(
                        "INSERT INTO player_scouting(realm_id,player_id,chunk_x,chunk_y,scouted_at_ms)
                         VALUES ($1,$2::uuid,$3,$4,$5) ON CONFLICT DO NOTHING",
                    )
                    .bind(&engine.realm_id)
                    .bind(&player)
                    .bind(cx + dx)
                    .bind(cy + dy)
                    .bind(now)
                    .execute(&mut **tx)
                    .await
                    .map_err(|e| AppError::Internal(e.to_string()))?;
                }
            }
            delta(
                engine,
                tx,
                "fog.revealed",
                EventRouting {
                    pos: Some((tx_, ty)),
                    aggregate_id: player.clone(),
                    owner_player_id: Some(player.clone()),
                    private: true,
                    visible_players: vec![player.clone()],
                },
                json!({"chunks":[[cx,cy]]}),
            )
            .await?;
        }
        "monster" => {
            let m: Option<(i32, i64, String)> = sqlx::query_as(
                "SELECT level,hp,subtype FROM entity_state WHERE realm_id=$1 AND id=$2",
            )
            .bind(&engine.realm_id)
            .bind(&target_id)
            .fetch_optional(&mut **tx)
            .await
            .map_err(|e| AppError::Internal(e.to_string()))?;
            if let Some((level, hp, _)) = m {
                if hp > 0 {
                    let def_units = vec![ArmyUnit {
                        unit: "monster".into(),
                        tier: level as u32,
                        count: (hp / 10).max(1) as u64,
                    }];
                    let input = CombatInput {
                        attackers: units.clone(),
                        defenders: def_units,
                        attacker_attack_permille: 1000,
                        attacker_defense_permille: 1000,
                        defender_attack_permille: 900 + level as i64 * 40,
                        defender_defense_permille: 900 + level as i64 * 50,
                        wall_level: 0,
                        terrain_defense_permille: 0,
                        attacker_hero_level,
                        defender_hero_level: 0,
                        defender_resources: ResVec::default(),
                        seed: now as u64 ^ (march_id.len() as u64),
                    };
                    let outcome = sim::resolve(&input);
                    units = sim::survivors(&units, &outcome.attacker_losses);
                    if outcome.attacker_won {
                        let loot = ResVec {
                            food: level as i64 * 1000,
                            wood: level as i64 * 1000,
                            stone: level as i64 * 600,
                            iron: level as i64 * 300,
                            gold: level as i64 * 400,
                        };
                        sqlx::query("UPDATE marches SET resources=$3 WHERE realm_id=$1 AND id=$2")
                            .bind(&engine.realm_id)
                            .bind(march_id)
                            .bind(serde_json::to_value(loot)?)
                            .execute(&mut **tx)
                            .await
                            .map_err(|e| AppError::Internal(e.to_string()))?;
                        let respawn = now + (level as i64 * 60_000).max(30_000);
                        sqlx::query("UPDATE entity_state SET hp=0,respawn_at_ms=$3 WHERE realm_id=$1 AND id=$2")
                            .bind(&engine.realm_id).bind(&target_id).bind(respawn).execute(&mut **tx).await.map_err(|e| AppError::Internal(e.to_string()))?;
                        engine
                            .schedule(
                                tx,
                                respawn,
                                400,
                                "monster_respawn",
                                json!({"entity_id":target_id}),
                            )
                            .await
                            .map_err(|e| AppError::Internal(e.to_string()))?;
                        bump_score(tx, &engine.realm_id, &player, None, level as i64 * 10).await?;
                    }
                    engine
                        .report(
                            tx,
                            "pve",
                            vec![player.clone()],
                            serde_json::to_value(&outcome)?,
                        )
                        .await
                        .map_err(|e| AppError::Internal(e.to_string()))?;
                }
            }
        }
        "gather" => {
            let node: Option<(i64, String)> = sqlx::query_as(
                "SELECT stock,subtype FROM entity_state WHERE realm_id=$1 AND id=$2",
            )
            .bind(&engine.realm_id)
            .bind(&target_id)
            .fetch_optional(&mut **tx)
            .await
            .map_err(|e| AppError::Internal(e.to_string()))?;
            if let Some((stock, _)) = node {
                if stock > 0 {
                    let carry: i64 = units
                        .iter()
                        .map(|u| {
                            content::unit(&u.unit, u.tier).map(|d| d.carry).unwrap_or(0)
                                * u.count as i64
                        })
                        .sum();
                    let gather_ms = 30_000i64;
                    engine
                        .schedule(
                            tx,
                            now + gather_ms,
                            250,
                            "gather_complete",
                            json!({"march_id":march_id,"entity_id":target_id,"carry":carry}),
                        )
                        .await
                        .map_err(|e| AppError::Internal(e.to_string()))?;
                    sqlx::query("UPDATE marches SET state='gathering',version=version+1 WHERE realm_id=$1 AND id=$2")
                        .bind(&engine.realm_id).bind(march_id).execute(&mut **tx).await.map_err(|e| AppError::Internal(e.to_string()))?;
                    sqlx::query(
                        "UPDATE scheduled_events SET status='done' WHERE realm_id=$1 AND id=$2",
                    )
                    .bind(&engine.realm_id)
                    .bind(
                        payload
                            .get("_event_id")
                            .and_then(|v| v.as_str())
                            .unwrap_or(""),
                    )
                    .execute(&mut **tx)
                    .await
                    .map_err(|e| AppError::Internal(e.to_string()))?;
                    return Ok(());
                }
            }
        }
        "attack_city" | "attack_fort" | "rally_attack" => {
            resolve_attack(
                engine, tx, march_id, &player, &hero, &target_id, &mut units, now,
            )
            .await?;
        }
        "reinforce" => {
            add_troop_list(tx, &engine.realm_id, &target_id, &units).await?;
            sqlx::query("UPDATE marches SET state='completed',version=version+1 WHERE realm_id=$1 AND id=$2")
                .bind(&engine.realm_id).bind(march_id).execute(&mut **tx).await.map_err(|e| AppError::Internal(e.to_string()))?;
            return Ok(());
        }
        "transport" => {
            credit(tx, &engine.realm_id, &target_id, cargo).await?;
            sqlx::query("UPDATE marches SET state='completed',version=version+1 WHERE realm_id=$1 AND id=$2")
                .bind(&engine.realm_id).bind(march_id).execute(&mut **tx).await.map_err(|e| AppError::Internal(e.to_string()))?;
            return Ok(());
        }
        _ => {}
    }
    let return_ms = (distance((fx, fy), (tx_, ty)) * 3_600_000 / 120).max(2000);
    sqlx::query("UPDATE marches SET state='returning',troops=$3,return_at_ms=$4,version=version+1 WHERE realm_id=$1 AND id=$2")
        .bind(&engine.realm_id).bind(march_id).bind(serde_json::to_value(&units)?).bind(now + return_ms)
        .execute(&mut **tx).await.map_err(|e| AppError::Internal(e.to_string()))?;
    engine
        .schedule(
            tx,
            now + return_ms,
            300,
            "march_return",
            json!({"march_id":march_id}),
        )
        .await
        .map_err(|e| AppError::Internal(e.to_string()))?;
    let _ = (mission, depart);
    Ok(())
}
