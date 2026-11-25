-- Retry scheduling for the transactional outbox. Without this, a row that
-- failed eight times was never selected again and a committed gameplay event
-- was silently lost. Rows are retried with capped exponential backoff instead.
ALTER TABLE outbox
    ADD COLUMN IF NOT EXISTS next_attempt_at_ms BIGINT NOT NULL DEFAULT 0;

CREATE INDEX IF NOT EXISTS outbox_retry_idx
    ON outbox (realm_id, published_at_ms, next_attempt_at_ms);
