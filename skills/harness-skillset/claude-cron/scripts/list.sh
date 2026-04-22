#!/usr/bin/env bash
# List all scheduled claude runs with schedule and last-success time.
# Usage: list.sh

SCHED_DIR="$HOME/Documents/harness/schedules"

main() {
  shopt -s nullglob
  local specs=("$SCHED_DIR"/*.cron)
  if (( ${#specs[@]} == 0 )); then
    echo "No scheduled runs"
    return 0
  fi

  echo "Scheduled claude runs:"
  local spec name schedule stamp last
  for spec in "${specs[@]}"; do
    name=$(basename "$spec" .cron)
    schedule=$(sed -n 's/^[[:space:]]*#[[:space:]]*schedule:[[:space:]]*//p' "$spec" | head -1)
    stamp="$SCHED_DIR/state/$name.stamp"
    if [[ -f "$stamp" ]]; then
      last=$(date -r "$(cat "$stamp")" "+%Y-%m-%d %H:%M")
    else
      last="(never)"
    fi
    printf "  %-24s %-15s last=%s\n" "$name" "$schedule" "$last"
  done
}

main "$@"
