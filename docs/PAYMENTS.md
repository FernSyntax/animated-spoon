# Payments service (`services/payments`)

A small, standalone axum service that sells gems/items for real money via
Stripe Checkout. It is designed so the whole flow is exercisable locally with
**no Stripe account and no credentials**: when no Stripe secret key is present,
the service uses a local stub provider.

> **Store backend:** payments are persisted in PostgreSQL when
> `KD_PAYMENTS_DB_URL` (or `KD_DATABASE_URL`) is set. Without a database URL the
> service falls back to an **in-memory, dev-only** store (with a WARN log) that
> loses all data on restart. Set a database URL before accepting real money.
> See [Payment store & migration](#payment-store--migration) and the
> "Before going live" checklist below.

## Endpoints

| Method | Path                       | Purpose                                                     |
| ------ | -------------------------- | ----------------------------------------------------------- |
| GET    | `/health`                  | Liveness probe; returns `ok`.                               |
| POST   | `/checkout`                | Body `{"account_id":"...","sku":"gems_1000"}` → creates a payment record and returns `{payment_id, checkout_url, provider}`. |
| GET    | `/stub-checkout/{id}`      | **Dev only.** Simulates a successful payment and fulfills it through the same path as the webhook. 404 in production mode. |
| POST   | `/webhook/stripe`          | Verifies `Stripe-Signature` over the raw body, then fulfills `checkout.session.completed` exactly once. |

Known SKUs are `gems_1000` (999 cents → 1000 credits), `gems_5000` (3999 cents
→ 5000 credits) and `starter_pack` (499 cents → 500 credits). Unknown SKUs are
rejected at checkout and at fulfillment. A grant looks like:

```json
{
  "payment_id": "<uuid>",
  "account_id": "<player account>",
  "sku": "gems_1000",
  "credits": 1000
}
```

## Configuration (environment variables)

All variables are optional; absence of `KD_STRIPE_SECRET_KEY` selects the stub.

| Variable                            | Default                          | Meaning                                                            |
| ----------------------------------- | -------------------------------- | ------------------------------------------------------------------ |
| `KD_PAYMENTS_DB_URL`                | *(unset)*                        | PostgreSQL URL for the durable payments store. Takes precedence over `KD_DATABASE_URL`. |
| `KD_DATABASE_URL`                   | *(unset)*                        | Fallback PostgreSQL URL for the payments store.                    |
| `KD_HTTP_ADDR`                      | `0.0.0.0:8080`                   | Listen address.                                                    |
| `KD_PUBLIC_BASE_URL`                | `http://localhost:8080`          | Base URL for stub checkout links and default success/cancel URLs.  |
| `KD_INTERNAL_SECRET`                | *(unset)*                        | Shared secret with the gateway. When set, checkout requires `x-kd-account-signature` = HMAC-SHA256(secret, account_id). |
| `KD_STRIPE_SECRET_KEY`              | *(unset)*                        | Stripe **secret** key. If set (non-empty), live mode is enabled.    |
| `KD_STRIPE_WEBHOOK_SECRET`          | *(unset)*                        | `whsec_...` signing secret used to verify webhooks.                |
| `KD_STRIPE_WEBHOOK_TOLERANCE_SECS`  | `300`                            | Max age of a signed webhook (replay protection).                   |
| `KD_STRIPE_SUCCESS_URL`             | `{PUBLIC_BASE_URL}/checkout/success` | Stripe Checkout `success_url`.                                 |
| `KD_STRIPE_CANCEL_URL`              | `{PUBLIC_BASE_URL}/checkout/cancel`  | Stripe Checkout `cancel_url`.                                  |
| `KD_STRIPE_API_BASE`                | `https://api.stripe.com`         | Override only for tests/local Stripe mocks.                        |
| `RUST_LOG`                          | `info`                           | Tracing filter.                                                    |

`scripts/env.sh` contains commented examples; `docker-compose.yml` carries the
same placeholders in its shared `x-rust-env` block. The service binary is not
wired into `docker-compose.yml` yet (no build/image target has been added).

**Never commit real keys.** Use your secret manager / deployment environment to
inject `KD_STRIPE_SECRET_KEY`, `KD_STRIPE_WEBHOOK_SECRET` and the database URL.

## Payment store & migration

`services/payments/src/store.rs` exposes one async `Store` API with two backends:

* **PostgreSQL (production):** selected when `KD_PAYMENTS_DB_URL` or
  `KD_DATABASE_URL` is non-empty. On startup the service connects with `sqlx`
  and runs `sqlx::migrate!` against `migrations/payments`.
* **In-memory (dev only):** selected when neither variable is set. The service
  logs a WARN that state is transient. Fine for local development and tests;
  never use it with real money or behind more than one replica.

The migration `migrations/payments/001_init.sql` creates a `payments` table
(`id` as PRIMARY KEY, `account_id`, `sku`, `stripe_session_id`, `status`,
`created_at_ms`, `fulfilled_at_ms`, `grant_json JSONB`) and an index on
`account_id`. The primary key on `id` is the idempotency guard: a payment can
hold at most one grant.

Fulfillment is a single transaction: it locks the payment row (`FOR UPDATE`),
returns the stored grant with `newly_granted: false` when one already exists,
and otherwise writes the grant with `UPDATE ... WHERE grant_json IS NULL` and
sets `status = 'fulfilled'`, `fulfilled_at_ms`. Only the caller that performs
that update gets `newly_granted: true`. Both the signed webhook and the dev stub
use this one path, so neither can double-grant.

To exercise the database backend locally:

```bash
# Requires a running PostgreSQL. Uses the test database from docker-compose.
KD_TEST_PAYMENTS_DB=postgres://kd:kd@localhost:15433/kd_payments_test \
  cargo test -p payments -- --include-ignored
```

The two `#[ignore]`d tests in `services/payments/tests/postgres.rs` run only
with that variable set: one verifies a payment/grant survives a new `Store`
instance on the same database and that a replay returns `newly_granted: false`;
the other races two `complete_payment` calls and asserts exactly one grant.

## Dev stub flow (no Stripe credentials)

```bash
# From the repo root. No .env needed: no Stripe key means stub mode.
cargo run -p payments
# In another shell:
curl -s localhost:8080/health
curl -s -X POST localhost:8080/checkout \
  -H 'content-type: application/json' \
  -d '{"account_id":"player-1","sku":"gems_1000"}'
# -> {"payment_id":"<uuid>","checkout_url":"http://localhost:8080/stub-checkout/<uuid>","provider":"stub"}

curl -s localhost:8080/stub-checkout/<uuid>
# -> {"payment_id":"...","newly_granted":true,
#     "grant":{"sku":"gems_1000","credits":1000,...},"note":"DEV STUB: ..."}
```

Calling the stub URL again returns the same grant with `newly_granted: false`:
fulfillment is idempotent by payment id, so replaying a webhook or refreshing a
stub checkout cannot double-grant. The stub route returns 404 as soon as a
Stripe secret key is configured. The unit tests cover this flow end to end
(`cargo test -p payments`) without binding a port.

## Stripe dashboard setup (production)

1. Create a Stripe account and use **test mode** keys first (`sk_test_...`) for
   end-to-end validation; switch to live (`sk_live_...`) only after sign-off.
2. In **Developers → API keys**, create a restricted secret key with write
   access to Checkout Sessions if you want least privilege.
3. In **Developers → Webhooks**, add an endpoint pointing at
   `https://<your-host>/webhook/stripe` and subscribe to
   **`checkout.session.completed`**. Stripe shows a **Signing secret**
   (`whsec_...`) — put it in `KD_STRIPE_WEBHOOK_SECRET`. Each endpoint (and each
   test/live mode) has a different secret.
4. For local webhook testing use the Stripe CLI:
   ```bash
   stripe listen --forward-to localhost:8080/webhook/stripe
   # Use the whsec_... it prints as KD_STRIPE_WEBHOOK_SECRET.
   stripe trigger checkout.session.completed
   ```
5. Configure `KD_PUBLIC_BASE_URL` and the success/cancel URLs to real client
   pages. Set `KD_STRIPE_SECRET_KEY` to switch from the stub to the hosted
   Stripe Checkout API (`POST https://api.stripe.com/v1/checkout/sessions`,
   form-encoded, Bearer auth, `client_reference_id` = our payment id).

The service verifies the Stripe scheme (`t=<ts>,v1=<hex>` → HMAC-SHA256 over
`"{timestamp}.{raw_body}"`) with a constant-time comparison and rejects
requests whose signature is bad, missing, or older than the tolerance window
(HTTP 400). It also rejects webhooks when `KD_STRIPE_WEBHOOK_SECRET` is unset
(HTTP 503). The event is parsed only after verification and only over the raw
body, never over re-serialized JSON.

## Security notes / limitations

* The stub endpoint is unauthenticated by design and is **dev-only**; it is
  disabled in production mode. Do not expose it publicly with a Stripe key set.
* `account_id` is trusted from the caller in this example. In production,
  derive it from the authenticated session/JWT rather than accepting it from
  the request body.
* Fulfillment currently checks `checkout.session.completed` only; extend it to
  handle async payment methods (`checkout.session.async_payment_succeeded`) and
  refunds/disputes before launch.
* `POST /admin/reconcile` re-checks pending payments (Stripe Checkout Sessions
  in live mode, stub payments in dev) and fulfills any paid-but-unfulfilled
  row. Run it periodically from a scheduler/cron; it is idempotent. Send it
  from a trusted network, and set `KD_INTERNAL_SECRET` to require the
  `x-kd-internal` header. Stripe retries failed deliveries, and payments now
  survive restarts,
  but failed fulfillment attempts are only logged — they are not recorded for
  an operator to reconcile. A durable failure/outbox record is still missing.

## Before going live (checklist)

1. Set `KD_PAYMENTS_DB_URL` (or `KD_DATABASE_URL`) so the durable PostgreSQL
   store is used; run the `migrations/payments` migration as part of deployment
   and never run production with the in-memory fallback.
2. Derive `account_id` from an authenticated identity; add authorization.
3. Add TLS termination in front of the service and terminate webhooks only over
   HTTPS.
4. Inject all secrets (`KD_STRIPE_SECRET_KEY`, `KD_STRIPE_WEBHOOK_SECRET`, DB
   URL, and eventually a live Stripe **restricted** key) from a secrets
   manager. Never bake keys into images or compose files.
5. Switch from test-mode to a live Stripe key only after sign-off, point the
   success/cancel URLs at real pages, and configure the production webhook
   endpoint + signing secret in Stripe.
6. Add durable outbox/reconciliation for missed webhooks and handle refunds /
   async payment methods.
7. Run `cargo clippy -p payments --all-targets -- -D warnings`,
   `cargo test -p payments`, the DB integration tests, and
   `cargo check --workspace` in CI; validate with `stripe trigger` in test mode
   before switching to live keys.
