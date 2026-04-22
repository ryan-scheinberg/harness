#!/usr/bin/env bash
# Cron wrapper: runs a daily job if it hasn't run yet today and the target
# hour has arrived. Catches up on the next tick after a missed window (laptop
# asleep) without drifting — a missed 9am run today fires at the first hourly
# tick past 9am, and tomorrow still fires at 9am.
set -euo pipefail

JOB="${1:?job name required}"
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SPEC="$REPO/$JOB.cron"
STAMP="$REPO/state/$JOB.stamp"

[[ -f "$SPEC" ]] || { echo "no spec at $SPEC" >&2; exit 64; }
mkdir -p "$REPO/state"

sched=$(sed -n 's/^[[:space:]]*#[[:space:]]*schedule:[[:space:]]*//p' "$SPEC" | head -1)
target_hour=$(printf '%s' "$sched" | awk '{print $2}')
[[ "$target_hour" =~ ^[0-9]+$ ]] || { echo "can't parse hour from '$sched' in $SPEC" >&2; exit 65; }

now_date=$(date +%Y-%m-%d)
now_hour=$(date +%H)
stamp_date=""
[[ -f "$STAMP" ]] && stamp_date=$(date -r "$(cat "$STAMP")" +%Y-%m-%d)

# Already ran today, or target hour hasn't arrived yet — no-op.
[[ "$now_date" == "$stamp_date" ]] && exit 0
(( 10#$now_hour < 10#$target_hour )) && exit 0

body=$(awk 'f{print;next} /^[[:space:]]*$/||/^[[:space:]]*#/{next} {f=1;print}' "$SPEC")
[[ -n "$body" ]] || { echo "$SPEC has no command body" >&2; exit 66; }

set +e; bash -c "$body"; rc=$?; set -e
(( rc == 0 )) && date +%s > "$STAMP"
exit $rc
