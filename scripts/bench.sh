#!/usr/bin/env bash
# Staged load profiles. 1k+ stages are defined but require explicit authorization.
set -euo pipefail
GW="${GW:-http://localhost:8080}"
mkdir -p docs/performance
run() {
  name="$1"; realm="$2"; clients="$3"; duration="$4"; rate="$5"; seed="$6"
  cargo run -q -p loadgen -- --gateway "$GW" --realm "$realm" --clients "$clients" \
    --duration "$duration" --actions-per-sec "$rate" --prefix "$name" --seed "$seed" \
    > "docs/performance/${name}.json"
  echo "$name: $(python3 -c "import json;d=json.load(open('docs/performance/${name}.json'));print(d['accepted'],'accepted',d['rejected'],'rejected')")"
}
case "${1:-smoke}" in
  smoke) run smoke20_a realm-a 10 60 2 20241; run smoke20_b realm-b 10 60 2 20242 ;;
  mixed100) run mixed100 realm-a 100 60 1 4242 ;;
  hotspot) run hotspot realm-a 100 60 4 7777 ;;
  reconnect) run reconnect realm-a 50 60 1 8888 ;;
  idle) run idle realm-a 100 60 0 9999 ;;
  profile-1k) echo "define distributed agents before running 1k CCU stage" ;;
  profile-5k|profile-10k|profile-100k|profile-1m) echo "requires explicit authorization; not executed locally" ;;
  *) echo "unknown profile" >&2; exit 1 ;;
esac
