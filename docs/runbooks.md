# Runbooks

## Slow realm
Symptom: command p95 rises, scheduler backlog grows. Check `kd_scheduler_backlog`,
`kd_scheduler_lag_ms`, `kd_command_latency_ms`, DB pool saturation and slow query logs.
Mitigation: confirm single fenced owner, look for long transactions and overdue events,
then reduce load or move the realm to a less loaded shard (offline procedure below).

## Database failure
Committed writes survive by definition (state is in PostgreSQL). Gateways keep sessions
but commands fail until the shard returns; clients show server errors and resync on
reconnect. Restart the worker after DB recovery; ownership lease expiry allows a fenced
takeover.

## Ownership failover
Kill the active worker. Lease expires after `KD_LEASE_SECS`; a standby `acquire()`s with
an incremented epoch. The old process cannot commit afterwards (`assert_ownership`
rejects stale epoch). Reclaimed `processing` events are re-run; per-command dedup and
event effects are idempotent. Verified by the `stale_owner_cannot_commit_after_takeover`
integration test.

## Replay / backlog
Outbox rows with `published_at_ms = 0` are retried with bounded backoff. Broker outage
leaves them pending; on recovery the relay publishes with stable `Nats-Msg-Id`.
Consumers deduplicate by event id. Dead-letter visibility is `last_error` + `attempts`.

## Broker or cache outage
Gameplay continues: no authoritative state lives in NATS or Valkey. Live deltas stop;
clients resync from snapshots on reconnect. Cache loss only affects disposable
presence/rate-limit counters.

## Backup / restore
Design: nightly base backups + WAL archiving (PITR) per shard. Local verification:
`scripts/backup_restore.sh` takes a `pg_dump` of a realm shard, restores it into a
scratch database and compares city counts, pending event counts and outbox counts.
Run before any destructive operation. Never reset production data.

## Offline realm movement / restore
1. Drain the realm: stop routing new commands (directory status), let queues empty.
2. Snapshot the realm's rows and verify counts.
3. Update `realms.shard` in the global directory; provision the realm on the destination
   shard and seed entities; reassign a worker.
4. Verify ownership acquisition and a single smoke command, then mark active.
Player ids are unchanged. Live migration is intentionally not implemented.

## Capacity expansion
Add a shard DB, add realms to it via `CreateRealm`/directory, start workers pinned to the
new shard, and point gateways at the new worker route. Scale gateway replicas freely.
