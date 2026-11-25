# Deployment

## Local

`docker compose up -d --build` starts: global DB, two realm shard DBs, NATS JetStream,
Valkey, control-plane, two realm workers (one per realm), outbox relay and two stateless
gateways. Migrations run automatically on service start (idempotent). Realm/account
seeding is deterministic and dev-only demo credentials are disabled in production mode.

Health: `/health` on each HTTP service, `pg_isready` for databases, NATS `/healthz`,
`valkey-cli ping`. Readiness for the gateway requires control-plane, NATS and its
shards' workers.

## Production topology

- Scale gateways horizontally; they hold no authoritative state.
- Assign realms to workers with `KD_WORKER_REALMS`; only the fenced owner mutates a realm.
- Scale databases by adding shards and moving realms via the directory, **not** by
  replicating the same writable state behind Kubernetes replicas.
- NATS JetStream and PostgreSQL are stateful services requiring their own HA/backup
  strategy; Valkey is disposable.
- Admin ports, DBs, broker and cache are never publicly exposed. Use TLS, network
  policies, least-privilege credentials and secret templates (no secrets in repo).

## Kubernetes

`deploy/kubernetes/` contains namespace, config/secret templates, per-component
deployments and services, and an HPA for stateless gateways. Images are pinned by tag.
Realms are pinned to workers via `KD_WORKER_REALMS` in each worker deployment; changing
a realm's shard is an explicit, documented runbook operation.

## OpenTofu

`deploy/opentofu/` is an **example** for AWS + EKS + managed PostgreSQL. It provisions
VPC/EKS/RDS/ElastiCache/MSK-shaped infrastructure declarations only; it is never to be
applied without explicit authorization. Provider assumptions are documented in the
module. `tofu validate` is run in CI when the binary is available.
