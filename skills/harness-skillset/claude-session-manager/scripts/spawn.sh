#!/usr/bin/env bash
# Spawn a named Claude --remote-control session in a new Terminal window
# Usage: spawn.sh <name> <role> <workdir> "<initial brief>"
# Manager is always the spawner ($CLAUDE_SESSION_NAME); unset when spawned from the user's terminal.
# Initial brief is queued as the first message after the role loads — required so a spawn never sits idle.
# Model is hardcoded — update MODEL below when a new frontier model ships.

set -e

MODEL="claude-opus-4-7[1m]"
REGISTRY=~/.claude/session-registry.json

_reg_init() {
  [[ -f "$REGISTRY" ]] || echo '{}' > "$REGISTRY"
}

_reg_write() {
  local name=$1 window_id=$2 pid=$3 workdir=$4 model=$5 manager=$6
  _reg_init
  local tmp=$(mktemp)
  jq --arg n "$name" --argjson w "$window_id" --argjson p "$pid" \
     --arg d "$workdir" --arg m "$model" --arg mgr "$manager" --arg t "$(date -u +%FT%TZ)" \
     '.[$n] = {window_id: $w, pid: $p, workdir: $d, model: $m, manager: $mgr, started: $t}' \
     "$REGISTRY" > "$tmp" && mv "$tmp" "$REGISTRY"
}

main() {
  local name=$1 role=$2 workdir=$3 initial=$4
  local manager=$CLAUDE_SESSION_NAME

  if [[ -z "$name" || -z "$role" || -z "$workdir" || -z "$initial" ]]; then
    echo "Usage: spawn.sh <name> <role> <workdir> \"<initial brief>\""
    echo "Example: spawn.sh dev-kiwi dev ~/Documents/skillscake \"build the MVP slice\""
    return 1
  fi

  # Export session identity + manager so request-manager / respond-to-request can target.
  # Positional prompt must come before flags (claude CLI behavior).
  local cmd="export CLAUDE_SESSION_NAME='$name' CLAUDE_SESSION_MANAGER='$manager'; cd '$workdir' && claude /role-$role --remote-control -n '$name' --model '$MODEL'"

  # Capture existing PIDs before spawn
  local existing_pids
  existing_pids=$(pgrep -f -- "--remote-control" 2>/dev/null || true)

  # Spawn in new Terminal window via AppleScript. Pin "Basic" profile for readability.
  local window_id
  window_id=$(osascript -e "
    tell application \"Terminal\"
      activate
      do script \"$cmd\" with profile \"Basic\"
    end tell" | grep -oE '[0-9]+$')

  if [[ -z "$window_id" ]]; then
    echo "Error: failed to spawn Terminal window" >&2
    return 1
  fi

  sleep 5  # wait for session to initialize

  # Find the newly spawned process (not in existing list)
  local all_pids
  all_pids=$(pgrep -f -- "--remote-control" 2>/dev/null || true)

  local pid
  while IFS= read -r p; do
    if ! grep -q "^$p$" <<< "$existing_pids"; then
      pid=$p
      break
    fi
  done < <(echo "$all_pids" | sort -rn)

  if [[ -z "$pid" ]]; then
    echo "Error: session spawned but could not find process" >&2
    return 1
  fi

  _reg_write "$name" "$window_id" "$pid" "$workdir" "$MODEL" "$manager"
  echo "Spawned '$name' — window=$window_id pid=$pid model=$MODEL role=$role manager=${manager:-none}"

  # Queue the initial brief once the role command has had time to load
  sleep 3
  local from=${CLAUDE_SESSION_NAME:-user}
  local msg="[from $from] $initial"
  local esc=${msg//\\/\\\\}
  esc=${esc//\"/\\\"}
  osascript >/dev/null <<APPLESCRIPT
tell application "Terminal" to do script "$esc" in window id $window_id
delay 0.3
tell application "System Events" to tell process "Terminal" to keystroke return
APPLESCRIPT
  echo "Initial brief queued for '$name'."
}

main "$@"
