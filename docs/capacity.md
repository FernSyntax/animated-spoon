# Capacity model and measured results

## Target hypothesis (not a measured claim)

200 realms × 5,000 CCU + 30% headroom ≈ 1.3M connection capacity; 1M CCU target.
Per connected client baseline: 0.2 mutations/s and 0.5 read/sub ops/s. PvP spikes:
2 mutations/s per active participant plus popular-chunk fanout.

| Quantity | Per realm @5k | Global @1M |
|---|---|---|
| Mutations/s | 1,000 | 200,000 |
| Reads/sub ops/s | 2,500 | 500,000 |
| Realms | 1 | 200 |
| Shard DBs (5k CCU each, headroom) | 1 | ~40+ |

Formulas: `mutations = CCU * 0.2`, `reads = CCU * 0.5`, `connections ≈ CCU`,
`gateway_memory ≈ CCU * per_session_bytes` (bounded frames/queue), `db_tx ≈ mutations`,
`outbound_deltas ≈ mutations * subscribed_chunk_fanout`. Bottlenecks are the per-realm
ownership row lock, DB commit latency (fsync), and delta fanout to popular chunks.
Rust does not make these numbers achievable automatically; headroom and shard count
must be validated by measurement.

## Measured local results (see `docs/performance/*.json`)

Environment: commodity Linux host, Docker Compose Postgres 16 ×3, NATS 2.11, two realm
workers and two gateways, release-independent debug binaries for load runs. Disk fsync
in this environment is slow (single commits frequently ~1s), which dominates latency;
this is reported, not hidden.

- 20-client multi-realm smoke (10 on realm-a via gateway-a, 10 on realm-b via gateway-b,
  60s): realm-a 26 accepted / 760 rule rejections / 0 system errors, p95 ~886ms;
  realm-b 62 accepted / 673 rule rejections / 0 system errors, p95 ~546ms.
- 100-client mixed workload on realm-a, 60s: 491 accepted, 1,313 rule rejections,
  258 system errors, 108 reconnects, p50 ~693ms / p95 ~2.46s / p99 ~2.91s.
  Rejections were legitimate game rules (Conflict/Prerequisite/NotFound/
  InsufficientTroops). The system errors and reconnects are **local environment
  limits** (DB commit latency and control-plane pool pressure during mass login), not
  a passed SLO.
- Unit/property tests: 13 passing. Real PostgreSQL integration tests: 6 passing
  (idempotency, conflict, determinism, offline clock completion, outbox atomicity,
  fencing takeover, cross-realm/security, concurrent spending).

## Staged profiles (defined, not executed beyond local)

`services/loadgen` accepts `--clients`, `--duration`, `--actions-per-sec`, `--scenario`
and `--seed`. Profiles:

| Profile | clients | command |
|---|---|---|
| per-realm 1k | 1000 | `--clients 1000 --actions-per-sec 2` on one realm |
| per-realm 5k | 5000 | distributed agents, one realm |
| global 10k | 10000 | 20 realms × 500 |
| global 100k | 100000 | 200 realms × 500 |
| global 1M + headroom | 1000000 | 200 realms × 5,000, 30% headroom |

Distributed agents, 1k/5k/10k+/1M stages and paid infrastructure are **not executed**
without authorization. No million idle sockets are used as fake load: every agent
performs real registered accounts, city creation, building/research/training, scouting,
gathering, monsters and chat through the production protocol.

## Finding the safe operating point

Increase client count in stages until committed command p95 or scheduler backlog exceeds
the target; the previous stage is the candidate safe point. Record hardware, versions,
duration, raw JSON and failure breakdown. Production p95 <100ms / p99 event lag <1s /
99.99% availability remain unvalidated until an actual full-scale run.
