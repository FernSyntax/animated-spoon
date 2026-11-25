#!/usr/bin/env bash
# Local backup/restore verification: dump a realm shard, restore to a scratch DB,
# compare city / pending event / outbox counts.
set -euo pipefail
SRC="${1:-postgres://kd:kd@localhost:15433/kd_realm_a}"
ADMIN="${2:-postgres://kd:kd@localhost:15432/postgres}"
STAMP=$(date +%s)
DUMP="/tmp/kd_realm_${STAMP}.dump"
SCRATCH="kd_restore_${STAMP}"
pg_dump "$SRC" -Fc -f "$DUMP"
psql "$ADMIN" -c "DROP DATABASE IF EXISTS $SCRATCH;"
psql "$ADMIN" -c "CREATE DATABASE $SCRATCH;"
pg_restore "$SRC" >/dev/null 2>&1 || true
pg_restore --dbname="postgres://kd:kd@localhost:15432/$SCRATCH" "$DUMP" >/dev/null 2>&1 || true

count() { psql "$1" -tAc "$2" | tr -d ' '; }
SRC_CITIES=$(count "$SRC" "select count(*) from cities")
DST_CITIES=$(count "postgres://kd:kd@localhost:15432/$SCRATCH" "select count(*) from cities")
SRC_EVENTS=$(count "$SRC" "select count(*) from scheduled_events where status='pending'")
DST_EVENTS=$(count "postgres://kd:kd@localhost:15432/$SCRATCH" "select count(*) from scheduled_events where status='pending'")
SRC_OUTBOX=$(count "$SRC" "select count(*) from outbox")
DST_OUTBOX=$(count "postgres://kd:kd@localhost:15432/$SCRATCH" "select count(*) from outbox")
echo "cities $SRC_CITIES/$DST_CITIES events $SRC_EVENTS/$DST_EVENTS outbox $SRC_OUTBOX/$DST_OUTBOX"
test "$SRC_CITIES" = "$DST_CITIES"
test "$SRC_EVENTS" = "$DST_EVENTS"
test "$SRC_OUTBOX" = "$DST_OUTBOX"
psql "$ADMIN" -c "DROP DATABASE $SCRATCH;"
echo "backup/restore verified"
