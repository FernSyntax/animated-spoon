-- Durable payment and fulfillment state. The primary key on id is also the
-- idempotency guard: exactly one row per payment can ever hold a grant.
CREATE TABLE IF NOT EXISTS payments (
    id TEXT PRIMARY KEY,
    account_id TEXT NOT NULL,
    sku TEXT NOT NULL,
    stripe_session_id TEXT,
    status TEXT NOT NULL DEFAULT 'pending',
    created_at_ms BIGINT NOT NULL,
    fulfilled_at_ms BIGINT,
    grant_json JSONB
);

CREATE INDEX IF NOT EXISTS payments_account_id_idx ON payments(account_id);
CREATE INDEX IF NOT EXISTS payments_reconcile_idx ON payments(status, created_at_ms);
