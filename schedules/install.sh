#!/usr/bin/env bash
# Sync schedules/*.cron into the user's crontab under a delimited block. Each
# spec gets two crontab entries (deduped if identical): the user's schedule for
# natural fires, and a top-of-hour catch-up tick so a fire missed by laptop
# sleep still runs after wake. The wrapper dedups via a per-job stamp.
# Specs are source of truth; non-harness crontab entries pass through untouched.
# macOS: Terminal needs Full Disk Access for crontab read/write.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WRAPPER="$HERE/bin/run-if-due.py"
CATCHUP="0 * * * *"

PYTHON=$(command -v python3) || { echo "python3 not found in PATH" >&2; exit 1; }
python3 -c "import croniter" 2>/dev/null || { echo "missing dep: pip install croniter" >&2; exit 1; }

chmod +x "$WRAPPER"
mkdir -p "$HERE/state"

BEGIN="# >>> harness schedules >>>"
END="# <<< harness schedules <<<"

block=""
count=0
shopt -s nullglob
for spec in "$HERE"/*.cron; do
  name=$(basename "$spec" .cron)
  sched=$(sed -n 's/^[[:space:]]*#[[:space:]]*schedule:[[:space:]]*//p' "$spec" | head -1)
  [[ -n "$sched" ]] || { echo "missing '# schedule:' header in $spec" >&2; exit 1; }
  block+="# $name: $sched"$'\n'
  block+="$sched $PYTHON $WRAPPER $name"$'\n'
  [[ "$sched" != "$CATCHUP" ]] && block+="$CATCHUP $PYTHON $WRAPPER $name"$'\n'
  count=$((count+1))
done

{
  (crontab -l 2>/dev/null || true) | sed "/^$BEGIN\$/,/^$END\$/d"
  if [[ -n "$block" ]]; then
    printf '%s\n%s%s\n' "$BEGIN" "$block" "$END"
  fi
} | crontab -

echo "installed -> crontab ($count job$([ $count -eq 1 ] || echo s))"
