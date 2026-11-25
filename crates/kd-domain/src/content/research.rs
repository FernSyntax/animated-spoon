//! Technology definitions, costs and research times.
//!
//! Split out of `content.rs`; the parent module owns shared constants.
use super::*;

// ---------------------------------------------------------------- research
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
/// Static definition of one technology.
pub struct TechDef {
    pub key: &'static str,
    pub name: &'static str,
    pub base_cost: ResVec,
    pub base_time_secs: i64,
    pub requires: Option<(&'static str, i32)>,
}

pub static TECHS: [TechDef; 14] = [
    TechDef {
        key: "agriculture",
        name: "Agriculture",
        base_cost: rv(0, 200, 80, 0, 120),
        base_time_secs: 20,
        requires: None,
    },
    TechDef {
        key: "forestry",
        name: "Forestry",
        base_cost: rv(0, 240, 100, 0, 120),
        base_time_secs: 20,
        requires: None,
    },
    TechDef {
        key: "masonry",
        name: "Masonry",
        base_cost: rv(0, 200, 200, 40, 140),
        base_time_secs: 24,
        requires: None,
    },
    TechDef {
        key: "metallurgy",
        name: "Metallurgy",
        base_cost: rv(60, 180, 180, 120, 160),
        base_time_secs: 28,
        requires: Some(("masonry", 1)),
    },
    TechDef {
        key: "commerce",
        name: "Commerce",
        base_cost: rv(0, 220, 120, 0, 200),
        base_time_secs: 26,
        requires: Some(("market", 1)),
    },
    TechDef {
        key: "pathfinding",
        name: "Pathfinding",
        base_cost: rv(0, 180, 100, 0, 120),
        base_time_secs: 18,
        requires: None,
    },
    TechDef {
        key: "logistics",
        name: "Logistics",
        base_cost: rv(80, 240, 140, 40, 160),
        base_time_secs: 24,
        requires: Some(("pathfinding", 1)),
    },
    TechDef {
        key: "cartography",
        name: "Cartography",
        base_cost: rv(60, 200, 140, 40, 180),
        base_time_secs: 26,
        requires: Some(("pathfinding", 2)),
    },
    TechDef {
        key: "drill",
        name: "Drill",
        base_cost: rv(160, 200, 80, 60, 140),
        base_time_secs: 22,
        requires: Some(("barracks", 1)),
    },
    TechDef {
        key: "ironworking",
        name: "Ironworking",
        base_cost: rv(100, 180, 200, 140, 180),
        base_time_secs: 30,
        requires: Some(("metallurgy", 1)),
    },
    TechDef {
        key: "siege_craft",
        name: "Siege Craft",
        base_cost: rv(140, 260, 220, 160, 220),
        base_time_secs: 34,
        requires: Some(("ironworking", 1)),
    },
    TechDef {
        key: "tactics",
        name: "Tactics",
        base_cost: rv(160, 200, 140, 80, 240),
        base_time_secs: 32,
        requires: Some(("drill", 2)),
    },
    TechDef {
        key: "fortification",
        name: "Fortification",
        base_cost: rv(80, 220, 280, 120, 160),
        base_time_secs: 28,
        requires: Some(("masonry", 1)),
    },
    TechDef {
        key: "medicine",
        name: "Medicine",
        base_cost: rv(140, 180, 100, 40, 180),
        base_time_secs: 26,
        requires: Some(("academy", 2)),
    },
];

// Some tech prerequisites are buildings; handled by requires_building helper.
/// Look up a technology by key.
pub fn tech(key: &str) -> Option<&'static TechDef> {
    TECHS.iter().find(|t| t.key == key)
}
/// Cost of researching `key` to `level`.
pub fn tech_cost(key: &str, level: i32) -> Option<ResVec> {
    let t = tech(key)?;
    if !(1..=3).contains(&level) {
        return None;
    }
    let m = [1000i64, 1800, 3200][(level - 1) as usize];
    Some(ResVec {
        food: t.base_cost.food * m / 1000,
        wood: t.base_cost.wood * m / 1000,
        stone: t.base_cost.stone * m / 1000,
        iron: t.base_cost.iron * m / 1000,
        gold: t.base_cost.gold * m / 1000,
    })
}
/// Research duration in seconds for the given level.
pub fn tech_time(key: &str, level: i32) -> Option<i64> {
    let t = tech(key)?;
    if !(1..=3).contains(&level) {
        return None;
    }
    Some(t.base_time_secs * [1000i64, 1900, 3400][(level - 1) as usize] / 1000)
}
/// Whether a tech key actually refers to a building prerequisite.
pub fn is_building_prereq(key: &str) -> bool {
    matches!(key, "market" | "barracks" | "academy")
}
