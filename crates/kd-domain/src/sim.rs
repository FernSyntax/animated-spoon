//! Deterministic, versioned combat resolution. Same inputs => same outputs.
//! Uses integer arithmetic throughout; a seeded xorshift adds bounded variance.
use crate::content::{unit, ResVec, RESOURCES};
use serde::{Deserialize, Serialize};

/// Increment when combat math changes so old reports stay interpretable.
pub const COMBAT_VERSION: u32 = 1;

#[derive(Clone, Debug, PartialEq, Eq, Serialize, Deserialize)]
/// One unit stack participating in combat.
pub struct ArmyUnit {
    pub unit: String,
    pub tier: u32,
    pub count: u64,
}

#[derive(Clone, Debug, Serialize, Deserialize)]
/// Fully deterministic input to the combat simulator.
pub struct CombatInput {
    pub attackers: Vec<ArmyUnit>,
    pub defenders: Vec<ArmyUnit>,
    pub attacker_attack_permille: i64,
    pub attacker_defense_permille: i64,
    pub defender_attack_permille: i64,
    pub defender_defense_permille: i64,
    pub wall_level: i32,
    pub terrain_defense_permille: i64,
    pub attacker_hero_level: i32,
    pub defender_hero_level: i32,
    pub defender_resources: ResVec,
    pub seed: u64,
}

#[derive(Clone, Debug, PartialEq, Eq, Serialize, Deserialize)]
/// Survivors, casualties, loot and winner of a combat resolution.
pub struct CombatOutcome {
    pub attacker_won: bool,
    pub attacker_power: i128,
    pub defender_power: i128,
    pub attacker_losses: Vec<ArmyUnit>,
    pub defender_losses: Vec<ArmyUnit>,
    pub attacker_wounded: Vec<ArmyUnit>,
    pub defender_wounded: Vec<ArmyUnit>,
    pub loot: ResVec,
    pub seed: u64,
}

fn hash_u64(x: u64) -> u64 {
    let mut z = x.wrapping_add(0x9E37_79B9_7F4A_7C15);
    z = (z ^ (z >> 30)).wrapping_mul(0xBF58_476D_1CE4_E5B9);
    z = (z ^ (z >> 27)).wrapping_mul(0x94D0_49BB_1331_11EB);
    z ^ (z >> 31)
}

fn canonical_seed(input: &CombatInput) -> u64 {
    let mut h = input.seed;
    let mut feed = |s: &str, v: u64| {
        for b in s.bytes() {
            h = hash_u64(h ^ b as u64);
        }
        h = hash_u64(h ^ v);
    };
    let mut atk = input.attackers.clone();
    let mut def = input.defenders.clone();
    atk.sort_by(|a, b| (&a.unit, a.tier).cmp(&(&b.unit, b.tier)));
    def.sort_by(|a, b| (&a.unit, a.tier).cmp(&(&b.unit, b.tier)));
    for u in atk {
        feed(&u.unit, u.count);
        feed("tier", u.tier as u64);
    }
    for u in def {
        feed(&u.unit, u.count);
        feed("tier", u.tier as u64);
    }
    h
}

struct Rng(u64);
impl Rng {
    fn next(&mut self) -> u64 {
        let mut x = self.0;
        x ^= x << 13;
        x ^= x >> 7;
        x ^= x << 17;
        self.0 = x;
        x
    }
    fn permille_jitter(&mut self) -> i64 {
        // 950..1050
        950 + (self.next() % 101) as i64
    }
}

fn matchup(atk: &str, def: &str) -> i64 {
    match (atk, def) {
        ("infantry", "cavalry") => 1250,
        ("ranged", "infantry") => 1200,
        ("cavalry", "ranged") => 1250,
        ("siege", "infantry") => 1150,
        ("siege", "ranged") => 1150,
        ("scout", _) => 200,
        _ => 1000,
    }
}

fn dominant(units: &[ArmyUnit]) -> &str {
    let mut best = "infantry";
    let mut best_n = 0u64;
    for u in units {
        if u.unit != "scout" && u.count > best_n {
            best_n = u.count;
            best = &u.unit;
        }
    }
    best
}

fn raw_power(
    units: &[ArmyUnit],
    use_attack: bool,
    bonus_permille: i64,
    hero_level: i32,
    against: &str,
) -> i128 {
    let hero = 1000 + hero_level as i128 * 20;
    let mut total = 0i128;
    for u in units {
        if let Some(d) = unit(&u.unit, u.tier) {
            let stat = if use_attack { d.attack } else { d.defense };
            total += u.count as i128
                * stat as i128
                * matchup(&u.unit, against) as i128
                * bonus_permille as i128
                * hero
                / (1000i128 * 1000i128 * 1000i128);
        }
    }
    total
}

fn apply_losses(
    units: &[ArmyUnit],
    loss_permille: i64,
    rng: &mut Rng,
    wounded_cap: u64,
) -> (Vec<ArmyUnit>, Vec<ArmyUnit>) {
    let mut losses = Vec::new();
    let mut wounded = Vec::new();
    let mut cap = wounded_cap;
    for u in units {
        if let Some(d) = unit(&u.unit, u.tier) {
            let jitter = rng.permille_jitter();
            let p = (loss_permille * jitter / 1000).clamp(0, 1000);
            let n = (u.count as i128 * p as i128 / 1000) as u64;
            let n = n.min(u.count);
            let w = n.min(cap).min(n * 700 / 1000);
            cap = cap.saturating_sub(w);
            if n > 0 {
                losses.push(ArmyUnit {
                    unit: u.unit.clone(),
                    tier: u.tier,
                    count: n,
                });
            }
            if w > 0 {
                wounded.push(ArmyUnit {
                    unit: u.unit.clone(),
                    tier: u.tier,
                    count: w,
                });
            }
            let _ = d;
        }
    }
    (losses, wounded)
}

fn sub_units(base: &[ArmyUnit], losses: &[ArmyUnit]) -> Vec<ArmyUnit> {
    base.iter()
        .map(|u| {
            let lost = losses
                .iter()
                .find(|l| l.unit == u.unit && l.tier == u.tier)
                .map(|l| l.count)
                .unwrap_or(0);
            ArmyUnit {
                unit: u.unit.clone(),
                tier: u.tier,
                count: u.count.saturating_sub(lost),
            }
        })
        .filter(|u| u.count > 0)
        .collect()
}

/// Resolve a battle deterministically.
pub fn resolve(input: &CombatInput) -> CombatOutcome {
    let seed = canonical_seed(input);
    let mut rng = Rng(seed);
    let atk_dom = dominant(&input.defenders);
    let def_dom = dominant(&input.attackers);
    let wall = input.wall_level as i64 * 80;
    let attacker_power = raw_power(
        &input.attackers,
        true,
        input.attacker_attack_permille,
        input.attacker_hero_level,
        atk_dom,
    );
    let defender_power = raw_power(
        &input.defenders,
        false,
        input.defender_defense_permille + wall + input.terrain_defense_permille,
        input.defender_hero_level,
        def_dom,
    );
    // Defender wins ties (stable).
    let attacker_won = attacker_power > defender_power;
    let (winner, loser) = if attacker_won {
        (attacker_power, defender_power)
    } else {
        (defender_power, attacker_power)
    };
    let ratio = winner.saturating_mul(1000).max(1) / loser.max(1);

    let loser_loss = (300 + (ratio - 1000) / 2).clamp(300, 950) as i64;
    let winner_loss = (100 + (ratio - 1000) / 8).clamp(80, 400) as i64;

    let (atk_losses, atk_wounded) = if attacker_won {
        apply_losses(&input.attackers, winner_loss, &mut rng, 100_000)
    } else {
        apply_losses(&input.attackers, loser_loss, &mut rng, 100_000)
    };
    let (def_losses, def_wounded) = if attacker_won {
        apply_losses(&input.defenders, loser_loss, &mut rng, 1_000_000)
    } else {
        apply_losses(&input.defenders, winner_loss, &mut rng, 1_000_000)
    };

    let mut loot = ResVec::default();
    if attacker_won {
        let mut carry: i64 = 0;
        for u in &input.attackers {
            if let Some(d) = unit(&u.unit, u.tier) {
                carry += u.count.saturating_sub(
                    atk_losses
                        .iter()
                        .find(|l| l.unit == u.unit && l.tier == u.tier)
                        .map(|l| l.count)
                        .unwrap_or(0),
                ) as i64
                    * d.carry;
            }
        }
        let mut remaining = carry;
        for &r in &RESOURCES {
            let available = input.defender_resources.get(r).max(0);
            let take = (available / 5).min(remaining).max(0);
            loot.set(r, take);
            remaining -= take;
            if remaining <= 0 {
                break;
            }
        }
    }

    let _ = sub_units; // exposed for callers applying survivors
    CombatOutcome {
        attacker_won,
        attacker_power,
        defender_power,
        attacker_losses: atk_losses,
        defender_losses: def_losses,
        attacker_wounded: atk_wounded,
        defender_wounded: def_wounded,
        loot,
        seed,
    }
}

/// Apply outcome losses to a side, returning surviving aggregates.
pub fn survivors(army: &[ArmyUnit], losses: &[ArmyUnit]) -> Vec<ArmyUnit> {
    sub_units(army, losses)
}

#[cfg(test)]
mod tests {
    use super::*;

    fn army(unit: &str, tier: u32, count: u64) -> Vec<ArmyUnit> {
        vec![ArmyUnit {
            unit: unit.into(),
            tier,
            count,
        }]
    }
    fn base(atk: Vec<ArmyUnit>, def: Vec<ArmyUnit>) -> CombatInput {
        CombatInput {
            attackers: atk,
            defenders: def,
            attacker_attack_permille: 1000,
            attacker_defense_permille: 1000,
            defender_attack_permille: 1000,
            defender_defense_permille: 1000,
            wall_level: 0,
            terrain_defense_permille: 0,
            attacker_hero_level: 0,
            defender_hero_level: 0,
            defender_resources: ResVec {
                food: 10000,
                wood: 10000,
                stone: 10000,
                iron: 5000,
                gold: 5000,
            },
            seed: 42,
        }
    }

    #[test]
    fn identical_inputs_replay_identically() {
        let a = base(army("infantry", 1, 100), army("infantry", 1, 100));
        let b = a.clone();
        assert_eq!(resolve(&a), resolve(&b));
    }

    #[test]
    fn weak_army_loses() {
        let out = resolve(&base(army("infantry", 1, 10), army("infantry", 3, 500)));
        assert!(!out.attacker_won);
        assert_eq!(out.loot, ResVec::default());
    }

    #[test]
    fn strong_army_wins_and_loots() {
        let out = resolve(&base(army("cavalry", 3, 1000), army("scout", 1, 5)));
        assert!(out.attacker_won);
        assert!(out.loot.food > 0);
    }

    #[test]
    fn wall_and_hero_modifiers_matter() {
        let mut input = base(army("infantry", 3, 100), army("infantry", 3, 100));
        let plain = resolve(&input);
        input.wall_level = 15;
        input.defender_hero_level = 20;
        let fortified = resolve(&input);
        assert!(fortified.defender_power > plain.defender_power);
        assert!(!fortified.attacker_won);
    }

    proptest::proptest! {
        #[test]
        fn survivors_never_exceed_original(a in 0u64..10000, l in 0u64..10000) {
            let units = army("infantry", 1, a);
            let losses = army("infantry", 1, l);
            let s = survivors(&units, &losses);
            let n = s.iter().map(|u| u.count).sum::<u64>();
            assert!(n <= a);
        }
    }
}
