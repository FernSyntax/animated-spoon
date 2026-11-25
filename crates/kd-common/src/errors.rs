//! Application error type and its mapping to wire-level error codes.
use kd_proto::ErrorCode;

#[derive(Debug, thiserror::Error)]
/// Application error taxonomy shared by all services and mapped to wire codes.
pub enum AppError {
    #[error("not found: {0}")]
    NotFound(String),
    #[error("invalid argument: {0}")]
    Invalid(String),
    #[error("permission denied: {0}")]
    Forbidden(String),
    #[error("unauthenticated")]
    Unauthenticated,
    #[error("conflict: {0}")]
    Conflict(String),
    #[error("insufficient resources: {0}")]
    InsufficientResources(String),
    #[error("insufficient troops: {0}")]
    InsufficientTroops(String),
    #[error("prerequisite unmet: {0}")]
    Prerequisite(String),
    #[error("queue full: {0}")]
    QueueFull(String),
    #[error("stale version")]
    StaleVersion,
    #[error("cross realm access")]
    CrossRealm,
    #[error("rate limited")]
    RateLimited,
    #[error("target shielded")]
    Shielded,
    #[error("no valid target")]
    NoTarget,
    #[error("not owner of realm ownership lease")]
    NotOwner,
    #[error("internal: {0}")]
    Internal(String),
}

impl AppError {
    pub fn code(&self) -> ErrorCode {
        match self {
            AppError::NotFound(_) => ErrorCode::NotFound,
            AppError::Invalid(_) => ErrorCode::InvalidArgument,
            AppError::Forbidden(_) => ErrorCode::PermissionDenied,
            AppError::Unauthenticated => ErrorCode::Unauthenticated,
            AppError::Conflict(_) | AppError::QueueFull(_) => ErrorCode::Conflict,
            AppError::InsufficientResources(_) => ErrorCode::InsufficientResources,
            AppError::InsufficientTroops(_) => ErrorCode::InsufficientTroops,
            AppError::Prerequisite(_) => ErrorCode::PrerequisiteUnmet,
            AppError::StaleVersion => ErrorCode::StaleVersion,
            AppError::CrossRealm => ErrorCode::CrossRealm,
            AppError::RateLimited => ErrorCode::RateLimited,
            AppError::Shielded => ErrorCode::Shielded,
            AppError::NoTarget => ErrorCode::NoTarget,
            AppError::NotOwner => ErrorCode::NotOwner,
            AppError::Internal(_) => ErrorCode::Internal,
        }
    }
}

pub type AppResult<T> = Result<T, AppError>;

impl From<sqlx::Error> for AppError {
    fn from(e: sqlx::Error) -> Self {
        // Unique-violation is mapped to Conflict so callers can retry safely.
        match &e {
            sqlx::Error::Database(d) if d.is_unique_violation() => {
                AppError::Conflict("unique constraint".into())
            }
            _ => AppError::Internal(e.to_string()),
        }
    }
}

impl From<serde_json::Error> for AppError {
    fn from(e: serde_json::Error) -> Self {
        AppError::Internal(e.to_string())
    }
}
