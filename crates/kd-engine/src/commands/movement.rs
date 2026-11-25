//! March planning and tile/monster/city interactions.
//!
//! Split out of `commands.rs`; shared helpers live in the parent module.
use super::*;

/// Validated, computed parameters shared by all march dispatch paths.
pub struct MarchPlan {
    pub from_city: CityRow,
    pub to: (i32, i32),
    pub target_id: String,
    pub units: Vec<ArmyUnit>,
    pub speed: i64,
    pub mods: Modifiers,
}

/// Validate a march request and compute its speed and arrival time.
pub async fn plan_march(
    engine: &Engine,
    tx: &mut Transaction<'_, Postgres>,
    player: &str,
    city_id: &str,
    to: (i32, i32),
    target_id: &str,
    units: Vec<ArmyUnit>,
) -> AppResult<MarchPlan> {
    accrue_city(engine, tx, city_id).await?;
    let from_city = load_city(tx, &engine.realm_id, city_id).await?;
    if from_city.player_id != player {
        return Err(AppError::Forbidden("not your city".into()));
    }
    let have = load_troops(tx, &engine.realm_id, city_id).await?;
    for u in &units {
        let h = have
            .iter()
            .find(|x| x.unit == u.unit && x.tier == u.tier)
            .map(|x| x.count)
            .unwrap_or(0);
        if h < u.count {
            return Err(AppError::InsufficientTroops(format!(
                "not enough {}",
                u.unit
            )));
        }
    }
    let mods = modifiers_for(tx, &engine.realm_id, player, city_id).await?;
    let speed = march_speed(&units, &mods);
    Ok(MarchPlan {
        from_city,
        to,
        target_id: target_id.into(),
        units,
        speed,
        mods,
    })
}

/// Count marches currently owned by a player.
pub async fn active_march_count(
    tx: &mut Transaction<'_, Postgres>,
    realm: &str,
    player: &str,
) -> AppResult<i64> {
    let r: (i64,) = sqlx::query_as("SELECT count(*) FROM marches WHERE realm_id=$1 AND player_id=$2::uuid AND state IN ('traveling','gathering','returning')")
        .bind(realm).bind(player).fetch_one(&mut **tx).await.map_err(|e| AppError::Internal(e.to_string()))?;
    Ok(r.0)
}

// Deliberate exception: these nine values are the full command context.
#[allow(clippy::too_many_arguments)]
/// Create a march, debit its troops and schedule its arrival.
pub async fn dispatch_march(
    engine: &Engine,
    tx: &mut Transaction<'_, Postgres>,
    player: &str,
    plan: MarchPlan,
    mission: &str,
    resource_cargo: ResVec,
    hero: &str,
    kind: &str,
    reserve: bool,
) -> AppResult<String> {
    let max_marches = plan.mods.march_capacity.max(1) as i64;
    if active_march_count(tx, &engine.realm_id, player).await? >= max_marches {
        return Err(AppError::QueueFull("march slots full".into()));
    }
    let now = engine
        .now_ms(tx)
        .await
        .map_err(|e| AppError::Internal(e.to_string()))?;
    let dist = distance((plan.from_city.x, plan.from_city.y), plan.to);
    let travel_ms = (dist * 3_600_000 / plan.speed.max(1)).max(2000);
    let march_id = kd_domain::new_id();
    let route = world::route((plan.from_city.x, plan.from_city.y), plan.to, 128);
    if route
        .iter()
        .any(|&(x, y)| !world::terrain(engine.seed, x, y).passable())
    {
        return Err(AppError::Invalid("route crosses impassable terrain".into()));
    }
    let hero = if hero.is_empty() {
        sqlx::query_as::<_, (String,)>("SELECT hero_key FROM heroes WHERE realm_id=$1 AND player_id=$2::uuid AND assignment='' ORDER BY level DESC,hero_key LIMIT 1")
            .bind(&engine.realm_id)
            .bind(player)
            .fetch_optional(&mut **tx)
            .await
            .map_err(|e| AppError::Internal(e.to_string()))?
            .map(|row| row.0)
            .unwrap_or_default()
    } else {
        hero.to_string()
    };
    if !hero.is_empty() {
        let changed = sqlx::query("UPDATE heroes SET assignment=$4 WHERE realm_id=$1 AND player_id=$2::uuid AND hero_key=$3 AND assignment=''")
            .bind(&engine.realm_id).bind(player).bind(&hero).bind(&march_id)
            .execute(&mut **tx).await.map_err(|e| AppError::Internal(e.to_string()))?.rows_affected();
        if changed == 0 {
            return Err(AppError::Conflict("hero already assigned".into()));
        }
    }
    if reserve {
        apply_troop_list(tx, &engine.realm_id, &plan.from_city.city_id, &plan.units).await?;
    }
    sqlx::query(
        "INSERT INTO marches(realm_id,id,player_id,from_city_id,from_x,from_y,to_x,to_y,target_id,mission,state,troops,hero,resources,depart_at_ms,arrive_at_ms)
         VALUES ($1,$2,$3::uuid,$4,$5,$6,$7,$8,$9,$10,'traveling',$11,$12,$13,$14,$15)",
    ).bind(&engine.realm_id).bind(&march_id).bind(player).bind(&plan.from_city.city_id)
     .bind(plan.from_city.x).bind(plan.from_city.y).bind(plan.to.0).bind(plan.to.1).bind(&plan.target_id)
     .bind(mission).bind(serde_json::to_value(&plan.units)?).bind(&hero).bind(serde_json::to_value(resource_cargo)?)
     .bind(now).bind(now + travel_ms).execute(&mut **tx).await.map_err(|e| AppError::Internal(e.to_string()))?;
    engine
        .schedule(
            tx,
            now + travel_ms,
            200,
            "march_arrival",
            json!({"march_id":march_id,"kind":kind}),
        )
        .await
        .map_err(|e| AppError::Internal(e.to_string()))?;
    bump_version(tx, &engine.realm_id).await?;
    delta(engine, tx, "march.dispatched", EventRouting { pos: Some(plan.to), aggregate_id: march_id.clone(), owner_player_id: Some(player.into()), private: false, visible_players: vec![] },
        json!({"march_id":march_id,"from":[plan.from_city.x,plan.from_city.y],"to":plan.to,"mission":mission,"arrive_at_ms":now+travel_ms})).await?;
    Ok(march_id)
}

/// Reveal a map tile and schedule the scouting report.
pub async fn scout_tile(
    engine: &Engine,
    tx: &mut Transaction<'_, Postgres>,
    player: &str,
    cmd: &kd_proto::ScoutTileCmd,
) -> AppResult<()> {
    let pos = cmd
        .pos
        .as_ref()
        .ok_or_else(|| AppError::Invalid("position required".into()))?;
    let cities = owned_cities(tx, &engine.realm_id, player).await?;
    let origin = cities
        .iter()
        .find(|c| c.is_capital)
        .ok_or(AppError::NoTarget)?;
    let units = vec![ArmyUnit {
        unit: "scout".into(),
        tier: 1,
        count: 1,
    }];
    let plan = plan_march(
        engine,
        tx,
        player,
        &origin.city_id,
        (pos.x, pos.y),
        "",
        units,
    )
    .await?;
    dispatch_march(
        engine,
        tx,
        player,
        plan,
        "scout",
        ResVec::default(),
        "",
        "scout",
        true,
    )
    .await?;
    Ok(())
}

/// Launch a hunt against a static monster entity.
pub async fn attack_monster(
    engine: &Engine,
    tx: &mut Transaction<'_, Postgres>,
    player: &str,
    cmd: &kd_proto::AttackMonsterCmd,
) -> AppResult<()> {
    let ent: Option<(i32, i32, i64)> = sqlx::query_as(
        "SELECT x,y,hp FROM entity_state WHERE realm_id=$1 AND id=$2 AND kind='monster'",
    )
    .bind(&engine.realm_id)
    .bind(&cmd.monster_id)
    .fetch_optional(&mut **tx)
    .await
    .map_err(|e| AppError::Internal(e.to_string()))?;
    let (x, y, hp) = ent.ok_or_else(|| AppError::NotFound("monster not found".into()))?;
    if hp <= 0 {
        return Err(AppError::NoTarget);
    }
    let units = load_troops(tx, &engine.realm_id, &cmd.city_id).await?;
    if army_count(&units) == 0 {
        return Err(AppError::InsufficientTroops("empty garrison".into()));
    }
    let plan = plan_march(
        engine,
        tx,
        player,
        &cmd.city_id,
        (x, y),
        &cmd.monster_id,
        units,
    )
    .await?;
    dispatch_march(
        engine,
        tx,
        player,
        plan,
        "monster",
        ResVec::default(),
        "",
        "monster",
        true,
    )
    .await?;
    Ok(())
}

/// Launch a gathering march toward a resource node.
pub async fn gather(
    engine: &Engine,
    tx: &mut Transaction<'_, Postgres>,
    player: &str,
    cmd: &kd_proto::GatherCmd,
) -> AppResult<()> {
    let ent: Option<(i32, i32, i64, String)> = sqlx::query_as(
        "SELECT x,y,stock,subtype FROM entity_state WHERE realm_id=$1 AND id=$2 AND kind='node'",
    )
    .bind(&engine.realm_id)
    .bind(&cmd.node_id)
    .fetch_optional(&mut **tx)
    .await
    .map_err(|e| AppError::Internal(e.to_string()))?;
    let (x, y, stock, _) = ent.ok_or_else(|| AppError::NotFound("node not found".into()))?;
    if stock <= 0 {
        return Err(AppError::NoTarget);
    }
    let units = load_troops(tx, &engine.realm_id, &cmd.city_id).await?;
    if army_count(&units) == 0 {
        return Err(AppError::InsufficientTroops("empty garrison".into()));
    }
    let plan = plan_march(
        engine,
        tx,
        player,
        &cmd.city_id,
        (x, y),
        &cmd.node_id,
        units,
    )
    .await?;
    dispatch_march(
        engine,
        tx,
        player,
        plan,
        "gather",
        ResVec::default(),
        "",
        "gather",
        true,
    )
    .await?;
    Ok(())
}

/// Validate and classify a march target by kind and ownership.
pub async fn resolve_target(
    tx: &mut Transaction<'_, Postgres>,
    realm: &str,
    target_id: &str,
) -> AppResult<(i32, i32)> {
    let city: Option<(i32, i32)> =
        sqlx::query_as("SELECT x,y FROM cities WHERE realm_id=$1 AND city_id=$2")
            .bind(realm)
            .bind(target_id)
            .fetch_optional(&mut **tx)
            .await
            .map_err(|e| AppError::Internal(e.to_string()))?;
    if let Some(p) = city {
        return Ok(p);
    }
    let ent: Option<(i32, i32)> =
        sqlx::query_as("SELECT x,y FROM entity_state WHERE realm_id=$1 AND id=$2")
            .bind(realm)
            .bind(target_id)
            .fetch_optional(&mut **tx)
            .await
            .map_err(|e| AppError::Internal(e.to_string()))?;
    ent.ok_or_else(|| AppError::NotFound("target not found".into()))
}

/// Launch a PvP attack after the scout-before-attack check.
pub async fn attack_city(
    engine: &Engine,
    tx: &mut Transaction<'_, Postgres>,
    player: &str,
    cmd: &kd_proto::AttackCityCmd,
) -> AppResult<()> {
    let (x, y) = resolve_target(tx, &engine.realm_id, &cmd.target_city_id).await?;
    let defender: Option<(String, i64, bool, Option<String>)> = sqlx::query_as("SELECT c.player_id::text,c.shield_until_ms,c.is_capital,p.alliance_id FROM cities c JOIN players p ON p.realm_id=c.realm_id AND p.player_id=c.player_id WHERE c.realm_id=$1 AND c.city_id=$2")
        .bind(&engine.realm_id).bind(&cmd.target_city_id).fetch_optional(&mut **tx).await.map_err(|e| AppError::Internal(e.to_string()))?;
    let (def_player, shield, is_capital, def_alliance) =
        defender.ok_or_else(|| AppError::NotFound("target city not found".into()))?;
    if def_player == player {
        return Err(AppError::Invalid("cannot attack own city".into()));
    }
    let now = engine
        .now_ms(tx)
        .await
        .map_err(|e| AppError::Internal(e.to_string()))?;
    if shield > now {
        return Err(AppError::Shielded);
    }
    let (_, my_alliance, _) = player_exists(tx, &engine.realm_id, player).await?;
    if my_alliance.is_some() && my_alliance == def_alliance {
        return Err(AppError::Forbidden("friendly fire disabled".into()));
    }
    let scouted: (i64,) = sqlx::query_as("SELECT count(*) FROM reports WHERE realm_id=$1 AND kind='scout' AND participants::jsonb ? $2 AND payload->>'target_city_id'=$3")
        .bind(&engine.realm_id).bind(player).bind(&cmd.target_city_id).fetch_one(&mut **tx).await.map_err(|e| AppError::Internal(e.to_string()))?;
    if scouted.0 == 0 {
        return Err(AppError::Prerequisite(
            "must scout target before attacking".into(),
        ));
    }
    if is_capital {
        let ct: (i64,) = sqlx::query_as("SELECT food FROM cities WHERE realm_id=$1 AND city_id=$2")
            .bind(&engine.realm_id)
            .bind(&cmd.target_city_id)
            .fetch_one(&mut **tx)
            .await
            .map_err(|e| AppError::Internal(e.to_string()))?;
        let _ = ct;
    }
    let units = load_troops(tx, &engine.realm_id, &cmd.city_id).await?;
    if army_count(&units) == 0 {
        return Err(AppError::InsufficientTroops("empty garrison".into()));
    }
    let plan = plan_march(
        engine,
        tx,
        player,
        &cmd.city_id,
        (x, y),
        &cmd.target_city_id,
        units,
    )
    .await?;
    dispatch_march(
        engine,
        tx,
        player,
        plan,
        "attack_city",
        ResVec::default(),
        "",
        "attack_city",
        true,
    )
    .await?;
    Ok(())
}

/// Launch an assault on a neutral or enemy fort.
pub async fn attack_fort(
    engine: &Engine,
    tx: &mut Transaction<'_, Postgres>,
    player: &str,
    cmd: &kd_proto::AttackFortCmd,
) -> AppResult<()> {
    let (x, y) = resolve_target(tx, &engine.realm_id, &cmd.fort_id).await?;
    let units = load_troops(tx, &engine.realm_id, &cmd.city_id).await?;
    if army_count(&units) == 0 {
        return Err(AppError::InsufficientTroops("empty garrison".into()));
    }
    let plan = plan_march(
        engine,
        tx,
        player,
        &cmd.city_id,
        (x, y),
        &cmd.fort_id,
        units,
    )
    .await?;
    dispatch_march(
        engine,
        tx,
        player,
        plan,
        "attack_fort",
        ResVec::default(),
        "",
        "attack_fort",
        true,
    )
    .await?;
    Ok(())
}

/// Send troops to strengthen an allied city.
pub async fn reinforce(
    engine: &Engine,
    tx: &mut Transaction<'_, Postgres>,
    player: &str,
    cmd: &kd_proto::ReinforceCmd,
) -> AppResult<()> {
    let (target_owner, target_alliance) =
        player_alliance_of_city(tx, &engine.realm_id, &cmd.target_city_id).await?;
    if target_owner == player {
        return Err(AppError::Invalid("cannot reinforce own city".into()));
    }
    let (_, my_alliance, _) = player_exists(tx, &engine.realm_id, player).await?;
    if my_alliance.is_none() || my_alliance != target_alliance {
        return Err(AppError::Forbidden(
            "reinforcement requires same alliance".into(),
        ));
    }
    let units = troops_from_proto(&cmd.troops)?;
    let (x, y) = resolve_target(tx, &engine.realm_id, &cmd.target_city_id).await?;
    let plan = plan_march(
        engine,
        tx,
        player,
        &cmd.city_id,
        (x, y),
        &cmd.target_city_id,
        units,
    )
    .await?;
    dispatch_march(
        engine,
        tx,
        player,
        plan,
        "reinforce",
        ResVec::default(),
        "",
        "reinforce",
        true,
    )
    .await?;
    Ok(())
}

/// Send resources to an allied city.
pub async fn transport(
    engine: &Engine,
    tx: &mut Transaction<'_, Postgres>,
    player: &str,
    cmd: &kd_proto::TransportCmd,
) -> AppResult<()> {
    let (target_owner, target_alliance) =
        player_alliance_of_city(tx, &engine.realm_id, &cmd.target_city_id).await?;
    if target_owner == player {
        return Err(AppError::Invalid("cannot transport to own city".into()));
    }
    let (_, my_alliance, _) = player_exists(tx, &engine.realm_id, player).await?;
    if my_alliance.is_none() || my_alliance != target_alliance {
        return Err(AppError::Forbidden(
            "transport requires same alliance".into(),
        ));
    }
    let cargo = res_from_proto(cmd.resources.as_ref());
    if !cargo.is_nonnegative() || cargo == ResVec::default() {
        return Err(AppError::Invalid("invalid cargo".into()));
    }
    let (x, y) = resolve_target(tx, &engine.realm_id, &cmd.target_city_id).await?;
    accrue_city(engine, tx, &cmd.city_id).await?;
    let city = load_city(tx, &engine.realm_id, &cmd.city_id).await?;
    if city.player_id != player {
        return Err(AppError::Forbidden("not your city".into()));
    }
    debit(tx, &engine.realm_id, &city, cargo).await?;
    let units = vec![ArmyUnit {
        unit: "scout".into(),
        tier: 1,
        count: 1,
    }];
    let plan = plan_march(
        engine,
        tx,
        player,
        &cmd.city_id,
        (x, y),
        &cmd.target_city_id,
        units,
    )
    .await?;
    dispatch_march(
        engine,
        tx,
        player,
        plan,
        "transport",
        cargo,
        "",
        "transport",
        true,
    )
    .await?;
    Ok(())
}

/// Return the alliance id owning a city, if any.
pub async fn player_alliance_of_city(
    tx: &mut Transaction<'_, Postgres>,
    realm: &str,
    city_id: &str,
) -> AppResult<(String, Option<String>)> {
    let r: Option<(String, Option<String>)> = sqlx::query_as(
        "SELECT p.player_id::text,p.alliance_id FROM cities c JOIN players p ON p.realm_id=c.realm_id AND p.player_id=c.player_id WHERE c.realm_id=$1 AND c.city_id=$2",
    ).bind(realm).bind(city_id).fetch_optional(&mut **tx).await.map_err(|e| AppError::Internal(e.to_string()))?;
    r.ok_or_else(|| AppError::NotFound("city not found".into()))
}

/// Recall an active march before it reaches its target.
pub async fn recall(
    engine: &Engine,
    tx: &mut Transaction<'_, Postgres>,
    player: &str,
    cmd: &kd_proto::RecallCmd,
) -> AppResult<()> {
    let m: Option<(String, String, i32, i32, i32, i32)> = sqlx::query_as(
        "SELECT player_id::text,state,from_x,from_y,to_x,to_y FROM marches WHERE realm_id=$1 AND id=$2",
    )
    .bind(&engine.realm_id)
    .bind(&cmd.march_id)
    .fetch_optional(&mut **tx)
    .await
    .map_err(|e| AppError::Internal(e.to_string()))?;
    let (owner, state, fx, fy, to_x, to_y) =
        m.ok_or_else(|| AppError::NotFound("march not found".into()))?;
    if owner != player {
        return Err(AppError::Forbidden("not your march".into()));
    }
    if state == "returning" || state == "completed" {
        return Err(AppError::Conflict("cannot recall".into()));
    }
    let now = engine
        .now_ms(tx)
        .await
        .map_err(|e| AppError::Internal(e.to_string()))?;
    sqlx::query("UPDATE scheduled_events SET status='cancelled' WHERE realm_id=$1 AND status='pending' AND payload->>'march_id'=$2")
        .bind(&engine.realm_id).bind(&cmd.march_id).execute(&mut **tx).await.map_err(|e| AppError::Internal(e.to_string()))?;
    let return_ms = (distance((to_x, to_y), (fx, fy)) + 1) * 1000;
    sqlx::query("UPDATE marches SET state='returning',return_at_ms=$3,version=version+1 WHERE realm_id=$1 AND id=$2")
        .bind(&engine.realm_id).bind(&cmd.march_id).bind(now + return_ms.max(1000))
        .execute(&mut **tx).await.map_err(|e| AppError::Internal(e.to_string()))?;
    engine
        .schedule(
            tx,
            now + return_ms.max(1000),
            300,
            "march_return",
            json!({"march_id":cmd.march_id}),
        )
        .await
        .map_err(|e| AppError::Internal(e.to_string()))?;
    delta(
        engine,
        tx,
        "march.recalled",
        EventRouting {
            pos: None,
            aggregate_id: cmd.march_id.clone(),
            owner_player_id: Some(player.into()),
            private: true,
            visible_players: vec![player.into()],
        },
        json!({"march_id":cmd.march_id}),
    )
    .await?;
    Ok(())
}
