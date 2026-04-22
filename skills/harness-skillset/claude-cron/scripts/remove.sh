#!/usr/bin/env bash
# Remove a scheduled claude run and sync the user's crontab.
# Usage: remove.sh <name>

set -e

SCHED_DIR="$HOME/Documents/harness/schedules"

main() {
  local name="${1:-}"
  if [[ -z "$name" ]]; then
    echo "Usage: remove.sh <name>" >&2
    return 1
  fi

  local spec="$SCHED_DIR/$name.cron"
  if [[ ! -f "$spec" ]]; then
    echo "Error: no spec at $spec" >&2
    return 1
  fi

  rm "$spec"
  rm -f "$SCHED_DIR/state/$name.stamp"
  "$SCHED_DIR/install.sh"
  echo "removed '$name'"
}

main "$@"
