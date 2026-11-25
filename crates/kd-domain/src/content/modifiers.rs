//! Aggregation of building, research and hero bonuses.
//!
//! Split out of `content.rs`; the parent module owns shared constants.
use super::*;

// ---------------------------------------------------------------- modifiers
#[derive(Clone, Copy, Debug, Default, PartialEq, Eq, Serialize, Deserialize)]
/// Aggregated permille bonuses applied to economy and combat.
pub struct Modifiers {
    pub food_prod: i64, // per hour, scaled by 1000
    pub wood_prod: i64,
    pub stone_prod: i64,
    pub iron_prod: i64,
    pub gold_prod: i64,
    pub capacity: i64,
    pub attack_permille: i64,
    pub defense_permille: i64,
    pub speed_permille: i64,
    pub march_capacity: i32,
    pub training_speed_permille: i64,
    pub research_speed_permille: i64,
    pub heal_speed_permille: i64,
    pub wounded_capacity: i64,
    pub rally_capacity: i64,
}

/// Aggregate building levels, research levels and hero bonuses into modifiers.
pub fn compute_modifiers(
    buildings: &HashMap<String, i32>,
    research: &HashMap<String, i32>,
    hero_attack: i64,
    hero_defense: i64,
    hero_economy: i64,
    hero_speed: i64,
) -> Modifiers {
    let lv = |k: &str| *buildings.get(k).unwrap_or(&0);
    let rl = |k: &str| *research.get(k).unwrap_or(&0);
    let th = lv("town_hall");
    let mut m = Modifiers {
        food_prod: 2000 + th as i64 * 600 + lv("farm") as i64 * 900,
        wood_prod: 1500 + th as i64 * 450 + lv("lumber_mill") as i64 * 800,
        stone_prod: 900 + th as i64 * 300 + lv("quarry") as i64 * 650,
        iron_prod: 500 + th as i64 * 180 + lv("iron_mine") as i64 * 500,
        gold_prod: 300 + th as i64 * 120 + lv("market") as i64 * 500,
        capacity: 50_000 + th as i64 * 20_000 + lv("warehouse") as i64 * 60_000,
        attack_permille: 1000,
        defense_permille: 1000,
        speed_permille: 1000,
        march_capacity: 1 + th / 4,
        training_speed_permille: 1000,
        research_speed_permille: 1000,
        heal_speed_permille: 1000,
        wounded_capacity: 2000 + lv("hospital") as i64 * 4000,
        rally_capacity: 10_000 + lv("embassy") as i64 * 20_000,
    };
    // research effects
    m.food_prod += rl("agriculture") as i64 * 1200;
    m.wood_prod += rl("forestry") as i64 * 1000;
    m.stone_prod += rl("masonry") as i64 * 700;
    m.iron_prod += rl("metallurgy") as i64 * 600;
    m.gold_prod += rl("commerce") as i64 * 700;
    m.speed_permille += rl("pathfinding") as i64 * 100 + rl("logistics") as i64 * 150;
    m.march_capacity += rl("logistics") as i64 as i32;
    m.attack_permille += rl("drill") as i64 * 70
        + rl("tactics") as i64 * 90
        + rl("ironworking") as i64 * 60
        + rl("siege_craft") as i64 * 80;
    m.defense_permille += rl("fortification") as i64 * 120;
    m.training_speed_permille += rl("drill") as i64 * 60;
    m.research_speed_permille += rl("logistics") as i64 * 40;
    m.heal_speed_permille += rl("medicine") as i64 * 150;
    m.wounded_capacity += rl("medicine") as i64 * 5000;
    // building effects
    m.defense_permille += lv("wall") as i64 * 80;
    m.wounded_capacity += lv("hospital") as i64 * 3000;
    m.rally_capacity += lv("embassy") as i64 * 5000;
    // hero bonuses (permille), scaled a little by level later by caller if desired
    m.attack_permille += hero_attack;
    m.defense_permille += hero_defense;
    m.gold_prod += hero_economy * 8;
    m.food_prod += hero_economy * 8;
    m.speed_permille += hero_speed;
    m
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::collections::HashMap;

    fn research(key: &str, level: i32) -> HashMap<String, i32> {
        let mut r = HashMap::new();
        r.insert(key.to_string(), level);
        r
    }

    #[test]
    fn research_production_techs_change_the_economy() {
        let base = compute_modifiers(&HashMap::new(), &HashMap::new(), 0, 0, 0, 0);
        assert!(
            compute_modifiers(&HashMap::new(), &research("agriculture", 3), 0, 0, 0, 0).food_prod
                > base.food_prod
        );
        assert!(
            compute_modifiers(&HashMap::new(), &research("forestry", 3), 0, 0, 0, 0).wood_prod
                > base.wood_prod
        );
        assert!(
            compute_modifiers(&HashMap::new(), &research("metallurgy", 2), 0, 0, 0, 0).iron_prod
                > base.iron_prod
        );
        assert!(
            compute_modifiers(&HashMap::new(), &research("commerce", 2), 0, 0, 0, 0).gold_prod
                > base.gold_prod
        );
    }

    #[test]
    fn research_combat_and_support_techs_change_modifiers() {
        let base = compute_modifiers(&HashMap::new(), &HashMap::new(), 0, 0, 0, 0);
        let drill = compute_modifiers(&HashMap::new(), &research("drill", 2), 0, 0, 0, 0);
        assert!(drill.attack_permille > base.attack_permille);
        assert!(drill.training_speed_permille > base.training_speed_permille);
        let fort = compute_modifiers(&HashMap::new(), &research("fortification", 2), 0, 0, 0, 0);
        assert!(fort.defense_permille > base.defense_permille);
        let med = compute_modifiers(&HashMap::new(), &research("medicine", 2), 0, 0, 0, 0);
        assert!(med.heal_speed_permille > base.heal_speed_permille);
        assert!(med.wounded_capacity > base.wounded_capacity);
        let log = compute_modifiers(&HashMap::new(), &research("logistics", 2), 0, 0, 0, 0);
        assert!(log.speed_permille > base.speed_permille);
        assert!(log.march_capacity > base.march_capacity);
    }

    #[test]
    fn buildings_and_heroes_stack_with_research() {
        let mut buildings = HashMap::new();
        buildings.insert("wall".to_string(), 5);
        buildings.insert("hospital".to_string(), 3);
        let plain = compute_modifiers(&HashMap::new(), &HashMap::new(), 0, 0, 0, 0);
        let built = compute_modifiers(&buildings, &HashMap::new(), 50, 20, 0, 0);
        assert!(built.defense_permille > plain.defense_permille);
        assert!(built.wounded_capacity > plain.wounded_capacity);
        assert!(built.attack_permille > plain.attack_permille);
    }
}
