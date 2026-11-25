//! City establishment, construction, research, training, item use and market trade.
//!
//! Split out of `commands.rs`; shared helpers live in the parent module.
use super::*;

async fn capital_row(
    tx: &mut Transaction<'_, Postgres>,
    realm: &str,
    player: &str,
) -> AppResult<CityRow> {
    owned_cities(tx, realm, player)
        .await?
        .into_iter()
        .find(|c| c.is_capital)
        .ok_or(AppError::NoTarget)
}

/// Found a new city for a player within their city limit.
pub async fn create_city(
    engine: &Engine,
    tx: &mut Transaction<'_, Postgres>,
    player: &str,
    cmd: &kd_proto::CreateCityCmd,
) -> AppResult<()> {
    let pos = cmd
        .pos
        .as_ref()
        .ok_or_else(|| AppError::Invalid("position required".into()))?;
    if pos.x.unsigned_abs() > 1024 || pos.y.unsigned_abs() > 1024 {
        return Err(AppError::Invalid("out of bounds".into()));
    }
    let terrain = world::terrain(engine.seed, pos.x, pos.y);
    if !terrain.passable() {
        return Err(AppError::Invalid(format!(
            "cannot build on {}",
            terrain.key()
        )));
    }
    let count: (i64,) =
        sqlx::query_as("SELECT count(*) FROM cities WHERE realm_id=$1 AND player_id=$2::uuid")
            .bind(&engine.realm_id)
            .bind(player)
            .fetch_one(&mut **tx)
            .await
            .map_err(|e| AppError::Internal(e.to_string()))?;
    if count.0 as usize >= content::MAX_CITIES_PER_PLAYER {
        return Err(AppError::Conflict("city cap reached".into()));
    }
    if cmd.name.trim().is_empty() || cmd.name.len() > 40 {
        return Err(AppError::Invalid("invalid name".into()));
    }
    let city_id = kd_domain::new_id();
    let now = engine
        .now_ms(tx)
        .await
        .map_err(|e| AppError::Internal(e.to_string()))?;
    sqlx::query(
        "INSERT INTO cities(realm_id,city_id,player_id,name,x,y,is_capital,last_accrued_ms) VALUES ($1,$2,$3::uuid,$4,$5,$6,$7,$8)",
    ).bind(&engine.realm_id).bind(&city_id).bind(player).bind(cmd.name.trim())
     .bind(pos.x).bind(pos.y).bind(count.0 == 0).bind(now)
     .execute(&mut **tx).await.map_err(|_e| AppError::Conflict("tile already occupied".into()))?;
    sqlx::query("INSERT INTO buildings(realm_id,city_id,kind,level) VALUES ($1,$2,'town_hall',1)")
        .bind(&engine.realm_id)
        .bind(&city_id)
        .execute(&mut **tx)
        .await
        .map_err(|e| AppError::Internal(e.to_string()))?;
    if count.0 == 0 {
        sqlx::query(
            "UPDATE players SET capital_city_id=$2 WHERE realm_id=$1 AND player_id=$3::uuid",
        )
        .bind(&engine.realm_id)
        .bind(&city_id)
        .bind(player)
        .execute(&mut **tx)
        .await
        .map_err(|e| AppError::Internal(e.to_string()))?;
    }
    bump_version(tx, &engine.realm_id).await?;
    delta(
        engine,
        tx,
        "city.created",
        EventRouting {
            pos: Some((pos.x, pos.y)),
            aggregate_id: city_id.clone(),
            owner_player_id: Some(player.into()),
            private: false,
            visible_players: vec![],
        },
        json!({"city_id":city_id,"x":pos.x,"y":pos.y,"name":cmd.name}),
    )
    .await?;
    engine
        .report(
            tx,
            "city",
            vec![player.into()],
            json!({"action":"created","city_id":city_id,"pos":(pos.x,pos.y)}),
        )
        .await
        .map_err(|e| AppError::Internal(e.to_string()))?;
    Ok(())
}

/// Start or complete a building upgrade for one plot.
pub async fn upgrade_building(
    engine: &Engine,
    tx: &mut Transaction<'_, Postgres>,
    player: &str,
    cmd: &kd_proto::UpgradeBuildingCmd,
) -> AppResult<()> {
    accrue_city(engine, tx, &cmd.city_id).await?;
    let city = load_city(tx, &engine.realm_id, &cmd.city_id).await?;
    if city.player_id != player {
        return Err(AppError::Forbidden("not your city".into()));
    }
    let now = engine
        .now_ms(tx)
        .await
        .map_err(|e| AppError::Internal(e.to_string()))?;
    if city.busy_until_ms > now {
        return Err(AppError::QueueFull("construction queue busy".into()));
    }
    let bmap = buildings(tx, &engine.realm_id, &cmd.city_id).await?;
    let cur = *bmap.get(&cmd.building).unwrap_or(&0);
    let def = content::building(&cmd.building)
        .ok_or_else(|| AppError::Invalid("unknown building".into()))?;
    if cur >= content::MAX_CITY_LEVEL {
        return Err(AppError::Prerequisite("max level".into()));
    }
    if let Some((preq, lv)) = def.requires {
        let actual = if content::building(preq).is_some() {
            *bmap.get(preq).unwrap_or(&0)
        } else {
            let r = research(tx, &engine.realm_id, player).await?;
            *r.get(preq).unwrap_or(&0)
        };
        if actual < lv {
            return Err(AppError::Prerequisite(format!("requires {preq} {lv}")));
        }
    }
    let cost = content::building_cost(&cmd.building, cur + 1)
        .ok_or_else(|| AppError::Invalid("bad level".into()))?;
    debit(tx, &engine.realm_id, &city, cost).await?;
    let m = modifiers_for(tx, &engine.realm_id, player, &cmd.city_id).await?;
    let secs = content::building_time(&cmd.building, cur + 1).unwrap_or(60) * 1000 * 1000
        / m.training_speed_permille.max(1);
    let due = now + secs;
    mark_busy(tx, &engine.realm_id, &cmd.city_id, due, "", "building").await?;
    engine
        .schedule(
            tx,
            due,
            100,
            "build_complete",
            json!({"city_id":cmd.city_id,"building":cmd.building,"level":cur+1}),
        )
        .await
        .map_err(|e| AppError::Internal(e.to_string()))?;
    bump_version(tx, &engine.realm_id).await?;
    delta(
        engine,
        tx,
        "queue.started",
        EventRouting {
            pos: Some((city.x, city.y)),
            aggregate_id: cmd.city_id.clone(),
            owner_player_id: Some(player.into()),
            private: true,
            visible_players: vec![player.into()],
        },
        json!({"kind":"building","until_ms":due,"target":cmd.building}),
    )
    .await?;
    Ok(())
}

/// Begin researching a technology in the single scholar queue.
pub async fn start_research(
    engine: &Engine,
    tx: &mut Transaction<'_, Postgres>,
    player: &str,
    cmd: &kd_proto::StartResearchCmd,
) -> AppResult<()> {
    let cities = owned_cities(tx, &engine.realm_id, player).await?;
    let capital = cities
        .iter()
        .find(|c| c.is_capital)
        .ok_or(AppError::NoTarget)?;
    accrue_city(engine, tx, &capital.city_id).await?;
    let now = engine
        .now_ms(tx)
        .await
        .map_err(|e| AppError::Internal(e.to_string()))?;
    let busy: (i64,) = sqlx::query_as("SELECT count(*) FROM scheduled_events WHERE realm_id=$1 AND kind='research_complete' AND status='pending' AND payload->>'player_id'=$2")
        .bind(&engine.realm_id).bind(player).fetch_one(&mut **tx).await.map_err(|e| AppError::Internal(e.to_string()))?;
    if busy.0 > 0 {
        return Err(AppError::QueueFull("research queue busy".into()));
    }
    let rmap = research(tx, &engine.realm_id, player).await?;
    let cur = *rmap.get(&cmd.tech).unwrap_or(&0);
    if cur >= 3 {
        return Err(AppError::Prerequisite("max research level".into()));
    }
    let def = content::tech(&cmd.tech).ok_or_else(|| AppError::Invalid("unknown tech".into()))?;
    if let Some((preq, lv)) = def.requires {
        let have = if content::building(preq).is_some() {
            let bmap = buildings(tx, &engine.realm_id, &capital.city_id).await?;
            *bmap.get(preq).unwrap_or(&0)
        } else {
            *rmap.get(preq).unwrap_or(&0)
        };
        if have < lv {
            return Err(AppError::Prerequisite(format!("requires {preq} {lv}")));
        }
    }
    let academy = {
        let b = buildings(tx, &engine.realm_id, &capital.city_id).await?;
        *b.get("academy").unwrap_or(&0)
    };
    let next = cur + 1;
    if next > 1 && academy < (next - 1) * 2 {
        return Err(AppError::Prerequisite("academy level too low".into()));
    }
    let cost = content::tech_cost(&cmd.tech, next)
        .ok_or_else(|| AppError::Invalid("bad tech level".into()))?;
    let city = load_city(tx, &engine.realm_id, &capital.city_id).await?;
    debit(tx, &engine.realm_id, &city, cost).await?;
    let secs = content::tech_time(&cmd.tech, next).unwrap_or(60) * 1000;
    let due = now + secs;
    engine
        .schedule(
            tx,
            due,
            100,
            "research_complete",
            json!({"player_id":player,"tech":cmd.tech,"level":next}),
        )
        .await
        .map_err(|e| AppError::Internal(e.to_string()))?;
    bump_version(tx, &engine.realm_id).await?;
    delta(
        engine,
        tx,
        "queue.started",
        EventRouting {
            pos: None,
            aggregate_id: player.into(),
            owner_player_id: Some(player.into()),
            private: true,
            visible_players: vec![player.into()],
        },
        json!({"kind":"research","until_ms":due,"target":cmd.tech}),
    )
    .await?;
    Ok(())
}

/// Enqueue a unit training order and debit its resource cost.
pub async fn train_troops(
    engine: &Engine,
    tx: &mut Transaction<'_, Postgres>,
    player: &str,
    cmd: &kd_proto::TrainTroopsCmd,
) -> AppResult<()> {
    accrue_city(engine, tx, &cmd.city_id).await?;
    let city = load_city(tx, &engine.realm_id, &cmd.city_id).await?;
    if city.player_id != player {
        return Err(AppError::Forbidden("not your city".into()));
    }
    let now = engine
        .now_ms(tx)
        .await
        .map_err(|e| AppError::Internal(e.to_string()))?;
    if city.busy_until_ms > now {
        return Err(AppError::QueueFull("training queue busy".into()));
    }
    if cmd.count == 0 || cmd.count > 100_000 {
        return Err(AppError::Invalid("invalid count".into()));
    }
    let unit = content::unit(&cmd.unit, cmd.tier)
        .ok_or_else(|| AppError::Invalid("unknown unit".into()))?;
    let bmap = buildings(tx, &engine.realm_id, &cmd.city_id).await?;
    let barracks = *bmap.get("barracks").unwrap_or(&0);
    if barracks < unit.unlock_barracks {
        return Err(AppError::Prerequisite(format!(
            "barracks {}",
            unit.unlock_barracks
        )));
    }
    let stack = ArmyUnit {
        unit: cmd.unit.clone(),
        tier: cmd.tier,
        count: cmd.count as u64,
    };
    if army_count(&load_troops(tx, &engine.realm_id, &cmd.city_id).await?) + stack.count > 2_000_000
    {
        return Err(AppError::Invalid("troop cap".into()));
    }
    let cost = army_cost(std::slice::from_ref(&stack))?;
    debit(tx, &engine.realm_id, &city, cost).await?;
    let m = modifiers_for(tx, &engine.realm_id, player, &cmd.city_id).await?;
    let secs = (unit.train_secs * cmd.count as i64 * 1000 * 1000
        / m.training_speed_permille.max(1))
    .max(1000);
    let due = now + secs;
    mark_busy(tx, &engine.realm_id, &cmd.city_id, due, "", "training").await?;
    engine
        .schedule(
            tx,
            due,
            100,
            "train_complete",
            json!({"city_id":cmd.city_id,"unit":cmd.unit,"tier":cmd.tier,"count":cmd.count}),
        )
        .await
        .map_err(|e| AppError::Internal(e.to_string()))?;
    bump_version(tx, &engine.realm_id).await?;
    Ok(())
}

/// Move wounded units through the hospital queue.
pub async fn heal_troops(
    engine: &Engine,
    tx: &mut Transaction<'_, Postgres>,
    player: &str,
    cmd: &kd_proto::HealTroopsCmd,
) -> AppResult<()> {
    accrue_city(engine, tx, &cmd.city_id).await?;
    let city = load_city(tx, &engine.realm_id, &cmd.city_id).await?;
    if city.player_id != player {
        return Err(AppError::Forbidden("not your city".into()));
    }
    let now = engine
        .now_ms(tx)
        .await
        .map_err(|e| AppError::Internal(e.to_string()))?;
    if city.busy_until_ms > now {
        return Err(AppError::QueueFull("hospital busy".into()));
    }
    let rows: Vec<(i64,)> = sqlx::query_as(
        "SELECT wounded FROM troops WHERE realm_id=$1 AND city_id=$2 AND unit=$3 AND tier=$4",
    )
    .bind(&engine.realm_id)
    .bind(&cmd.city_id)
    .bind(&cmd.unit)
    .bind(cmd.tier as i32)
    .fetch_all(&mut **tx)
    .await
    .map_err(|e| AppError::Internal(e.to_string()))?;
    let available: i64 = rows.iter().map(|r| r.0).sum();
    if available < cmd.count as i64 || cmd.count == 0 {
        return Err(AppError::InsufficientTroops("not enough wounded".into()));
    }
    let cost = ResVec {
        food: cmd.count as i64 * 2,
        wood: 0,
        stone: 0,
        iron: 0,
        gold: cmd.count as i64,
    };
    debit(tx, &engine.realm_id, &city, cost).await?;
    let due = now + (cmd.count as i64 * 1000).max(1000);
    mark_busy(tx, &engine.realm_id, &cmd.city_id, due, "", "healing").await?;
    engine
        .schedule(
            tx,
            due,
            100,
            "heal_complete",
            json!({"city_id":cmd.city_id,"unit":cmd.unit,"tier":cmd.tier,"count":cmd.count}),
        )
        .await
        .map_err(|e| AppError::Internal(e.to_string()))?;
    bump_version(tx, &engine.realm_id).await?;
    Ok(())
}

/// Consume an item and apply its effect to the player or city.
pub async fn use_item(
    engine: &Engine,
    tx: &mut Transaction<'_, Postgres>,
    player: &str,
    cmd: &kd_proto::UseItemCmd,
) -> AppResult<()> {
    let def = content::item(&cmd.item).ok_or_else(|| AppError::Invalid("unknown item".into()))?;
    if item_qty(tx, &engine.realm_id, player, &cmd.item).await? < 1 {
        return Err(AppError::InsufficientResources("no such item".into()));
    }
    let now = engine
        .now_ms(tx)
        .await
        .map_err(|e| AppError::Internal(e.to_string()))?;
    if def.shield_hours > 0 {
        let cities = owned_cities(tx, &engine.realm_id, player).await?;
        let capital = cities
            .iter()
            .find(|c| c.is_capital)
            .ok_or(AppError::NoTarget)?;
        sqlx::query("UPDATE cities SET shield_until_ms=GREATEST(shield_until_ms,$3)+$4 WHERE realm_id=$1 AND player_id=$2::uuid")
            .bind(&engine.realm_id).bind(player).bind(now).bind(def.shield_hours * 3_600_000)
            .execute(&mut **tx).await.map_err(|e| AppError::Internal(e.to_string()))?;
        let _ = capital;
    } else if def.speedup_secs > 0 {
        let target = cmd.target_city_id.as_str();
        if target.is_empty() {
            return Err(AppError::Invalid("target_city_id required".into()));
        }
        let ev: Option<(String, i64, String)> = sqlx::query_as(
            "SELECT e.id::text,e.due_at_ms,e.kind FROM scheduled_events e WHERE e.realm_id=$1 AND e.status='pending' AND ((e.kind IN ('build_complete','train_complete','heal_complete') AND e.payload->>'city_id'=$2 AND EXISTS(SELECT 1 FROM cities c WHERE c.realm_id=e.realm_id AND c.city_id=$2 AND c.player_id=$3::uuid)) OR (e.kind='research_complete' AND e.payload->>'player_id'=$3 AND $2='research')) ORDER BY e.due_at_ms LIMIT 1",
        )
        .bind(&engine.realm_id)
        .bind(target)
        .bind(player)
        .fetch_optional(&mut **tx)
        .await
        .map_err(|e| AppError::Internal(e.to_string()))?;
        let (id, due, kind) =
            ev.ok_or_else(|| AppError::NotFound("no active queue for that city".into()))?;
        let new_due = kd_domain::economy::apply_speedup(due - now, def.speedup_secs * 1000) + now;
        sqlx::query("UPDATE scheduled_events SET due_at_ms=$2 WHERE realm_id=$1 AND id=$3::uuid")
            .bind(&engine.realm_id)
            .bind(new_due)
            .bind(id)
            .execute(&mut **tx)
            .await
            .map_err(|e| AppError::Internal(e.to_string()))?;
        if kind != "research_complete" {
            sqlx::query("UPDATE cities SET busy_until_ms=$3 WHERE realm_id=$1 AND city_id=$2 AND player_id=$4::uuid")
                .bind(&engine.realm_id)
                .bind(target)
                .bind(new_due)
                .bind(player)
                .execute(&mut **tx)
                .await
                .map_err(|e| AppError::Internal(e.to_string()))?;
        }
    } else if cmd.item == "scout_kit" {
        let cities = owned_cities(tx, &engine.realm_id, player).await?;
        let capital = cities
            .iter()
            .find(|c| c.is_capital)
            .ok_or(AppError::NoTarget)?;
        let (x, y): (i32, i32) =
            sqlx::query_as("SELECT x,y FROM cities WHERE realm_id=$1 AND city_id=$2")
                .bind(&engine.realm_id)
                .bind(&capital.city_id)
                .fetch_one(&mut **tx)
                .await
                .map_err(|e| AppError::Internal(e.to_string()))?;
        let cx = x.div_euclid(32);
        let cy = y.div_euclid(32);
        for dx in -1..=1 {
            for dy in -1..=1 {
                sqlx::query("INSERT INTO player_scouting(realm_id,player_id,chunk_x,chunk_y,scouted_at_ms) VALUES ($1,$2::uuid,$3,$4,$5) ON CONFLICT DO NOTHING")
                    .bind(&engine.realm_id)
                    .bind(player)
                    .bind(cx + dx)
                    .bind(cy + dy)
                    .bind(now)
                    .execute(&mut **tx)
                    .await
                    .map_err(|e| AppError::Internal(e.to_string()))?;
            }
        }
    } else {
        let cities = owned_cities(tx, &engine.realm_id, player).await?;
        let capital = cities
            .iter()
            .find(|c| c.is_capital)
            .ok_or(AppError::NoTarget)?;
        let cap_city = load_city(tx, &engine.realm_id, &capital.city_id).await?;
        credit(tx, &engine.realm_id, &capital.city_id, def.resource).await?;
        let _ = cap_city;
    }
    use_item_unit(tx, &engine.realm_id, player, &cmd.item).await?;
    bump_version(tx, &engine.realm_id).await?;
    Ok(())
}

/// Activate or extend a city peace shield.
pub async fn set_shield(
    engine: &Engine,
    tx: &mut Transaction<'_, Postgres>,
    player: &str,
    cmd: &kd_proto::SetShieldCmd,
) -> AppResult<()> {
    if cmd.hours == 0 || cmd.hours > 24 {
        return Err(AppError::Invalid("shield duration 1..24 hours".into()));
    }
    if item_qty(tx, &engine.realm_id, player, "shield_1d").await? < 1 {
        return Err(AppError::InsufficientResources("need shield item".into()));
    }
    let now = engine
        .now_ms(tx)
        .await
        .map_err(|e| AppError::Internal(e.to_string()))?;
    sqlx::query("UPDATE cities SET shield_until_ms=GREATEST(shield_until_ms,$3)+$4 WHERE realm_id=$1 AND player_id=$2::uuid")
        .bind(&engine.realm_id).bind(player).bind(now).bind(24i64 * 3_600_000)
        .execute(&mut **tx).await.map_err(|e| AppError::Internal(e.to_string()))?;
    use_item_unit(tx, &engine.realm_id, player, "shield_1d").await?;
    Ok(())
}

/// Change which city is the player's capital.
pub async fn switch_capital(
    engine: &Engine,
    tx: &mut Transaction<'_, Postgres>,
    player: &str,
    cmd: &kd_proto::SwitchCapitalCmd,
) -> AppResult<()> {
    let city = load_city(tx, &engine.realm_id, &cmd.city_id).await?;
    if city.player_id != player {
        return Err(AppError::Forbidden("not your city".into()));
    }
    sqlx::query("UPDATE cities SET is_capital=false WHERE realm_id=$1 AND player_id=$2::uuid")
        .bind(&engine.realm_id)
        .bind(player)
        .execute(&mut **tx)
        .await
        .map_err(|e| AppError::Internal(e.to_string()))?;
    sqlx::query("UPDATE cities SET is_capital=true WHERE realm_id=$1 AND city_id=$2")
        .bind(&engine.realm_id)
        .bind(&cmd.city_id)
        .execute(&mut **tx)
        .await
        .map_err(|e| AppError::Internal(e.to_string()))?;
    sqlx::query("UPDATE players SET capital_city_id=$2 WHERE realm_id=$1 AND player_id=$3::uuid")
        .bind(&engine.realm_id)
        .bind(&cmd.city_id)
        .bind(player)
        .execute(&mut **tx)
        .await
        .map_err(|e| AppError::Internal(e.to_string()))?;
    bump_version(tx, &engine.realm_id).await?;
    Ok(())
}

/// Recruit a hero using gold and record its level.
pub async fn recruit_hero(
    engine: &Engine,
    tx: &mut Transaction<'_, Postgres>,
    player: &str,
    cmd: &kd_proto::RecruitHeroCmd,
) -> AppResult<()> {
    let hero = content::hero(&cmd.hero).ok_or_else(|| AppError::Invalid("unknown hero".into()))?;
    let owned: (bool,) = sqlx::query_as(
        "SELECT EXISTS(SELECT 1 FROM heroes WHERE realm_id=$1 AND player_id=$2::uuid AND hero_key=$3)",
    )
    .bind(&engine.realm_id)
    .bind(player)
    .bind(&cmd.hero)
    .fetch_one(&mut **tx)
    .await
    .map_err(|e| AppError::Internal(e.to_string()))?;
    if owned.0 {
        return Err(AppError::Conflict("hero already recruited".into()));
    }
    let cities = owned_cities(tx, &engine.realm_id, player).await?;
    let capital = cities
        .iter()
        .find(|city| city.is_capital)
        .ok_or(AppError::NoTarget)?;
    let city = load_city(tx, &engine.realm_id, &capital.city_id).await?;
    debit(
        tx,
        &engine.realm_id,
        &city,
        ResVec {
            gold: hero.recruit_gold,
            ..ResVec::default()
        },
    )
    .await?;
    sqlx::query("INSERT INTO heroes(realm_id,player_id,hero_key,level) VALUES ($1,$2::uuid,$3,1)")
        .bind(&engine.realm_id)
        .bind(player)
        .bind(&cmd.hero)
        .execute(&mut **tx)
        .await
        .map_err(|e| AppError::Internal(e.to_string()))?;
    bump_version(tx, &engine.realm_id).await?;
    Ok(())
}

/// Remove a building and refund half of every resource spent reaching its level.
pub async fn demolish_building(
    engine: &Engine,
    tx: &mut Transaction<'_, Postgres>,
    player: &str,
    cmd: &kd_proto::DemolishBuildingCmd,
) -> AppResult<()> {
    // The town hall anchors city state; losing it would orphan queues and troops.
    if cmd.building == "town_hall" {
        return Err(AppError::Forbidden("town hall cannot be demolished".into()));
    }
    accrue_city(engine, tx, &cmd.city_id).await?;
    let city = load_city(tx, &engine.realm_id, &cmd.city_id).await?;
    if city.player_id != player {
        return Err(AppError::Forbidden("not your city".into()));
    }
    let level = *buildings(tx, &engine.realm_id, &cmd.city_id)
        .await?
        .get(&cmd.building)
        .ok_or_else(|| AppError::NotFound("building not found".into()))?;
    if level < 1 {
        return Err(AppError::NotFound("building not found".into()));
    }
    let mut refund = ResVec::default();
    for lvl in 1..=level {
        let cost = content::building_cost(&cmd.building, lvl)
            .ok_or_else(|| AppError::Invalid("bad building level".into()))?;
        refund = refund
            .add_checked(cost)
            .ok_or_else(|| AppError::Internal("refund overflow".into()))?;
    }
    refund.food /= 2;
    refund.wood /= 2;
    refund.stone /= 2;
    refund.iron /= 2;
    refund.gold /= 2;

    sqlx::query("DELETE FROM buildings WHERE realm_id=$1 AND city_id=$2 AND kind=$3")
        .bind(&engine.realm_id)
        .bind(&cmd.city_id)
        .bind(&cmd.building)
        .execute(&mut **tx)
        .await
        .map_err(|e| AppError::Internal(e.to_string()))?;
    credit(tx, &engine.realm_id, &cmd.city_id, refund).await?;
    bump_version(tx, &engine.realm_id).await?;
    delta(
        engine,
        tx,
        "building.demolished",
        EventRouting {
            pos: Some((city.x, city.y)),
            aggregate_id: cmd.city_id.clone(),
            owner_player_id: Some(player.into()),
            private: false,
            visible_players: vec![],
        },
        json!({"city_id":cmd.city_id,"building":cmd.building,"refund":refund}),
    )
    .await?;
    engine
        .report(
            tx,
            "building",
            vec![player.into()],
            json!({"action":"demolished","city_id":cmd.city_id,"building":cmd.building,"refund":refund}),
        )
        .await
        .map_err(|e| AppError::Internal(e.to_string()))?;
    Ok(())
}

/// Buy items at the catalog's fixed gold price, debiting the capital's gold.
pub async fn market_buy(
    engine: &Engine,
    tx: &mut Transaction<'_, Postgres>,
    player: &str,
    cmd: &kd_proto::MarketBuyCmd,
) -> AppResult<()> {
    if !(1..=99).contains(&cmd.qty) {
        return Err(AppError::Invalid("quantity must be 1..99".into()));
    }
    let price =
        content::item_price(&cmd.item).ok_or_else(|| AppError::Invalid("unknown item".into()))?;
    let capital = capital_row(tx, &engine.realm_id, player).await?;
    accrue_city(engine, tx, &capital.city_id).await?;
    let city = load_city(tx, &engine.realm_id, &capital.city_id).await?;
    let spent = price * cmd.qty as i64;
    debit(
        tx,
        &engine.realm_id,
        &city,
        ResVec {
            gold: spent,
            ..ResVec::default()
        },
    )
    .await?;
    sqlx::query("INSERT INTO items(realm_id,player_id,item_key,qty) VALUES ($1,$2::uuid,$3,$4) ON CONFLICT(realm_id,player_id,item_key) DO UPDATE SET qty=items.qty+EXCLUDED.qty")
        .bind(&engine.realm_id)
        .bind(player)
        .bind(&cmd.item)
        .bind(cmd.qty as i64)
        .execute(&mut **tx)
        .await
        .map_err(|e| AppError::Internal(e.to_string()))?;
    bump_version(tx, &engine.realm_id).await?;
    delta(
        engine,
        tx,
        "market.bought",
        EventRouting {
            pos: None,
            aggregate_id: player.into(),
            owner_player_id: Some(player.into()),
            private: true,
            visible_players: vec![player.into()],
        },
        json!({"item":cmd.item,"qty":cmd.qty,"gold_spent":spent}),
    )
    .await?;
    Ok(())
}

/// Sell items from inventory for half their catalog price, credited as gold.
pub async fn market_sell(
    engine: &Engine,
    tx: &mut Transaction<'_, Postgres>,
    player: &str,
    cmd: &kd_proto::MarketSellCmd,
) -> AppResult<()> {
    if !(1..=99).contains(&cmd.qty) {
        return Err(AppError::Invalid("quantity must be 1..99".into()));
    }
    let price =
        content::item_price(&cmd.item).ok_or_else(|| AppError::Invalid("unknown item".into()))?;
    if item_qty(tx, &engine.realm_id, player, &cmd.item).await? < cmd.qty as i64 {
        return Err(AppError::InsufficientResources("not enough items".into()));
    }
    let capital = capital_row(tx, &engine.realm_id, player).await?;
    accrue_city(engine, tx, &capital.city_id).await?;
    let updated = sqlx::query(
        "UPDATE items SET qty=qty-$4 WHERE realm_id=$1 AND player_id=$2::uuid AND item_key=$3",
    )
    .bind(&engine.realm_id)
    .bind(player)
    .bind(&cmd.item)
    .bind(cmd.qty as i64)
    .execute(&mut **tx)
    .await
    .map_err(|e| AppError::Internal(e.to_string()))?;
    if updated.rows_affected() != 1 {
        return Err(AppError::InsufficientResources("not enough items".into()));
    }
    let earned = price / 2 * cmd.qty as i64;
    credit(
        tx,
        &engine.realm_id,
        &capital.city_id,
        ResVec {
            gold: earned,
            ..ResVec::default()
        },
    )
    .await?;
    bump_version(tx, &engine.realm_id).await?;
    delta(
        engine,
        tx,
        "market.sold",
        EventRouting {
            pos: None,
            aggregate_id: player.into(),
            owner_player_id: Some(player.into()),
            private: true,
            visible_players: vec![player.into()],
        },
        json!({"item":cmd.item,"qty":cmd.qty,"gold_earned":earned}),
    )
    .await?;
    Ok(())
}
