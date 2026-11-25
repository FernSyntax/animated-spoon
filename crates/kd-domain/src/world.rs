//! Deterministic, seeded world generation. Terrain and static entity placement
//! are pure functions of (seed, coordinate); mutable entity state lives in the DB.
use serde::{Deserialize, Serialize};

/// Side length of the square world, in tiles.
pub const WORLD_SIZE: i32 = 2048;
/// Side length of a subscription chunk, in tiles.
pub const CHUNK_SIZE: i32 = 32;

#[derive(Clone, Copy, Debug, PartialEq, Eq, Serialize, Deserialize)]
/// Tile terrain type and its passability.
pub enum Terrain {
    Plains,
    Forest,
    Hills,
    Water,
    Mountains,
}

impl Terrain {
    pub fn passable(self) -> bool {
        !matches!(self, Terrain::Water | Terrain::Mountains)
    }
    pub fn key(self) -> &'static str {
        match self {
            Terrain::Plains => "plains",
            Terrain::Forest => "forest",
            Terrain::Hills => "hills",
            Terrain::Water => "water",
            Terrain::Mountains => "mountains",
        }
    }
}

#[derive(Clone, Copy, Debug, PartialEq, Eq, Serialize, Deserialize)]
/// One deterministic world tile.
pub struct Tile {
    pub x: i32,
    pub y: i32,
    pub terrain: Terrain,
}

#[derive(Clone, Debug, PartialEq, Eq, Serialize, Deserialize)]
/// Deterministic placement of a static world entity.
pub struct EntitySeed {
    pub id: String,
    pub kind: EntityKind,
    pub x: i32,
    pub y: i32,
    pub level: i32,
    pub subtype: String,
}

#[derive(Clone, Copy, Debug, PartialEq, Eq, Serialize, Deserialize)]
/// Category of a static world entity.
pub enum EntityKind {
    ResourceNode,
    Monster,
    Fort,
}

impl EntityKind {
    pub fn key(self) -> &'static str {
        match self {
            EntityKind::ResourceNode => "node",
            EntityKind::Monster => "monster",
            EntityKind::Fort => "fort",
        }
    }
}

/// Splitmix64 finalizer used as the seed hash primitive.
pub fn mix64(mut x: u64) -> u64 {
    x = (x ^ (x >> 30)).wrapping_mul(0xBF58_476D_1CE4_E5B9);
    x = (x ^ (x >> 27)).wrapping_mul(0x94D0_49BB_1331_11EB);
    x ^ (x >> 31)
}

fn hash2(seed: u64, x: i32, y: i32) -> u64 {
    mix64(
        seed ^ (x as u64).wrapping_mul(0x9E37_79B9_7F4A_7C15)
            ^ (y as u64).wrapping_mul(0xC2B2_AE3D_282F_4185),
    )
}

fn value_noise(seed: u64, x: i32, y: i32, scale: i32) -> u8 {
    let gx = x.div_euclid(scale);
    let gy = y.div_euclid(scale);
    let fx = x.rem_euclid(scale) as f64 / scale as f64;
    let fy = y.rem_euclid(scale) as f64 / scale as f64;
    let smooth = |t: f64| t * t * (3.0 - 2.0 * t);
    let (sx, sy) = (smooth(fx), smooth(fy));
    let corner = |cx, cy| (hash2(seed, cx, cy) >> 56) as f64;
    let top = corner(gx, gy) + (corner(gx + 1, gy) - corner(gx, gy)) * sx;
    let bottom = corner(gx, gy + 1) + (corner(gx + 1, gy + 1) - corner(gx, gy + 1)) * sx;
    (top + (bottom - top) * sy).round() as u8
}

/// Distinct, fixed offsets for each independent noise layer. Separating the
/// layers keeps them decorrelated while making generation reproducible for a
/// given realm seed. Do not change these values without reseeding every realm.
const CONTINENT_SEED: u64 = 0xC011_71E5;
const BIOME_SEED: u64 = 0xB10C_5EED;
const LANDFORM_SEED: u64 = 0x1A4D_F04D;
const DETAIL_SEED: u64 = 0x000D_3711;
const GRAIN_SEED: u64 = 0x0000_ABCD;

/// Pure, seeded terrain lookup for one coordinate.
pub fn terrain(seed: u64, x: i32, y: i32) -> Terrain {
    // Broad fields shape continents and biomes; a small-scale field breaks up
    // large, monotonous starting regions into readable tactical terrain.
    let continent = value_noise(seed ^ CONTINENT_SEED, x, y, 192) as u64;
    let biome = value_noise(seed ^ BIOME_SEED, x, y, 64) as u64;
    let landform = value_noise(seed ^ LANDFORM_SEED, x, y, 32) as u64;
    let detail = value_noise(seed ^ DETAIL_SEED, x, y, 12) as u64;
    let grain = hash2(seed ^ GRAIN_SEED, x, y) >> 56;
    // Keep broad landforms coherent at the tile level. The previous detail
    // weighting created a noisy mountain/water checkerboard around spawn.
    let v = (continent * 40 + biome * 30 + landform * 20 + detail * 8 + grain * 2) / 100;
    match v {
        0..=160 => Terrain::Plains,
        161..=174 => Terrain::Forest,
        175..=190 => Terrain::Hills,
        191..=198 => Terrain::Mountains,
        _ => Terrain::Water,
    }
}

/// Generate all tiles for one subscription chunk from the world seed.
pub fn chunk_tiles(seed: u64, cx: i32, cy: i32, chunk_size: i32) -> Vec<Tile> {
    let mut out = Vec::with_capacity((chunk_size * chunk_size) as usize);
    for y in 0..chunk_size {
        for x in 0..chunk_size {
            let tx = cx * chunk_size + x;
            let ty = cy * chunk_size + y;
            out.push(Tile {
                x: tx,
                y: ty,
                terrain: terrain(seed, tx, ty),
            });
        }
    }
    out
}

/// Deterministic, well-spread starting positions on passable land.
pub fn starting_positions(seed: u64, count: usize, world_size: i32) -> Vec<(i32, i32)> {
    let mut out = Vec::with_capacity(count);
    let margin = 128;
    let span = world_size - 2 * margin;
    let cols = (count as f64).sqrt().ceil() as i32;
    for i in 0..count {
        let gx = i as i32 % cols;
        let gy = i as i32 / cols;
        let mut px = margin + (gx * span / cols.max(1)) + 40;
        let mut py = margin + (gy * span / cols.max(1)) + 40;
        // Nudge to nearest passable tile deterministically.
        let mut guard = 0;
        while !terrain(seed, px, py).passable() && guard < 256 {
            px = (px + 1) % world_size;
            if px % 64 == 0 {
                py = (py + 1) % world_size;
            }
            guard += 1;
        }
        out.push((px, py));
    }
    out
}

/// Static entities whose mutable state (stock/hp/owner/respawn) is persisted.
///
/// Slots are hashed independently so entities spread across a chunk instead of
/// clustering, and levels rise with distance from the world centre so early
/// exploration stays survivable while the frontier stays rewarding.
pub fn entities_for_chunk(seed: u64, cx: i32, cy: i32, chunk_size: i32) -> Vec<EntitySeed> {
    let mut out = Vec::new();
    for slot in 0..8i32 {
        let salt = (slot as u64 + 1).wrapping_mul(0x9E37_79B9_7F4A_7C15);
        let lx = (hash2(seed ^ salt ^ 0x1234, cx, cy) % chunk_size as u64) as i32;
        let ly = (hash2(seed ^ salt ^ 0x9876, cx, cy) % chunk_size as u64) as i32;
        let x = cx * chunk_size + lx;
        let y = cy * chunk_size + ly;
        if !terrain(seed, x, y).passable() {
            continue;
        }
        let h = hash2(seed ^ salt ^ 0x5EED, cx, cy);
        let distance = x.unsigned_abs().max(y.unsigned_abs());
        let tier = 1 + (distance / 256).min(9) as i32;
        let roll = h % 100;
        let (kind, level, subtype) = if roll < 40 {
            let r = hash2(seed ^ 0x777, x, y) % 5;
            let sub = match r {
                0 => "food",
                1 => "wood",
                2 => "stone",
                3 => "iron",
                _ => "gold",
            };
            (EntityKind::ResourceNode, tier.clamp(1, 5), sub.to_string())
        } else if roll < 75 {
            (EntityKind::Monster, tier, "monster".to_string())
        } else if roll < 80 && (cx.abs() + cy.abs()) % 3 == 0 {
            (EntityKind::Fort, tier.clamp(1, 5), "fort".to_string())
        } else {
            continue;
        };
        out.push(EntitySeed {
            id: format!("{}:{}:{}", kind.key(), x, y),
            kind,
            x,
            y,
            level,
            subtype,
        });
    }
    out
}

/// Deterministic bounded path: a straight line with at most `max_steps` waypoints.
/// Used to persist a march route; passability is checked at dispatch.
pub fn route(from: (i32, i32), to: (i32, i32), max_steps: usize) -> Vec<(i32, i32)> {
    let dx = to.0 - from.0;
    let dy = to.1 - from.1;
    let steps = dx.abs().max(dy.abs()).min(max_steps as i32).max(1);
    (0..=steps)
        .map(|i| {
            (
                from.0 + (dx as i64 * i as i64 / steps as i64) as i32,
                from.1 + (dy as i64 * i as i64 / steps as i64) as i32,
            )
        })
        .collect()
}

#[cfg(test)]
mod tests {
    use super::*;
    #[test]
    fn deterministic() {
        let a = chunk_tiles(7, 3, 4, 32);
        let b = chunk_tiles(7, 3, 4, 32);
        assert_eq!(a, b);
    }
    #[test]
    fn starts_are_passable_and_unique() {
        let p = starting_positions(99, 20, 2048);
        assert_eq!(p.len(), 20);
        assert!(p.iter().all(|(x, y)| terrain(99, *x, *y).passable()));
        let set: std::collections::HashSet<_> = p.iter().collect();
        assert_eq!(set.len(), p.len());
    }
    #[test]
    fn entities_are_deterministic() {
        assert_eq!(
            entities_for_chunk(5, 2, 2, 32),
            entities_for_chunk(5, 2, 2, 32)
        );
    }
}
