//! Consumable item definitions.
//!
//! Split out of `content.rs`; the parent module owns shared constants.
use super::*;

// ---------------------------------------------------------------- items
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
/// Static definition of one consumable item.
pub struct ItemDef {
    pub key: &'static str,
    pub name: &'static str,
    pub speedup_secs: i64,
    pub resource: ResVec,
    pub shield_hours: i64,
    pub price_gold: i64,
}
pub static ITEMS: [ItemDef; 6] = [
    ItemDef {
        key: "bundle_small",
        name: "Small Supply Bundle",
        speedup_secs: 0,
        resource: rv(5000, 5000, 3000, 1000, 500),
        shield_hours: 0,
        price_gold: 1000,
    },
    ItemDef {
        key: "bundle_large",
        name: "Large Supply Bundle",
        speedup_secs: 0,
        resource: rv(50000, 50000, 30000, 10000, 5000),
        shield_hours: 0,
        price_gold: 8000,
    },
    ItemDef {
        key: "speed_5m",
        name: "5 Minute Speedup",
        speedup_secs: 300,
        resource: rv(0, 0, 0, 0, 0),
        shield_hours: 0,
        price_gold: 200,
    },
    ItemDef {
        key: "speed_1h",
        name: "1 Hour Speedup",
        speedup_secs: 3600,
        resource: rv(0, 0, 0, 0, 0),
        shield_hours: 0,
        price_gold: 1500,
    },
    ItemDef {
        key: "shield_1d",
        name: "1 Day Shield",
        speedup_secs: 0,
        resource: rv(0, 0, 0, 0, 0),
        shield_hours: 24,
        price_gold: 2500,
    },
    ItemDef {
        key: "scout_kit",
        name: "Scout Kit",
        speedup_secs: 0,
        resource: rv(0, 0, 0, 0, 0),
        shield_hours: 0,
        price_gold: 300,
    },
];
/// Look up an item by key.
pub fn item(key: &str) -> Option<&'static ItemDef> {
    ITEMS.iter().find(|i| i.key == key)
}
/// Fixed gold price of one unit; the market sells back at half this value.
pub fn item_price(key: &str) -> Option<i64> {
    item(key).map(|def| def.price_gold)
}
