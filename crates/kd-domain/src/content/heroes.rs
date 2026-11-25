//! Hero definitions and recruitment costs.
//!
//! Split out of `content.rs`; the parent module owns shared constants.
// ---------------------------------------------------------------- heroes
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
/// Static definition of one recruitable hero.
pub struct HeroDef {
    pub key: &'static str,
    pub name: &'static str,
    pub attack_bonus_permille: i64,
    pub defense_bonus_permille: i64,
    pub economy_bonus_permille: i64,
    pub speed_bonus_permille: i64,
    pub recruit_gold: i64,
}
pub static HEROES: [HeroDef; 6] = [
    HeroDef {
        key: "aurora",
        name: "Aurora",
        attack_bonus_permille: 80,
        defense_bonus_permille: 20,
        economy_bonus_permille: 40,
        speed_bonus_permille: 0,
        recruit_gold: 1200,
    },
    HeroDef {
        key: "borin",
        name: "Borin",
        attack_bonus_permille: 30,
        defense_bonus_permille: 110,
        economy_bonus_permille: 10,
        speed_bonus_permille: 0,
        recruit_gold: 1000,
    },
    HeroDef {
        key: "cinder",
        name: "Cinder",
        attack_bonus_permille: 140,
        defense_bonus_permille: 10,
        economy_bonus_permille: 0,
        speed_bonus_permille: 20,
        recruit_gold: 1800,
    },
    HeroDef {
        key: "dalia",
        name: "Dalia",
        attack_bonus_permille: 20,
        defense_bonus_permille: 40,
        economy_bonus_permille: 130,
        speed_bonus_permille: 10,
        recruit_gold: 1500,
    },
    HeroDef {
        key: "eorin",
        name: "Eorin",
        attack_bonus_permille: 60,
        defense_bonus_permille: 60,
        economy_bonus_permille: 30,
        speed_bonus_permille: 60,
        recruit_gold: 1600,
    },
    HeroDef {
        key: "faye",
        name: "Faye",
        attack_bonus_permille: 100,
        defense_bonus_permille: 30,
        economy_bonus_permille: 60,
        speed_bonus_permille: 40,
        recruit_gold: 1700,
    },
];
/// Look up a hero by key.
pub fn hero(key: &str) -> Option<&'static HeroDef> {
    HEROES.iter().find(|h| h.key == key)
}
