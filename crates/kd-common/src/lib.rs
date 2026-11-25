//! Shared cross-cutting primitives: configuration, authentication, errors and observability.
pub mod auth;
pub mod config;
pub mod errors;
pub mod obs;

pub use errors::{AppError, AppResult};
