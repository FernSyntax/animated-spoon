//! Serializable snapshots shared by engine, gateways and client.
use crate::content::ResVec;
use crate::sim::ArmyUnit;
use crate::world::{EntityKind, Terrain};
use serde::{Deserialize, Serialize};
use std::collections::HashMap;

#[derive(Clone, Debug, Serialize, Deserialize)]
/// Authoritative city state exposed to the owning player.
pub struct CitySnapshot {
    pub id: String,
    pub name: String,
    pub x: i32,
    pub y: i32,
    pub is_capital: bool,
    pub buildings: HashMap<String, i32>,
    pub resources: ResVec,
    pub rates_per_hour: ResVec,
    pub capacity: ResVec,
    pub troops: Vec<ArmyUnit>,
    pub wounded: Vec<ArmyUnit>,
    pub shield_until_ms: i64,
    pub busy_until_ms: i64,
    pub busy_action: String,
    pub busy_target: String,
}

#[derive(Clone, Debug, Serialize, Deserialize)]
/// Authoritative march state exposed to the owning player.
pub struct MarchSnapshot {
    pub id: String,
    pub mission: String,
    pub state: String,
    pub from_city_id: String,
    pub from: (i32, i32),
    pub to: (i32, i32),
    pub target_id: String,
    pub depart_at_ms: i64,
    pub arrive_at_ms: i64,
    pub troops: Vec<ArmyUnit>,
    pub hero: String,
    pub resources: ResVec,
}

#[derive(Clone, Debug, Serialize, Deserialize)]
/// Complete private player state returned by bootstrap.
pub struct PlayerSnapshot {
    pub player_id: String,
    pub name: String,
    pub realm_id: String,
    pub alliance_id: Option<String>,
    pub alliance_role: Option<String>,
    pub research_busy_until_ms: i64,
    pub research_busy_target: String,
    pub cities: Vec<CitySnapshot>,
    pub research: HashMap<String, i32>,
    pub items: HashMap<String, i64>,
    pub heroes: HashMap<String, i32>,             // key -> level
    pub hero_assignment: HashMap<String, String>, // march/city -> hero key
    pub marches: Vec<MarchSnapshot>,
    pub version: u64,
    pub server_time_ms: i64,
}

#[derive(Clone, Debug, Serialize, Deserialize)]
/// City fields safe to expose to other players.
pub struct PublicCity {
    pub id: String,
    pub name: String,
    pub player_id: String,
    pub player_name: String,
    pub alliance_id: Option<String>,
    pub x: i32,
    pub y: i32,
    pub is_capital: bool,
    pub town_hall_level: i32,
    pub shield_until_ms: i64,
}

#[derive(Clone, Debug, Serialize, Deserialize)]
/// Mutable state of a static world entity.
pub struct EntityState {
    pub id: String,
    pub kind: EntityKind,
    pub x: i32,
    pub y: i32,
    pub level: i32,
    pub subtype: String,
    pub stock: i64,
    pub hp: i64,
    pub owner_player_id: Option<String>,
    pub respawn_at_ms: i64,
}

#[derive(Clone, Debug, Serialize, Deserialize)]
/// Chunk-filtered, visibility-filtered map payload.
pub struct MapSnapshot {
    pub realm_id: String,
    pub seed: u64,
    pub chunk_size: i32,
    pub tiles: Vec<(i32, i32, Terrain)>,
    pub entities: Vec<EntityState>,
    pub cities: Vec<PublicCity>,
    pub marches: Vec<PublicMarch>,
    pub season_score: HashMap<String, i64>,
    /// Chunks the player has not scouted; client renders fog over these.
    pub fogged_chunks: Vec<(i32, i32)>,
}

#[derive(Clone, Debug, Serialize, Deserialize)]
/// March fields safe to expose to other players.
pub struct PublicMarch {
    pub id: String,
    pub player_id: String,
    pub mission: String,
    pub from: (i32, i32),
    pub to: (i32, i32),
    pub depart_at_ms: i64,
    pub arrive_at_ms: i64,
}
