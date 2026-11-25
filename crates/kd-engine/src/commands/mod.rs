//! Typed authoritative command handlers and scheduled-event effects.
//! Every write is called from within a fenced transaction.
use crate::engine::{Engine, EventRouting};
use kd_common::{AppError, AppResult};
use kd_domain::content::{self, Modifiers, ResVec, Resource, RESOURCES};
use kd_domain::economy::accrue;
use kd_domain::sim::{self, ArmyUnit, CombatInput};
use kd_domain::world::{self, EntityKind};
use kd_proto::{command_payload::Action, CommandPayload};
use serde_json::{json, Value};
use sqlx::{FromRow, PgPool, Postgres, Transaction};
use std::collections::HashMap;

// Feature handlers live in focused submodules. `use super::*` in each
// submodule gives them access to the shared helpers kept here.
mod alliance;
mod city;
mod combat;
mod events;
mod logistics;
mod movement;
mod progression;
mod rally;

pub use alliance::*;
pub use city::*;
pub use combat::*;
pub use events::*;
pub use logistics::*;
pub use movement::*;
pub use progression::*;
pub use rally::*;

#[derive(FromRow, Clone)]
#[allow(dead_code)]
/// Minimal city row used to authorise and route commands.
pub struct CityRow {
    city_id: String,
    player_id: String,
    name: String,
    x: i32,
    y: i32,
    is_capital: bool,
    shield_until_ms: i64,
    busy_until_ms: i64,
    food: i64,
    wood: i64,
    stone: i64,
    iron: i64,
    gold: i64,
    rem_food: i64,
    rem_wood: i64,
    rem_stone: i64,
    rem_iron: i64,
    rem_gold: i64,
    last_accrued_ms: i64,
}

impl CityRow {
    fn resources(&self) -> ResVec {
        ResVec {
            food: self.food,
            wood: self.wood,
            stone: self.stone,
            iron: self.iron,
            gold: self.gold,
        }
    }
}

async fn load_city(
    tx: &mut Transaction<'_, Postgres>,
    realm: &str,
    city_id: &str,
) -> AppResult<CityRow> {
    sqlx::query_as::<_, CityRow>(
        "SELECT city_id,player_id::text,name,x,y,is_capital,shield_until_ms,busy_until_ms,food,wood,stone,iron,gold,rem_food,rem_wood,rem_stone,rem_iron,rem_gold,last_accrued_ms FROM cities WHERE realm_id=$1 AND city_id=$2",
    ).bind(realm).bind(city_id).fetch_optional(&mut **tx).await
        .map_err(|e| AppError::Internal(e.to_string()))?
        .ok_or_else(|| AppError::NotFound("city not found".into()))
}

async fn player_exists(
    tx: &mut Transaction<'_, Postgres>,
    realm: &str,
    player_id: &str,
) -> AppResult<(String, Option<String>, Option<String>)> {
    sqlx::query_as::<_, (String, Option<String>, Option<String>)>(
        "SELECT name,alliance_id,alliance_role FROM players WHERE realm_id=$1 AND player_id=$2::uuid",
    ).bind(realm).bind(player_id).fetch_optional(&mut **tx).await
        .map_err(|e| AppError::Internal(e.to_string()))?
        .ok_or(AppError::Unauthenticated)
}

async fn buildings(
    tx: &mut Transaction<'_, Postgres>,
    realm: &str,
    city_id: &str,
) -> AppResult<HashMap<String, i32>> {
    let rows: Vec<(String, i32)> =
        sqlx::query_as("SELECT kind,level FROM buildings WHERE realm_id=$1 AND city_id=$2")
            .bind(realm)
            .bind(city_id)
            .fetch_all(&mut **tx)
            .await
            .map_err(|e| AppError::Internal(e.to_string()))?;
    Ok(rows.into_iter().collect())
}

async fn research(
    tx: &mut Transaction<'_, Postgres>,
    realm: &str,
    player_id: &str,
) -> AppResult<HashMap<String, i32>> {
    let rows: Vec<(String, i32)> =
        sqlx::query_as("SELECT tech,level FROM research WHERE realm_id=$1 AND player_id=$2::uuid")
            .bind(realm)
            .bind(player_id)
            .fetch_all(&mut **tx)
            .await
            .map_err(|e| AppError::Internal(e.to_string()))?;
    Ok(rows.into_iter().collect())
}

async fn hero_bonuses(
    tx: &mut Transaction<'_, Postgres>,
    realm: &str,
    player_id: &str,
    city_id: &str,
) -> AppResult<(i64, i64, i64, i64, i32)> {
    let row: Option<(String, i32)> = sqlx::query_as("SELECT hero_key,level FROM heroes WHERE realm_id=$1 AND player_id=$2::uuid AND assignment=$3")
        .bind(realm).bind(player_id).bind(city_id).fetch_optional(&mut **tx).await.map_err(|e| AppError::Internal(e.to_string()))?;
    if let Some((key, level)) = row {
        if let Some(h) = content::hero(&key) {
            let scale = 1000i64 + (level - 1) as i64 * 60;
            return Ok((
                h.attack_bonus_permille * scale / 1000,
                h.defense_bonus_permille * scale / 1000,
                h.economy_bonus_permille * scale / 1000,
                h.speed_bonus_permille * scale / 1000,
                level,
            ));
        }
    }
    Ok((0, 0, 0, 0, 0))
}

async fn modifiers_for(
    tx: &mut Transaction<'_, Postgres>,
    realm: &str,
    player_id: &str,
    city_id: &str,
) -> AppResult<Modifiers> {
    let b = buildings(tx, realm, city_id).await?;
    let r = research(tx, realm, player_id).await?;
    let (a, d, e, s, _) = hero_bonuses(tx, realm, player_id, city_id).await?;
    Ok(content::compute_modifiers(&b, &r, a, d, e, s))
}

/// Lazily accrue a city's production up to `now`, persisting fractional remainders.
pub async fn accrue_city(
    engine: &Engine,
    tx: &mut Transaction<'_, Postgres>,
    city_id: &str,
) -> AppResult<()> {
    let city = load_city(tx, &engine.realm_id, city_id).await?;
    let now = engine
        .now_ms(tx)
        .await
        .map_err(|e| AppError::Internal(e.to_string()))?;
    if now <= city.last_accrued_ms {
        return Ok(());
    }
    let elapsed_ms = now - city.last_accrued_ms;
    let m = modifiers_for(tx, &engine.realm_id, &city.player_id, city_id).await?;
    let cap = ResVec {
        food: m.capacity,
        wood: m.capacity,
        stone: m.capacity,
        iron: m.capacity,
        gold: m.capacity / 2,
    };
    let prod = |scaled: i64| scaled;
    let (food, rf) = accrue(
        city.food,
        city.rem_food,
        prod(m.food_prod),
        elapsed_ms / 1000,
        cap.food,
    );
    let (wood, rw) = accrue(
        city.wood,
        city.rem_wood,
        prod(m.wood_prod),
        elapsed_ms / 1000,
        cap.wood,
    );
    let (stone, rs) = accrue(
        city.stone,
        city.rem_stone,
        prod(m.stone_prod),
        elapsed_ms / 1000,
        cap.stone,
    );
    let (iron, ri) = accrue(
        city.iron,
        city.rem_iron,
        prod(m.iron_prod),
        elapsed_ms / 1000,
        cap.iron,
    );
    let (gold, rg) = accrue(
        city.gold,
        city.rem_gold,
        prod(m.gold_prod),
        elapsed_ms / 1000,
        cap.gold,
    );
    sqlx::query("UPDATE cities SET food=$2,wood=$3,stone=$4,iron=$5,gold=$6,rem_food=$7,rem_wood=$8,rem_stone=$9,rem_iron=$10,rem_gold=$11,last_accrued_ms=$12 WHERE realm_id=$13 AND city_id=$1")
        .bind(city_id).bind(food).bind(wood).bind(stone).bind(iron).bind(gold)
        .bind(rf).bind(rw).bind(rs).bind(ri).bind(rg).bind(now).bind(&engine.realm_id)
        .execute(&mut **tx).await.map_err(|e| AppError::Internal(e.to_string()))?;
    Ok(())
}

async fn debit(
    tx: &mut Transaction<'_, Postgres>,
    realm: &str,
    city: &CityRow,
    cost: ResVec,
) -> AppResult<()> {
    if !city.resources().can_afford(cost) {
        return Err(AppError::InsufficientResources("cannot afford cost".into()));
    }
    sqlx::query("UPDATE cities SET food=food-$2,wood=wood-$3,stone=stone-$4,iron=iron-$5,gold=gold-$6 WHERE realm_id=$1 AND city_id=$7")
        .bind(realm).bind(cost.food).bind(cost.wood).bind(cost.stone).bind(cost.iron).bind(cost.gold).bind(&city.city_id)
        .execute(&mut **tx).await.map_err(|e| AppError::Internal(e.to_string()))?;
    Ok(())
}

async fn credit(
    tx: &mut Transaction<'_, Postgres>,
    realm: &str,
    city_id: &str,
    amount: ResVec,
) -> AppResult<()> {
    if RESOURCES.iter().all(|&r| amount.get(r) == 0) {
        return Ok(());
    }
    sqlx::query("UPDATE cities SET food=food+$2,wood=wood+$3,stone=stone+$4,iron=iron+$5,gold=gold+$6 WHERE realm_id=$1 AND city_id=$7")
        .bind(realm).bind(amount.food).bind(amount.wood).bind(amount.stone).bind(amount.iron).bind(amount.gold).bind(city_id)
        .execute(&mut **tx).await.map_err(|e| AppError::Internal(e.to_string()))?;
    Ok(())
}

async fn load_troops(
    tx: &mut Transaction<'_, Postgres>,
    realm: &str,
    city_id: &str,
) -> AppResult<Vec<ArmyUnit>> {
    let rows: Vec<(String, i32, i64)> = sqlx::query_as(
        "SELECT unit,tier,count FROM troops WHERE realm_id=$1 AND city_id=$2 AND count>0",
    )
    .bind(realm)
    .bind(city_id)
    .fetch_all(&mut **tx)
    .await
    .map_err(|e| AppError::Internal(e.to_string()))?;
    Ok(rows
        .into_iter()
        .map(|(unit, tier, count)| ArmyUnit {
            unit,
            tier: tier as u32,
            count: count as u64,
        })
        .collect())
}

async fn adjust_troop(
    tx: &mut Transaction<'_, Postgres>,
    realm: &str,
    city_id: &str,
    u: &ArmyUnit,
    delta: i64,
) -> AppResult<()> {
    sqlx::query(
        "INSERT INTO troops(realm_id,city_id,unit,tier,count) VALUES ($1,$2,$3,$4,GREATEST($5,0))
         ON CONFLICT(realm_id,city_id,unit,tier) DO UPDATE SET count=GREATEST(troops.count+$5,0)",
    )
    .bind(realm)
    .bind(city_id)
    .bind(&u.unit)
    .bind(u.tier as i32)
    .bind(delta)
    .execute(&mut **tx)
    .await
    .map_err(|e| AppError::Internal(e.to_string()))?;
    Ok(())
}

async fn apply_troop_list(
    tx: &mut Transaction<'_, Postgres>,
    realm: &str,
    city_id: &str,
    list: &[ArmyUnit],
) -> AppResult<()> {
    for u in list {
        adjust_troop(tx, realm, city_id, u, -(u.count as i64)).await?;
    }
    Ok(())
}

async fn add_troop_list(
    tx: &mut Transaction<'_, Postgres>,
    realm: &str,
    city_id: &str,
    list: &[ArmyUnit],
) -> AppResult<()> {
    for u in list {
        adjust_troop(tx, realm, city_id, u, u.count as i64).await?;
    }
    Ok(())
}

fn army_cost(units: &[ArmyUnit]) -> AppResult<ResVec> {
    let mut total = ResVec::default();
    for u in units {
        let d = content::unit(&u.unit, u.tier)
            .ok_or_else(|| AppError::Invalid("unknown unit".into()))?;
        total = total
            .add_checked(ResVec {
                food: d.cost.food * u.count as i64,
                wood: d.cost.wood * u.count as i64,
                stone: d.cost.stone * u.count as i64,
                iron: d.cost.iron * u.count as i64,
                gold: d.cost.gold * u.count as i64,
            })
            .ok_or_else(|| AppError::Invalid("cost overflow".into()))?;
    }
    Ok(total)
}

fn army_count(units: &[ArmyUnit]) -> u64 {
    units.iter().map(|u| u.count).sum()
}

fn march_speed(units: &[ArmyUnit], m: &Modifiers) -> i64 {
    let relevant: Vec<&ArmyUnit> = units
        .iter()
        .filter(|u| u.unit != "scout" && u.count > 0)
        .collect();
    let base = if relevant.is_empty() {
        300
    } else {
        relevant
            .iter()
            .filter_map(|u| content::unit(&u.unit, u.tier).map(|d| d.speed))
            .min()
            .unwrap_or(300)
    };
    (base * m.speed_permille / 1000).max(1)
}

fn distance(a: (i32, i32), b: (i32, i32)) -> i64 {
    (a.0 as i64 - b.0 as i64).abs().max(a.1 as i64 - b.1 as i64)
}

async fn mark_busy(
    tx: &mut Transaction<'_, Postgres>,
    realm: &str,
    city_id: &str,
    until: i64,
    cmd: &str,
    action: &str,
) -> AppResult<()> {
    sqlx::query("UPDATE cities SET busy_until_ms=$3,busy_command_id=$4,busy_action=$5 WHERE realm_id=$1 AND city_id=$2")
        .bind(realm).bind(city_id).bind(until).bind(cmd).bind(action)
        .execute(&mut **tx).await.map_err(|e| AppError::Internal(e.to_string()))?;
    Ok(())
}

async fn clear_busy(
    tx: &mut Transaction<'_, Postgres>,
    realm: &str,
    city_id: &str,
) -> AppResult<()> {
    sqlx::query("UPDATE cities SET busy_until_ms=0,busy_command_id=NULL,busy_action='' WHERE realm_id=$1 AND city_id=$2")
        .bind(realm).bind(city_id).execute(&mut **tx).await.map_err(|e| AppError::Internal(e.to_string()))?;
    Ok(())
}

async fn bump_version(tx: &mut Transaction<'_, Postgres>, realm: &str) -> AppResult<i64> {
    let r: (i64,) = sqlx::query_as(
        "UPDATE realm_state SET version=version+1 WHERE realm_id=$1 RETURNING version",
    )
    .bind(realm)
    .fetch_one(&mut **tx)
    .await
    .map_err(|e| AppError::Internal(e.to_string()))?;
    Ok(r.0)
}

async fn delta(
    engine: &Engine,
    tx: &mut Transaction<'_, Postgres>,
    typ: &str,
    routing: EventRouting,
    payload: Value,
) -> AppResult<()> {
    engine
        .outbox(tx, typ, routing, payload)
        .await
        .map_err(|e| AppError::Internal(e.to_string()))
}

async fn owned_cities(
    tx: &mut Transaction<'_, Postgres>,
    realm: &str,
    player_id: &str,
) -> AppResult<Vec<CityRow>> {
    sqlx::query_as::<_, CityRow>(
        "SELECT city_id,player_id::text,name,x,y,is_capital,shield_until_ms,busy_until_ms,food,wood,stone,iron,gold,rem_food,rem_wood,rem_stone,rem_iron,rem_gold,last_accrued_ms FROM cities WHERE realm_id=$1 AND player_id=$2::uuid",
    ).bind(realm).bind(player_id).fetch_all(&mut **tx).await.map_err(|e| AppError::Internal(e.to_string()))
}

async fn item_qty(
    tx: &mut Transaction<'_, Postgres>,
    realm: &str,
    player_id: &str,
    key: &str,
) -> AppResult<i64> {
    let r: Option<(i64,)> = sqlx::query_as(
        "SELECT qty FROM items WHERE realm_id=$1 AND player_id=$2::uuid AND item_key=$3",
    )
    .bind(realm)
    .bind(player_id)
    .bind(key)
    .fetch_optional(&mut **tx)
    .await
    .map_err(|e| AppError::Internal(e.to_string()))?;
    Ok(r.map(|x| x.0).unwrap_or(0))
}

async fn use_item_unit(
    tx: &mut Transaction<'_, Postgres>,
    realm: &str,
    player_id: &str,
    key: &str,
) -> AppResult<()> {
    sqlx::query("UPDATE items SET qty=qty-1 WHERE realm_id=$1 AND player_id=$2::uuid AND item_key=$3 AND qty>0")
        .bind(realm).bind(player_id).bind(key).execute(&mut **tx).await.map_err(|e| AppError::Internal(e.to_string()))?;
    Ok(())
}

// ---------------------------------------------------------------- dispatch
/// Route a typed command to its handler inside a fenced transaction.
pub async fn dispatch(
    engine: &Engine,
    tx: &mut Transaction<'_, Postgres>,
    player_id: &str,
    payload: &CommandPayload,
) -> AppResult<()> {
    let action = payload
        .action
        .as_ref()
        .ok_or_else(|| AppError::Invalid("empty payload".into()))?;
    player_exists(tx, &engine.realm_id, player_id).await?;
    match action {
        Action::CreateCity(cmd) => create_city(engine, tx, player_id, cmd).await,
        Action::UpgradeBuilding(cmd) => upgrade_building(engine, tx, player_id, cmd).await,
        Action::StartResearch(cmd) => start_research(engine, tx, player_id, cmd).await,
        Action::TrainTroops(cmd) => train_troops(engine, tx, player_id, cmd).await,
        Action::HealTroops(cmd) => heal_troops(engine, tx, player_id, cmd).await,
        Action::UseItem(cmd) => use_item(engine, tx, player_id, cmd).await,
        Action::ScoutTile(cmd) => scout_tile(engine, tx, player_id, cmd).await,
        Action::AttackMonster(cmd) => attack_monster(engine, tx, player_id, cmd).await,
        Action::Gather(cmd) => gather(engine, tx, player_id, cmd).await,
        Action::AttackCity(cmd) => attack_city(engine, tx, player_id, cmd).await,
        Action::AttackFort(cmd) => attack_fort(engine, tx, player_id, cmd).await,
        Action::Reinforce(cmd) => reinforce(engine, tx, player_id, cmd).await,
        Action::Transport(cmd) => transport(engine, tx, player_id, cmd).await,
        Action::Recall(cmd) => recall(engine, tx, player_id, cmd).await,
        Action::SetShield(cmd) => set_shield(engine, tx, player_id, cmd).await,
        Action::SwitchCapital(cmd) => switch_capital(engine, tx, player_id, cmd).await,
        Action::RecruitHero(cmd) => recruit_hero(engine, tx, player_id, cmd).await,
        Action::DemolishBuilding(cmd) => demolish_building(engine, tx, player_id, cmd).await,
        Action::MarketBuy(cmd) => market_buy(engine, tx, player_id, cmd).await,
        Action::MarketSell(cmd) => market_sell(engine, tx, player_id, cmd).await,
        Action::CreateAlliance(cmd) => create_alliance(engine, tx, player_id, cmd).await,
        Action::AllianceInvite(cmd) => alliance_invite(engine, tx, player_id, cmd).await,
        Action::AllianceAccept(cmd) => alliance_accept(engine, tx, player_id, cmd).await,
        Action::AllianceJoin(cmd) => alliance_join(engine, tx, player_id, cmd).await,
        Action::AllianceLeave(_) => alliance_leave(engine, tx, player_id).await,
        Action::AllianceKick(cmd) => alliance_kick(engine, tx, player_id, cmd).await,
        Action::AllianceHelp(cmd) => alliance_help(engine, tx, player_id, cmd).await,
        Action::RallyCreate(cmd) => rally_create(engine, tx, player_id, cmd).await,
        Action::RallyJoin(cmd) => rally_join(engine, tx, player_id, cmd).await,
        Action::RallyCancel(cmd) => rally_cancel(engine, tx, player_id, cmd).await,
        Action::Chat(cmd) => chat(engine, tx, player_id, cmd).await,
    }
}

fn res_from_proto(r: Option<&kd_proto::Resources>) -> ResVec {
    match r {
        Some(r) => ResVec {
            food: r.food,
            wood: r.wood,
            stone: r.stone,
            iron: r.iron,
            gold: r.gold,
        },
        None => ResVec::default(),
    }
}

fn troops_from_proto(list: &[kd_proto::TroopSend]) -> AppResult<Vec<ArmyUnit>> {
    if list.is_empty() {
        return Err(AppError::Invalid("no troops specified".into()));
    }
    if list.len() > 100 {
        return Err(AppError::Invalid("too many troop stacks".into()));
    }
    let mut out = Vec::with_capacity(list.len());
    for t in list {
        if t.count == 0 || t.count > 10_000_000 || t.tier < 1 || t.tier > 3 {
            return Err(AppError::Invalid("invalid troop stack".into()));
        }
        content::unit(&t.unit, t.tier).ok_or_else(|| AppError::Invalid("unknown unit".into()))?;
        out.push(ArmyUnit {
            unit: t.unit.clone(),
            tier: t.tier,
            count: t.count as u64,
        });
    }
    Ok(out)
}
