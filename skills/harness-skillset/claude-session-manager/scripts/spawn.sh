#!/usr/bin/env bash
# Spawn a named Claude --remote-control session in a new Terminal window
# Usage: spawn.sh <name> <role> <workdir>
# Manager is always the spawner ($CLAUDE_SESSION_NAME); unset when spawned from the user's terminal.
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
  local name=$1 role=$2 workdir=$3
  local manager=$CLAUDE_SESSION_NAME

  if [[ -z "$name" || -z "$role" || -z "$workdir" ]]; then
    echo "Usage: spawn.sh <name> <role> <workdir>"
    echo "Example: spawn.sh dev-kiwi dev ~/Documents/skillscake"
    return 1
  fi

  # Export session identity + manager so request-manager / respond-to-request can target.
  # Positional prompt must come before flags (claude CLI behavior).
  local cmd="export CLAUDE_SESSION_NAME='$name' CLAUDE_SESSION_MANAGER='$manager'; cd '$workdir' && claude /role-$role --remote-control -n '$name' --model '$MODEL'"

  # Capture existing PIDs before spawn
  local existing_pids
  existing_pids=$(pgrep -f -- "--remote-control" 2>/dev/null || true)

  # Spawn in new Terminal window via AppleScript
  local window_id
  window_id=$(osascript -e "
    tell application \"Terminal\"
      activate
      do script \"$cmd\"
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
}

main "$@"
