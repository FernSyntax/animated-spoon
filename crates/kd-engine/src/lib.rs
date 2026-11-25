//! Reusable authoritative realm engine. All gameplay mutations, scheduling,
//! deduplication and outbox writes happen inside one fenced DB transaction.
pub mod commands;
pub mod engine;
pub mod scheduler;
pub mod snapshot;

pub use engine::{Engine, EventRouting};
