//! Resource kinds and the checked, saturating resource vector.
//!
//! Split out of `content.rs`; the parent module owns shared constants.
use super::*;

// ---------------------------------------------------------------- resources
#[derive(Clone, Copy, Debug, PartialEq, Eq, Hash, Serialize, Deserialize)]
/// The five resources produced and consumed by the economy.
pub enum Resource {
    Food,
    Wood,
    Stone,
    Iron,
    Gold,
}

/// All resources in canonical display order.
pub const RESOURCES: [Resource; 5] = [
    Resource::Food,
    Resource::Wood,
    Resource::Stone,
    Resource::Iron,
    Resource::Gold,
];

impl Resource {
    pub fn key(self) -> &'static str {
        match self {
            Resource::Food => "food",
            Resource::Wood => "wood",
            Resource::Stone => "stone",
            Resource::Iron => "iron",
            Resource::Gold => "gold",
        }
    }
    pub fn parse(s: &str) -> Option<Self> {
        match s {
            "food" => Some(Resource::Food),
            "wood" => Some(Resource::Wood),
            "stone" => Some(Resource::Stone),
            "iron" => Some(Resource::Iron),
            "gold" => Some(Resource::Gold),
            _ => None,
        }
    }
}

/// Integer vector. All operations are checked and saturating at i64::MAX/0.
#[derive(Clone, Copy, Debug, Default, PartialEq, Eq, Serialize, Deserialize)]
/// Fixed-size integer vector of resources with saturating arithmetic.
pub struct ResVec {
    pub food: i64,
    pub wood: i64,
    pub stone: i64,
    pub iron: i64,
    pub gold: i64,
}

impl ResVec {
    pub fn get(self, r: Resource) -> i64 {
        match r {
            Resource::Food => self.food,
            Resource::Wood => self.wood,
            Resource::Stone => self.stone,
            Resource::Iron => self.iron,
            Resource::Gold => self.gold,
        }
    }
    pub fn set(&mut self, r: Resource, v: i64) {
        match r {
            Resource::Food => self.food = v,
            Resource::Wood => self.wood = v,
            Resource::Stone => self.stone = v,
            Resource::Iron => self.iron = v,
            Resource::Gold => self.gold = v,
        }
    }
    pub fn add_checked(self, other: ResVec) -> Option<ResVec> {
        Some(ResVec {
            food: self.food.checked_add(other.food)?,
            wood: self.wood.checked_add(other.wood)?,
            stone: self.stone.checked_add(other.stone)?,
            iron: self.iron.checked_add(other.iron)?,
            gold: self.gold.checked_add(other.gold)?,
        })
    }
    pub fn sub_checked(self, other: ResVec) -> Option<ResVec> {
        Some(ResVec {
            food: self.food.checked_sub(other.food)?,
            wood: self.wood.checked_sub(other.wood)?,
            stone: self.stone.checked_sub(other.stone)?,
            iron: self.iron.checked_sub(other.iron)?,
            gold: self.gold.checked_sub(other.gold)?,
        })
    }
    pub fn can_afford(self, cost: ResVec) -> bool {
        RESOURCES.iter().all(|&r| self.get(r) >= cost.get(r))
    }
    pub fn saturating_cap(self, cap: ResVec) -> ResVec {
        ResVec {
            food: self.food.min(cap.food),
            wood: self.wood.min(cap.wood),
            stone: self.stone.min(cap.stone),
            iron: self.iron.min(cap.iron),
            gold: self.gold.min(cap.gold),
        }
    }
    pub fn is_nonnegative(self) -> bool {
        RESOURCES.iter().all(|&r| self.get(r) >= 0)
    }
}
