#!/usr/bin/env bash
# Sync schedules/*.cron into the user's crontab under a delimited block.
# Each spec fires an hourly catch-up tick (on the user's minute); the wrapper
# decides whether to actually run based on today's date and the target hour.
# Specs are source of truth; non-harness crontab entries pass through untouched.
# macOS: Terminal needs Full Disk Access for crontab read/write.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WRAPPER="$HERE/bin/run-if-due.sh"
BEGIN="# >>> harness schedules >>>"
END="# <<< harness schedules <<<"

chmod +x "$WRAPPER"
mkdir -p "$HERE/state"

block=""
count=0
shopt -s nullglob
for spec in "$HERE"/*.cron; do
  name=$(basename "$spec" .cron)
  sched=$(sed -n 's/^[[:space:]]*#[[:space:]]*schedule:[[:space:]]*//p' "$spec" | head -1)
  [[ -n "$sched" ]] || { echo "missing '# schedule:' header in $spec" >&2; exit 1; }
  minute=$(printf '%s' "$sched" | awk '{print $1}')
  block+="# $name: $sched"$'\n'
  block+="$minute * * * * $WRAPPER $name"$'\n'
  count=$((count+1))
done

{
  (crontab -l 2>/dev/null || true) | sed "/^$BEGIN\$/,/^$END\$/d"
  if [[ -n "$block" ]]; then
    printf '%s\n%s%s\n' "$BEGIN" "$block" "$END"
  fi
} | crontab -

echo "installed -> crontab ($count job$([ $count -eq 1 ] || echo s))"
