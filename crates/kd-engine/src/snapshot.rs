//! Authoritative snapshot construction. Private state is assembled server-side
//! and filtered before it ever reaches a transport encoder.
use crate::commands::accrue_city;
use crate::engine::Engine;
use kd_common::AppResult;
use kd_domain::content::{self, ResVec};
use kd_domain::sim::ArmyUnit;
use kd_domain::state::{
    CitySnapshot, EntityState, MapSnapshot, MarchSnapshot, PlayerSnapshot, PublicCity, PublicMarch,
};
use kd_domain::world;
use kd_proto::Vec2;
use serde_json::Value;
use sqlx::{Postgres, Transaction};
use std::collections::HashMap;

/// Build the authoritative private player payload.
pub async fn player_snapshot(
    engine: &Engine,
    tx: &mut Transaction<'_, Postgres>,
    player: &str,
) -> AppResult<PlayerSnapshot> {
    let all: Vec<(String,)> = sqlx::query_as("SELECT city_id FROM cities WHERE realm_id=$1 AND player_id=$2::uuid ORDER BY is_capital DESC,city_id")
        .bind(&engine.realm_id).bind(player).fetch_all(&mut **tx).await.map_err(|e| kd_common::AppError::Internal(e.to_string()))?;
    for (city_id,) in &all {
        accrue_city(engine, tx, city_id).await?;
    }
    let p: (String, Option<String>, Option<String>) = sqlx::query_as("SELECT name,alliance_id,alliance_role FROM players WHERE realm_id=$1 AND player_id=$2::uuid")
        .bind(&engine.realm_id).bind(player).fetch_one(&mut **tx).await.map_err(|e| kd_common::AppError::Internal(e.to_string()))?;
    let ver: (i64,) = sqlx::query_as("SELECT version FROM realm_state WHERE realm_id=$1")
        .bind(&engine.realm_id)
        .fetch_one(&mut **tx)
        .await
        .map_err(|e| kd_common::AppError::Internal(e.to_string()))?;
    let now = engine
        .now_ms(tx)
        .await
        .map_err(|e| kd_common::AppError::Internal(e.to_string()))?;
    let research_queue: Option<(i64, String)> = sqlx::query_as(
        "SELECT due_at_ms,COALESCE(payload->>'tech','') FROM scheduled_events WHERE realm_id=$1 AND kind='research_complete' AND status='pending' AND payload->>'player_id'=$2 ORDER BY due_at_ms LIMIT 1",
    )
    .bind(&engine.realm_id)
    .bind(player)
    .fetch_optional(&mut **tx)
    .await
    .map_err(|e| kd_common::AppError::Internal(e.to_string()))?;

    let mut cities = Vec::new();
    for (city_id,) in &all {
        let c: (String, i32, i32, bool, i64, i64, i64, i64, i64, i64, i64, i32) = sqlx::query_as(
            "SELECT name,x,y,is_capital,shield_until_ms,busy_until_ms,food,wood,stone,iron,gold,COALESCE(town_hall_level,1) FROM cities WHERE realm_id=$1 AND city_id=$2",
        ).bind(&engine.realm_id).bind(city_id).fetch_one(&mut **tx).await.map_err(|e| kd_common::AppError::Internal(e.to_string()))?;
        let b: Vec<(String, i32)> =
            sqlx::query_as("SELECT kind,level FROM buildings WHERE realm_id=$1 AND city_id=$2")
                .bind(&engine.realm_id)
                .bind(city_id)
                .fetch_all(&mut **tx)
                .await
                .map_err(|e| kd_common::AppError::Internal(e.to_string()))?;
        let bmap: HashMap<String, i32> = b.into_iter().collect();
        let r: Vec<(String, i32)> = sqlx::query_as(
            "SELECT tech,level FROM research WHERE realm_id=$1 AND player_id=$2::uuid",
        )
        .bind(&engine.realm_id)
        .bind(player)
        .fetch_all(&mut **tx)
        .await
        .map_err(|e| kd_common::AppError::Internal(e.to_string()))?;
        let rmap: HashMap<String, i32> = r.into_iter().collect();
        let m = content::compute_modifiers(&bmap, &rmap, 0, 0, 0, 0);
        let tr: Vec<(String, i32, i64, i64)> = sqlx::query_as("SELECT unit,tier,count,wounded FROM troops WHERE realm_id=$1 AND city_id=$2 AND (count>0 OR wounded>0)")
            .bind(&engine.realm_id).bind(city_id).fetch_all(&mut **tx).await.map_err(|e| kd_common::AppError::Internal(e.to_string()))?;
        let troops: Vec<ArmyUnit> = tr
            .iter()
            .filter(|x| x.2 > 0)
            .map(|x| ArmyUnit {
                unit: x.0.clone(),
                tier: x.1 as u32,
                count: x.2 as u64,
            })
            .collect();
        let wounded: Vec<ArmyUnit> = tr
            .iter()
            .filter(|x| x.3 > 0)
            .map(|x| ArmyUnit {
                unit: x.0.clone(),
                tier: x.1 as u32,
                count: x.3 as u64,
            })
            .collect();
        let busy_action: (Option<String>,) =
            sqlx::query_as("SELECT busy_action FROM cities WHERE realm_id=$1 AND city_id=$2")
                .bind(&engine.realm_id)
                .bind(city_id)
                .fetch_one(&mut **tx)
                .await
                .map_err(|e| kd_common::AppError::Internal(e.to_string()))?;
        let busy_target: (Option<String>,) = sqlx::query_as(
            "SELECT COALESCE(payload->>'building',payload->>'unit',kind) FROM scheduled_events WHERE realm_id=$1 AND status='pending' AND payload->>'city_id'=$2 ORDER BY due_at_ms,priority,id LIMIT 1",
        )
        .bind(&engine.realm_id)
        .bind(city_id)
        .fetch_optional(&mut **tx)
        .await
        .map_err(|e| kd_common::AppError::Internal(e.to_string()))?
        .unwrap_or((None,));
        cities.push(CitySnapshot {
            id: city_id.clone(),
            name: c.0,
            x: c.1,
            y: c.2,
            is_capital: c.3,
            buildings: bmap,
            resources: ResVec {
                food: c.6,
                wood: c.7,
                stone: c.8,
                iron: c.9,
                gold: c.10,
            },
            rates_per_hour: ResVec {
                food: m.food_prod / 1000,
                wood: m.wood_prod / 1000,
                stone: m.stone_prod / 1000,
                iron: m.iron_prod / 1000,
                gold: m.gold_prod / 1000,
            },
            capacity: ResVec {
                food: m.capacity,
                wood: m.capacity,
                stone: m.capacity,
                iron: m.capacity,
                gold: m.capacity / 2,
            },
            troops,
            wounded,
            shield_until_ms: c.4,
            busy_until_ms: c.5,
            busy_action: busy_action.0.unwrap_or_default(),
            busy_target: busy_target.0.unwrap_or_default(),
        });
    }

    let research: Vec<(String, i32)> = sqlx::query_as(
        "SELECT tech,level FROM research WHERE realm_id=$1 AND player_id=$2::uuid AND level>0",
    )
    .bind(&engine.realm_id)
    .bind(player)
    .fetch_all(&mut **tx)
    .await
    .map_err(|e| kd_common::AppError::Internal(e.to_string()))?;
    let items: Vec<(String, i64)> = sqlx::query_as(
        "SELECT item_key,qty FROM items WHERE realm_id=$1 AND player_id=$2::uuid AND qty>0",
    )
    .bind(&engine.realm_id)
    .bind(player)
    .fetch_all(&mut **tx)
    .await
    .map_err(|e| kd_common::AppError::Internal(e.to_string()))?;
    let heroes: Vec<(String, i32)> = sqlx::query_as(
        "SELECT hero_key,level FROM heroes WHERE realm_id=$1 AND player_id=$2::uuid",
    )
    .bind(&engine.realm_id)
    .bind(player)
    .fetch_all(&mut **tx)
    .await
    .map_err(|e| kd_common::AppError::Internal(e.to_string()))?;
    let assignments: Vec<(String, String)> = sqlx::query_as("SELECT assignment,hero_key FROM heroes WHERE realm_id=$1 AND player_id=$2::uuid AND assignment<>''")
        .bind(&engine.realm_id).bind(player).fetch_all(&mut **tx).await.map_err(|e| kd_common::AppError::Internal(e.to_string()))?;
    let mr: Vec<(String, String, String, String, i32, i32, i32, i32, i64, Value, String, i64)> = sqlx::query_as(
        "SELECT id,mission,state,from_city_id,from_x,from_y,to_x,to_y,arrive_at_ms,troops,hero,depart_at_ms FROM marches WHERE realm_id=$1 AND player_id=$2::uuid AND state<>'completed' ORDER BY arrive_at_ms",
    ).bind(&engine.realm_id).bind(player).fetch_all(&mut **tx).await.map_err(|e| kd_common::AppError::Internal(e.to_string()))?;
    let marches = mr
        .into_iter()
        .map(|r| MarchSnapshot {
            id: r.0,
            mission: r.1,
            state: r.2,
            from_city_id: r.3,
            from: (r.4, r.5),
            to: (r.6, r.7),
            target_id: String::new(),
            depart_at_ms: r.11,
            arrive_at_ms: r.8,
            troops: serde_json::from_value(r.9).unwrap_or_default(),
            hero: r.10,
            resources: ResVec::default(),
        })
        .collect();

    Ok(PlayerSnapshot {
        player_id: player.into(),
        name: p.0,
        realm_id: engine.realm_id.clone(),
        alliance_id: p.1,
        alliance_role: p.2,
        research_busy_until_ms: research_queue.as_ref().map(|q| q.0).unwrap_or_default(),
        research_busy_target: research_queue.map(|q| q.1).unwrap_or_default(),
        cities,
        research: research.into_iter().collect(),
        items: items.into_iter().collect(),
        heroes: heroes.into_iter().collect(),
        hero_assignment: assignments.into_iter().collect(),
        marches,
        version: ver.0 as u64,
        server_time_ms: now,
    })
}

/// Build the chunk- and visibility-filtered map payload.
pub async fn map_snapshot(
    engine: &Engine,
    tx: &mut Transaction<'_, Postgres>,
    player: &str,
    chunks: &[Vec2],
) -> AppResult<MapSnapshot> {
    let (seed,): (i64,) = sqlx::query_as("SELECT seed FROM realm_state WHERE realm_id=$1")
        .bind(&engine.realm_id)
        .fetch_one(&mut **tx)
        .await
        .map_err(|e| kd_common::AppError::Internal(e.to_string()))?;
    let scouted: Vec<(i32, i32)> = sqlx::query_as(
        "SELECT chunk_x,chunk_y FROM player_scouting WHERE realm_id=$1 AND player_id=$2::uuid",
    )
    .bind(&engine.realm_id)
    .bind(player)
    .fetch_all(&mut **tx)
    .await
    .map_err(|e| kd_common::AppError::Internal(e.to_string()))?;
    let scouted_set: std::collections::HashSet<(i32, i32)> = scouted.into_iter().collect();
    // div_euclid matches world::chunk_tiles and the gateway subscription filter;
    // SQL's `/` truncates toward zero and misclassifies negative coordinates.
    let city_positions: Vec<(i32, i32)> =
        sqlx::query_as("SELECT x,y FROM cities WHERE realm_id=$1 AND player_id=$2::uuid")
            .bind(&engine.realm_id)
            .bind(player)
            .fetch_all(&mut **tx)
            .await
            .map_err(|e| kd_common::AppError::Internal(e.to_string()))?;
    let own_city_chunks: Vec<(i32, i32)> = city_positions
        .iter()
        .map(|(x, y)| (x.div_euclid(32), y.div_euclid(32)))
        .collect();
    let mut visible = scouted_set;
    visible.extend(own_city_chunks);

    let mut tiles = Vec::new();
    let mut entities = Vec::new();
    let mut fogged_chunks = Vec::new();
    let cs = 32i32;
    for c in chunks {
        if !visible.contains(&(c.x, c.y)) {
            fogged_chunks.push((c.x, c.y));
        }
        for t in world::chunk_tiles(seed as u64, c.x, c.y, cs) {
            tiles.push((t.x, t.y, t.terrain));
        }
        let x0 = c.x * cs;
        let y0 = c.y * cs;
        let rows: Vec<(String, String, i32, i32, i32, String, i64, i64, Option<String>, i64)> = sqlx::query_as(
            "SELECT id,kind,x,y,level,subtype,stock,hp,COALESCE(owner_player_id::text,''),respawn_at_ms FROM entity_state WHERE realm_id=$1 AND x BETWEEN $2 AND $3 AND y BETWEEN $4 AND $5",
        ).bind(&engine.realm_id).bind(x0).bind(x0 + cs - 1).bind(y0).bind(y0 + cs - 1)
         .fetch_all(&mut **tx).await.map_err(|e| kd_common::AppError::Internal(e.to_string()))?;
        for r in rows {
            // A defeated monster is removed from the visible world until its
            // scheduled respawn; broadcasting hp=0 sprites would make the map
            // look permanently cluttered with corpses.
            if r.1 == "monster" && r.7 <= 0 {
                continue;
            }
            // Neutral frontier targets are part of the world map: let players
            // discover and interact with monsters and resource sites without
            // scouting. Keep player-owned entities and fog rules intact.
            let is_neutral_target = r.8.as_deref().is_none_or(|o| o.is_empty())
                && matches!(r.1.as_str(), "monster" | "resource_node" | "node" | "fort");
            if !visible.contains(&(c.x, c.y))
                && r.8.as_deref().filter(|o| !o.is_empty()) != Some(player)
                && !is_neutral_target
            {
                continue;
            }
            entities.push(EntityState {
                id: r.0,
                kind: parse_kind(&r.1),
                x: r.2,
                y: r.3,
                level: r.4,
                subtype: r.5,
                stock: r.6,
                hp: r.7,
                owner_player_id: r.8.filter(|s| !s.is_empty()),
                respawn_at_ms: r.9,
            });
        }
    }
    let cities: Vec<(String, String, String, String, Option<String>, i32, i32, bool, i32, i64)> = sqlx::query_as(
        "SELECT c.city_id,c.name,c.player_id::text,p.name,p.alliance_id,c.x,c.y,c.is_capital,c.town_hall_level,c.shield_until_ms FROM cities c JOIN players p ON p.realm_id=c.realm_id AND p.player_id=c.player_id WHERE c.realm_id=$1 AND ($2=0 OR (c.x BETWEEN $3 AND $4 AND c.y BETWEEN $5 AND $6)) LIMIT 500",
    ).bind(&engine.realm_id).bind(chunks.len() as i32)
     .bind(chunks.iter().map(|c| c.x * cs).min().unwrap_or(0))
     .bind(chunks.iter().map(|c| c.x * cs + cs - 1).max().unwrap_or(0))
     .bind(chunks.iter().map(|c| c.y * cs).min().unwrap_or(0))
     .bind(chunks.iter().map(|c| c.y * cs + cs - 1).max().unwrap_or(0))
     .fetch_all(&mut **tx).await.map_err(|e| kd_common::AppError::Internal(e.to_string()))?;
    let public_cities = cities
        .into_iter()
        .filter(|c| visible.contains(&(c.5.div_euclid(cs), c.6.div_euclid(cs))) || c.2 == player)
        .map(|c| PublicCity {
            id: c.0,
            name: c.1,
            player_id: c.2,
            player_name: c.3,
            alliance_id: c.4,
            x: c.5,
            y: c.6,
            is_capital: c.7,
            town_hall_level: c.8,
            shield_until_ms: c.9,
        })
        .collect();
    let marches: Vec<(String, String, String, i32, i32, i32, i32, i64, i64)> = sqlx::query_as(
        "SELECT id,player_id::text,mission,from_x,from_y,to_x,to_y,depart_at_ms,arrive_at_ms FROM marches WHERE realm_id=$1 AND state IN ('traveling','gathering','returning') LIMIT 500",
    ).bind(&engine.realm_id).fetch_all(&mut **tx).await.map_err(|e| kd_common::AppError::Internal(e.to_string()))?;
    let public_marches = marches
        .into_iter()
        .map(|m| PublicMarch {
            id: m.0,
            player_id: m.1,
            mission: m.2,
            from: (m.3, m.4),
            to: (m.5, m.6),
            depart_at_ms: m.7,
            arrive_at_ms: m.8,
        })
        .collect();
    let scores: Vec<(String, i64)> = sqlx::query_as(
        "SELECT score_key,score FROM season_scores WHERE realm_id=$1 ORDER BY score DESC LIMIT 20",
    )
    .bind(&engine.realm_id)
    .fetch_all(&mut **tx)
    .await
    .map_err(|e| kd_common::AppError::Internal(e.to_string()))?;
    Ok(MapSnapshot {
        realm_id: engine.realm_id.clone(),
        seed: seed as u64,
        chunk_size: cs,
        tiles,
        entities,
        cities: public_cities,
        marches: public_marches,
        season_score: scores.into_iter().collect(),
        fogged_chunks,
    })
}

fn parse_kind(s: &str) -> world::EntityKind {
    match s {
        "node" => world::EntityKind::ResourceNode,
        "monster" => world::EntityKind::Monster,
        _ => world::EntityKind::Fort,
    }
}
