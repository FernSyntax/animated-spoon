//! Versioned, validated static content catalogs. All numeric effects are
//! integers; no floats are used for authoritative quantities.
use serde::{Deserialize, Serialize};
use std::collections::HashMap;

// Catalog data is grouped by domain; the public API is unchanged.
mod buildings;
mod heroes;
mod items;
mod modifiers;
mod research;
mod resources;
mod troops;

pub use buildings::*;
pub use heroes::*;
pub use items::*;
pub use modifiers::*;
pub use research::*;
pub use resources::*;
pub use troops::*;

/// Increment whenever a content constant changes incompatibly.
pub const CONTENT_VERSION: u32 = 1;
/// Highest level attainable by any building.
pub const MAX_CITY_LEVEL: i32 = 20;
/// Hard cap on troop count per city.
pub const MAX_TROOPS_PER_CITY: u64 = 2_000_000;
/// Side length of the square world, in tiles.
pub const WORLD_SIZE: i32 = 2048;
/// Side length of a subscription chunk, in tiles.
pub const CHUNK_SIZE: i32 = 32;
/// Maximum number of cities a player may found.
pub const MAX_CITIES_PER_PLAYER: usize = 6;
