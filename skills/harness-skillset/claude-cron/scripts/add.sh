#!/usr/bin/env bash
# Schedule a recurring `claude -p` run. Writes a spec to ~/Documents/harness/schedules/
# and syncs the user's crontab.
# Usage: add.sh <name> "<cron-schedule>" "<prompt>"
# Example: add.sh daily-angle "0 9 * * *" "/skillscake-marketing-ideation"
#
# The schedule must be daily: `M H * * *`. Catch-up is automatic — if the laptop
# was asleep at the scheduled moment, the job runs on the next cron tick after
# wake, and still fires at the intended time the next day (no drift).

set -e

MODEL="claude-opus-4-7[1m]"
SCHED_DIR="$HOME/Documents/harness/schedules"
LOG_DIR="$HOME/.claude/logs/scheduled"

main() {
  local name="${1:-}"
  local schedule="${2:-}"
  local prompt="${3:-}"

  if [[ -z "$name" || -z "$schedule" || -z "$prompt" ]]; then
    echo "Usage: add.sh <name> \"<cron-schedule>\" \"<prompt>\"" >&2
    echo "Example: add.sh daily-angle \"0 9 * * *\" \"/skillscake-marketing-ideation\"" >&2
    return 1
  fi

  if [[ ! "$schedule" =~ ^[0-9]+[[:space:]]+[0-9]+[[:space:]]+\*[[:space:]]+\*[[:space:]]+\*$ ]]; then
    echo "Error: schedule must be daily format 'M H * * *' (e.g., '0 9 * * *' for 9am daily)" >&2
    echo "Got: '$schedule'" >&2
    return 1
  fi

  local spec="$SCHED_DIR/$name.cron"
  if [[ -f "$spec" ]]; then
    echo "Error: spec already exists at $spec" >&2
    echo "Remove it first: bash remove.sh $name" >&2
    return 1
  fi

  local claude_bin
  claude_bin=$(command -v claude) || { echo "Error: 'claude' not found in PATH" >&2; return 1; }

  local desc
  desc=$(printf '%s' "$prompt" | tr '\n' ' ' | cut -c1-80)

  mkdir -p "$SCHED_DIR" "$LOG_DIR"

  {
    printf '# schedule: %s\n' "$schedule"
    printf '# description: %s\n' "$desc"
    printf '\n'
    printf "%s -p \"\$(cat <<'PROMPT'\n" "$claude_bin"
    printf '%s\n' "$prompt"
    printf 'PROMPT\n'
    printf ')" --model %s >> %s/%s.log 2>&1\n' "$MODEL" "$LOG_DIR" "$name"
  } > "$spec"

  "$SCHED_DIR/install.sh"
  echo "scheduled '$name' ($schedule)"
  echo "  log:  $LOG_DIR/$name.log"
  echo "  spec: $spec"
}

main "$@"
