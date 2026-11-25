#!/usr/bin/env bash
# Convenience: run the Rust services as host binaries against Compose infrastructure.
# Used for fast local iteration; production/local deployment uses `docker compose up`.
set -euo pipefail
cd "$(dirname "$0")/.."
source scripts/env.sh
export KD_WORKER_BY_SHARD__SHARD_A="${KD_WORKER_BY_SHARD__SHARD_A:-http://localhost:50072}"
export KD_WORKER_BY_SHARD__SHARD_B="${KD_WORKER_BY_SHARD__SHARD_B:-http://localhost:50063}"

pkill -f 'target/debug/(control-plane|gateway|realm-worker|outbox-worker)' 2>/dev/null || true
sleep 1

KD_HTTP_ADDR=0.0.0.0:8085 KD_GRPC_ADDR=0.0.0.0:50051 nohup ./target/debug/control-plane > /tmp/kd-control.log 2>&1 &
KD_HTTP_ADDR=0.0.0.0:8086 KD_GRPC_ADDR=0.0.0.0:50072 KD_WORKER_ID=worker-a KD_WORKER_REALMS=realm-a nohup ./target/debug/realm-worker > /tmp/kd-worker-a.log 2>&1 &
KD_HTTP_ADDR=0.0.0.0:8087 KD_GRPC_ADDR=0.0.0.0:50063 KD_WORKER_ID=worker-b KD_WORKER_REALMS=realm-b nohup ./target/debug/realm-worker > /tmp/kd-worker-b.log 2>&1 &
KD_HTTP_ADDR=0.0.0.0:8088 nohup ./target/debug/outbox-worker > /tmp/kd-outbox.log 2>&1 &
KD_HTTP_ADDR=0.0.0.0:8080 nohup ./target/debug/gateway > /tmp/kd-gateway.log 2>&1 &
KD_HTTP_ADDR=0.0.0.0:8081 nohup ./target/debug/gateway > /tmp/kd-gateway-b.log 2>&1 &
sleep 8
curl -fsS http://localhost:8080/health
echo
