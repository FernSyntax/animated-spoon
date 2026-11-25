//! Payment and idempotency state, backed by PostgreSQL in production.
//!
//! A `Store` is either an in-memory map (dev/test only) or a PostgreSQL pool.
//! Both variants share the same async API so callers never branch on the
//! backend. In PostgreSQL, fulfillment is a transaction guarded by a row lock
//! and a `WHERE grant_json IS NULL` update; the table's primary key on `id`
//! guarantees that only one caller can ever write a grant for a payment.

use crate::catalog;
use anyhow::{bail, Result};
use serde_json::Value;
use sqlx::postgres::{PgPool, PgPoolOptions};
use std::{
    collections::HashMap,
    sync::{Arc, Mutex},
    time::{Duration, SystemTime, UNIX_EPOCH},
};
use uuid::Uuid;

static MIGRATOR: sqlx::migrate::Migrator = sqlx::migrate!("../../migrations/payments");

#[derive(Clone, Debug)]
pub struct Payment {
    pub id: String,
    pub account_id: String,
    pub sku: String,
    /// Set when Stripe created a hosted Checkout Session (diagnostics only).
    pub stripe_session_id: Option<String>,
}

#[derive(Clone, Debug)]
pub struct FulfillmentOutcome {
    pub grant: Value,
    /// `true` only on the first successful fulfillment of this payment id.
    pub newly_granted: bool,
}

#[derive(Clone, Debug, sqlx::FromRow)]
struct PaymentRow {
    id: String,
    account_id: String,
    sku: String,
    stripe_session_id: Option<String>,
}

impl From<PaymentRow> for Payment {
    fn from(row: PaymentRow) -> Self {
        Self {
            id: row.id,
            account_id: row.account_id,
            sku: row.sku,
            stripe_session_id: row.stripe_session_id,
        }
    }
}

#[derive(Default)]
struct InMemoryDb {
    payments: HashMap<String, Payment>,
    fulfilled: HashMap<String, Value>,
}

#[derive(Clone, Default)]
pub struct MemoryStore {
    db: Arc<Mutex<InMemoryDb>>,
}

#[derive(Clone)]
pub struct PostgresStore {
    pool: PgPool,
}

#[derive(Clone)]
pub enum Store {
    Memory(MemoryStore),
    Postgres(PostgresStore),
}

impl Store {
    /// In-memory store for unit tests and local development. Prefer
    /// [`Store::from_env`] in the binary so a configured database is honoured.
    pub fn new() -> Self {
        Self::Memory(MemoryStore::default())
    }

    /// Select the backend from the environment. An absent database URL selects
    /// the dev-only in-memory store with a loud warning.
    pub async fn from_env() -> Result<Self> {
        let url = std::env::var("KD_PAYMENTS_DB_URL")
            .ok()
            .or_else(|| std::env::var("KD_DATABASE_URL").ok())
            .map(|value| value.trim().to_string())
            .filter(|value| !value.is_empty());
        match url {
            Some(url) => {
                tracing::info!("payments store: PostgreSQL");
                Self::connect(&url).await
            }
            None => {
                tracing::warn!(
                    "KD_PAYMENTS_DB_URL and KD_DATABASE_URL are unset: using the DEV-ONLY in-memory payments store; all payments and grants will be lost on restart"
                );
                Ok(Self::new())
            }
        }
    }

    /// Connect to PostgreSQL, apply the payments migrations, and return a
    /// store backed by that pool. Also used by the database integration tests.
    pub async fn connect(url: &str) -> Result<Self> {
        let pool = PgPoolOptions::new()
            .max_connections(10)
            .acquire_timeout(Duration::from_secs(5))
            .connect(url)
            .await?;
        MIGRATOR.run(&pool).await?;
        Ok(Self::Postgres(PostgresStore { pool }))
    }

    /// Reject unknown SKUs up front so nobody reaches a checkout page for an
    /// item we cannot grant.
    pub async fn create_payment(&self, account_id: &str, sku: &str) -> Result<Payment> {
        catalog::unit_amount_cents(sku)?;
        let id = Uuid::new_v4().to_string();
        match self {
            Self::Memory(store) => {
                let payment = Payment {
                    id,
                    account_id: account_id.to_string(),
                    sku: sku.to_string(),
                    stripe_session_id: None,
                };
                let mut db = store.db.lock().expect("in-memory db lock poisoned");
                db.payments.insert(payment.id.clone(), payment.clone());
                Ok(payment)
            }
            Self::Postgres(store) => {
                sqlx::query(
                    "INSERT INTO payments (id, account_id, sku, status, created_at_ms) \
                     VALUES ($1, $2, $3, 'pending', $4)",
                )
                .bind(&id)
                .bind(account_id)
                .bind(sku)
                .bind(now_ms())
                .execute(&store.pool)
                .await?;
                Ok(Payment {
                    id,
                    account_id: account_id.to_string(),
                    sku: sku.to_string(),
                    stripe_session_id: None,
                })
            }
        }
    }

    /// Payment ids that may have paid while our webhook was down.
    pub async fn pending_ids(&self, older_than_ms: i64) -> Result<Vec<String>> {
        match self {
            Self::Memory(store) => {
                let db = store.db.lock().expect("in-memory db lock poisoned");
                Ok(db
                    .payments
                    .keys()
                    .filter(|id| !db.fulfilled.contains_key(*id))
                    .cloned()
                    .collect())
            }
            Self::Postgres(store) => {
                let rows: Vec<(String,)> = sqlx::query_as(
                    "SELECT id FROM payments WHERE status='pending' AND created_at_ms<$1 ORDER BY created_at_ms",
                )
                .bind(older_than_ms)
                .fetch_all(&store.pool)
                .await?;
                Ok(rows.into_iter().map(|r| r.0).collect())
            }
        }
    }

    pub async fn get_payment(&self, payment_id: &str) -> Option<Payment> {
        match self {
            Self::Memory(store) => {
                let db = store.db.lock().expect("in-memory db lock poisoned");
                db.payments.get(payment_id).cloned()
            }
            Self::Postgres(store) => {
                match sqlx::query_as::<_, PaymentRow>(
                    "SELECT id, account_id, sku, stripe_session_id FROM payments WHERE id = $1",
                )
                .bind(payment_id)
                .fetch_optional(&store.pool)
                .await
                {
                    Ok(row) => row.map(Payment::from),
                    Err(error) => {
                        tracing::error!(%payment_id, %error, "failed to read payment");
                        None
                    }
                }
            }
        }
    }

    pub async fn set_stripe_session_id(&self, payment_id: &str, session_id: &str) {
        match self {
            Self::Memory(store) => {
                let mut db = store.db.lock().expect("in-memory db lock poisoned");
                if let Some(payment) = db.payments.get_mut(payment_id) {
                    payment.stripe_session_id = Some(session_id.to_string());
                }
            }
            Self::Postgres(store) => {
                if let Err(error) =
                    sqlx::query("UPDATE payments SET stripe_session_id = $2 WHERE id = $1")
                        .bind(payment_id)
                        .bind(session_id)
                        .execute(&store.pool)
                        .await
                {
                    tracing::error!(%payment_id, %error, "failed to persist Stripe session id");
                }
            }
        }
    }

    /// The one fulfillment path. Both the Stripe webhook and the dev stub call
    /// this, so neither can bypass the idempotency check.
    pub async fn complete_payment(&self, payment_id: &str) -> Result<FulfillmentOutcome> {
        match self {
            Self::Memory(store) => {
                let mut db = store.db.lock().expect("in-memory db lock poisoned");
                let Some(payment) = db.payments.get(payment_id).cloned() else {
                    bail!("unknown payment id: {payment_id}");
                };
                if let Some(grant) = db.fulfilled.get(payment_id) {
                    return Ok(FulfillmentOutcome {
                        grant: grant.clone(),
                        newly_granted: false,
                    });
                }
                let grant = catalog::fulfill(payment_id, &payment.account_id, &payment.sku)?;
                db.fulfilled.insert(payment_id.to_string(), grant.clone());
                Ok(FulfillmentOutcome {
                    grant,
                    newly_granted: true,
                })
            }
            Self::Postgres(store) => {
                let mut tx = store.pool.begin().await?;
                #[derive(sqlx::FromRow)]
                struct CurrentGrant {
                    account_id: String,
                    sku: String,
                    grant_json: Option<Value>,
                }
                let row = sqlx::query_as::<_, CurrentGrant>(
                    "SELECT account_id, sku, grant_json FROM payments WHERE id = $1 FOR UPDATE",
                )
                .bind(payment_id)
                .fetch_optional(&mut *tx)
                .await?;
                let Some(row) = row else {
                    bail!("unknown payment id: {payment_id}");
                };
                if let Some(grant) = row.grant_json {
                    tx.commit().await?;
                    return Ok(FulfillmentOutcome {
                        grant,
                        newly_granted: false,
                    });
                }
                let grant = catalog::fulfill(payment_id, &row.account_id, &row.sku)?;
                let result = sqlx::query(
                    "UPDATE payments SET grant_json = $2, status = 'fulfilled', fulfilled_at_ms = $3 \
                     WHERE id = $1 AND grant_json IS NULL",
                )
                .bind(payment_id)
                .bind(&grant)
                .bind(now_ms())
                .execute(&mut *tx)
                .await?;
                tx.commit().await?;
                if result.rows_affected() != 1 {
                    bail!("payment was fulfilled concurrently: {payment_id}");
                }
                Ok(FulfillmentOutcome {
                    grant,
                    newly_granted: true,
                })
            }
        }
    }

    /// Diagnostic/test helper: how many payments have been granted.
    pub async fn fulfilled_count(&self) -> usize {
        match self {
            Self::Memory(store) => {
                let db = store.db.lock().expect("in-memory db lock poisoned");
                db.fulfilled.len()
            }
            Self::Postgres(store) => {
                let row: (i64,) =
                    sqlx::query_as("SELECT COUNT(*) FROM payments WHERE grant_json IS NOT NULL")
                        .fetch_one(&store.pool)
                        .await
                        .expect("count fulfilled payments");
                row.0 as usize
            }
        }
    }
}

impl Default for Store {
    fn default() -> Self {
        Self::new()
    }
}

fn now_ms() -> i64 {
    SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .expect("system clock")
        .as_millis() as i64
}
