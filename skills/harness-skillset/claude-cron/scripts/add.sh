#!/usr/bin/env bash
# Schedule a recurring `claude -p` run. Writes a spec to ~/Documents/harness/schedules/
# and syncs the user's crontab.
# Usage: add.sh <name> "<cron-schedule>" "<prompt>"
# Example: add.sh morning-brief "0 9 * * *" "/skillscake-marketing-ideation"
#
# Any 5-field cron expression is accepted. The installer adds a top-of-hour
# catch-up tick alongside the user's schedule so a fire missed by laptop sleep
# still runs after wake; the wrapper dedups via a stamp.

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

  if [[ ! "$schedule" =~ ^[^[:space:]]+([[:space:]]+[^[:space:]]+){4}$ ]]; then
    echo "Error: schedule must be a 5-field cron expression (e.g., '0 9 * * *')" >&2
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

  mkdir -p "$SCHED_DIR" "$SCHED_DIR/state" "$LOG_DIR"

  # Seed the stamp at install time so the catch-up tick won't retroactively fire
  # the body for a scheduled time that already passed today.
  date +%s > "$SCHED_DIR/state/$name.stamp"

  {
    printf '# schedule: %s\n' "$schedule"
    printf '# description: %s\n' "$desc"
    printf '\n'
    printf '%s -p ' "$claude_bin"
    # %q (not a heredoc): round-trips quotes/newlines/$/backticks safely
    printf '%q' "$prompt"
    printf ' --model %s >> %s/%s.log 2>&1\n' "$MODEL" "$LOG_DIR" "$name"
  } > "$spec"

  "$SCHED_DIR/install.sh"
  echo "scheduled '$name' ($schedule)"
  echo "  log:  $LOG_DIR/$name.log"
  echo "  spec: $spec"
}

main "$@"
