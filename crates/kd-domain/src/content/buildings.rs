//! Building definitions, costs and construction times.
//!
//! Split out of `content.rs`; the parent module owns shared constants.
use super::*;

// ---------------------------------------------------------------- buildings
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
/// Static definition of one building type.
pub struct BuildingDef {
    pub key: &'static str,
    pub name: &'static str,
    pub base_cost: ResVec,
    pub cost_growth: u32, // permille, e.g. 1350 => 1.35x per level
    pub base_time_secs: i64,
    pub time_growth: u32,
    pub requires: Option<(&'static str, i32)>,
}

pub(crate) const fn rv(food: i64, wood: i64, stone: i64, iron: i64, gold: i64) -> ResVec {
    ResVec {
        food,
        wood,
        stone,
        iron,
        gold,
    }
}

pub static BUILDINGS: [BuildingDef; 12] = [
    BuildingDef {
        key: "town_hall",
        name: "Town Hall",
        base_cost: rv(0, 400, 300, 100, 200),
        cost_growth: 1550,
        base_time_secs: 30,
        time_growth: 1500,
        requires: None,
    },
    BuildingDef {
        key: "farm",
        name: "Farm",
        base_cost: rv(0, 120, 40, 0, 20),
        cost_growth: 1350,
        base_time_secs: 12,
        time_growth: 1300,
        requires: Some(("town_hall", 1)),
    },
    BuildingDef {
        key: "lumber_mill",
        name: "Lumber Mill",
        base_cost: rv(0, 150, 50, 0, 20),
        cost_growth: 1350,
        base_time_secs: 12,
        time_growth: 1300,
        requires: Some(("town_hall", 1)),
    },
    BuildingDef {
        key: "quarry",
        name: "Quarry",
        base_cost: rv(30, 120, 80, 0, 20),
        cost_growth: 1380,
        base_time_secs: 14,
        time_growth: 1320,
        requires: Some(("town_hall", 2)),
    },
    BuildingDef {
        key: "iron_mine",
        name: "Iron Mine",
        base_cost: rv(40, 140, 90, 20, 30),
        cost_growth: 1400,
        base_time_secs: 16,
        time_growth: 1350,
        requires: Some(("town_hall", 3)),
    },
    BuildingDef {
        key: "market",
        name: "Market",
        base_cost: rv(0, 220, 120, 0, 60),
        cost_growth: 1420,
        base_time_secs: 18,
        time_growth: 1350,
        requires: Some(("town_hall", 3)),
    },
    BuildingDef {
        key: "warehouse",
        name: "Warehouse",
        base_cost: rv(0, 260, 180, 40, 60),
        cost_growth: 1450,
        base_time_secs: 20,
        time_growth: 1380,
        requires: Some(("town_hall", 2)),
    },
    BuildingDef {
        key: "barracks",
        name: "Barracks",
        base_cost: rv(100, 300, 180, 60, 80),
        cost_growth: 1480,
        base_time_secs: 24,
        time_growth: 1400,
        requires: Some(("town_hall", 2)),
    },
    BuildingDef {
        key: "academy",
        name: "Academy",
        base_cost: rv(80, 280, 200, 80, 100),
        cost_growth: 1480,
        base_time_secs: 26,
        time_growth: 1400,
        requires: Some(("town_hall", 3)),
    },
    BuildingDef {
        key: "wall",
        name: "Wall",
        base_cost: rv(0, 180, 320, 120, 60),
        cost_growth: 1500,
        base_time_secs: 22,
        time_growth: 1400,
        requires: Some(("town_hall", 2)),
    },
    BuildingDef {
        key: "hospital",
        name: "Hospital",
        base_cost: rv(120, 240, 160, 60, 90),
        cost_growth: 1450,
        base_time_secs: 22,
        time_growth: 1380,
        requires: Some(("town_hall", 4)),
    },
    BuildingDef {
        key: "embassy",
        name: "Embassy / Rally Hall",
        base_cost: rv(100, 260, 200, 80, 120),
        cost_growth: 1450,
        base_time_secs: 24,
        time_growth: 1400,
        requires: Some(("town_hall", 4)),
    },
];

/// Look up a building definition by key.
pub fn building(key: &str) -> Option<&'static BuildingDef> {
    BUILDINGS.iter().find(|b| b.key == key)
}

fn grow(base: i64, growth: u32, level: i32) -> i64 {
    // (growth/1000)^(level-1), computed with integer math and capped.
    let mut v = base;
    for _ in 1..level.max(1) {
        v = v.saturating_mul(growth as i64) / 1000;
    }
    v.max(1)
}

/// Cost of upgrading `key` to `next_level`, if the level is valid.
pub fn building_cost(key: &str, next_level: i32) -> Option<ResVec> {
    let b = building(key)?;
    if !(1..=MAX_CITY_LEVEL).contains(&next_level) {
        return None;
    }
    let g = |r: Resource| grow(b.base_cost.get(r), b.cost_growth, next_level);
    Some(rv(
        g(Resource::Food),
        g(Resource::Wood),
        g(Resource::Stone),
        g(Resource::Iron),
        g(Resource::Gold),
    ))
}

/// Construction time in seconds for the next level.
pub fn building_time(key: &str, next_level: i32) -> Option<i64> {
    let b = building(key)?;
    if !(1..=MAX_CITY_LEVEL).contains(&next_level) {
        return None;
    }
    Some(grow(b.base_time_secs, b.time_growth, next_level))
}
