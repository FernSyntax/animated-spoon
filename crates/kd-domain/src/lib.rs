//! Pure, deterministic game domain: content catalogs, IDs, world generation,
//! economy and combat mathematics. No I/O, no global state.
pub mod content;
pub mod economy;
pub mod ids;
pub mod sim;
pub mod state;
pub mod world;

pub use ids::*;
