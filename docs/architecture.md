# Architecture

## Ownership and trust boundaries

| Component | Authority | State |
|---|---|---|
| control-plane | Identity, sessions, realm directory, membership | Global PostgreSQL only |
| gateway | Authentication + routing + delta filtering | Stateless; no gameplay writes |
| realm-worker | All gameplay for its assigned realms | Realm PostgreSQL (canonical) |
| outbox relay | Event delivery | Reads outbox; publishes to JetStream |
| NATS / Valkey | Notifications, disposable presence/rate limits | Never authoritative |
| Flutter client | Presentation + command authoring | No rules, no secrets |

The client supplies commands only. Player identity, realm, costs, timers, positions,
combat results and entitlements are all derived server-side. Gateways set the verified
principal in internal gRPC metadata; the realm worker rejects empty or malformed
principals.

## Fencing / lease

`realm_ownership(realm_id, epoch, owner_id, lease_until_ms)` is the single serialization
point per realm. On start a worker runs `acquire()`:

1. `SELECT ... FOR UPDATE` the ownership row (serializes competing workers).
2. If no owner/lease expired: increment epoch, set `owner_id = worker_id`,
   `lease_until_ms = wall_now_ms() + lease_secs`.
3. Otherwise a standby waits and retries.

Every gameplay transaction starts with `assert_ownership(realm_id, worker_id, epoch)`,
which re-reads the row `FOR UPDATE`, compares both owner and epoch, and checks the lease
against wall-clock time. A takeover increments the epoch, so any in-flight transaction
from the previous owner fails at commit time. Lease renewal runs every `lease_secs/3`;
failure marks the engine lost and stops accepting commands. The scheduler, command
handler and state commit share the same ownership boundary. This is a **per-realm**
serialization point, not a global one; independent realms never block each other.

Documented trade-off: full per-realm serialization via the ownership row simplifies
correctness (no lost updates, no cross-aggregate anomalies) but caps a single realm's
write throughput at roughly one short transaction at a time. Capacity is achieved by
many realms across shards, not by a single large realm. This is an explicit design
choice, measured locally (see `docs/performance/`), not an SLO claim.

## Command pipeline

1. Gateway verifies JWT (control-plane `Validate`, which checks session revocation and
   expiry) and routes by realm → shard → worker.
2. Worker `submit()`: begin fenced tx → insert `commands` marker with payload hash
   (`ON CONFLICT DO NOTHING`) → dispatch typed handler → build authoritative snapshot →
   update command result → commit.
3. Duplicate (same realm/principal/command id/hash) returns the stored result; a reused
   id with a different payload is rejected. Rejections are persisted in a fresh
   transaction so a DB error cannot mask the real error code.
4. State mutations and `outbox` rows are written in the same transaction.

## Discrete-event scheduler

All timed gameplay (construction, research, training, healing, marches, gathering,
monster respawn, rally launch) is a persisted row in `scheduled_events` with
`(due_at_ms, priority, id)` ordering. The scheduler claims bounded batches with
`FOR UPDATE SKIP LOCKED`, reclaims `processing` rows left by a crashed owner, applies
each effect in a fenced transaction, and records `done` or retries with bounded
exponential backoff before `failed`. A dev-only virtual clock offset
(`realm_clock.offset_micros`) makes offline-completion tests deterministic; production
uses statement timestamp only and the admin clock endpoint is disabled.

## Time semantics

Authoritative time is `clock_now_ms(realm) = statement_timestamp + offset`. All deadlines
are UTC milliseconds. Events at the same `due_at_ms` are ordered by explicit priority
then stable UUID. The virtual clock offset never decreases in a running realm (the dev
endpoint only adds). Real wall time is used for lease expiry so virtual time never
expires a lease prematurely.

## Reconnect / resync

WS sessions always receive a full private + chunk-filtered snapshot on connect. A
`SubscriptionUpdate` with a mismatched cursor triggers a fresh snapshot. Deltas carry a
stable `event_id` and a cursor; clients deduplicate by id and may request resync at any
time. If uncertain, the client resyncs — there is no assumption of a gapless stream.
Backpressure uses a bounded outbound channel; slow consumers are disconnected.

## Sharding

`realms.shard` maps to an explicit DSN in `shard_dbs`. Compose runs two independent
PostgreSQL instances (`kd_realm_a`, `kd_realm_b`) and two workers. A realm can be
relocated by changing the directory row and re-provisioning on the destination shard;
player ids never change. No cross-shard join exists in the gameplay hot path.
