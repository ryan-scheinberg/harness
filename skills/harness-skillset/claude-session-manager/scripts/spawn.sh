#!/usr/bin/env bash
# Spawn a named Claude --remote-control session in a new Terminal window
# Usage: spawn.sh <name> [workdir]
# Model is hardcoded — update MODEL below when a new frontier model ships.

set -e

MODEL="claude-opus-4-7[1m]"
REGISTRY=~/.claude/session-registry.json

_reg_init() {
  [[ -f "$REGISTRY" ]] || echo '{}' > "$REGISTRY"
}

_reg_write() {
  local name=$1 window_id=$2 pid=$3 workdir=$4 model=$5
  _reg_init
  local tmp=$(mktemp)
  jq --arg n "$name" --argjson w "$window_id" --argjson p "$pid" \
     --arg d "$workdir" --arg m "$model" --arg t "$(date -u +%FT%TZ)" \
     '.[$n] = {window_id: $w, pid: $p, workdir: $d, model: $m, started: $t}' \
     "$REGISTRY" > "$tmp" && mv "$tmp" "$REGISTRY"
}

main() {
  local name=$1 workdir=${2:-$HOME}

  if [[ -z "$name" ]]; then
    echo "Error: name is required"
    echo "Usage: spawn.sh <name> [workdir]"
    echo "Example: spawn.sh Worker1 ~/project"
    return 1
  fi

  # Capture existing PIDs before spawn
  local existing_pids
  existing_pids=$(pgrep -f "claude --remote-control" 2>/dev/null || true)

  # Spawn in new Terminal window via AppleScript
  local window_id
  window_id=$(osascript -e "
    tell application \"Terminal\"
      activate
      do script \"cd '$workdir' && claude --remote-control -n '$name' --model '$MODEL'\"
    end tell" | grep -oE '[0-9]+$')

  if [[ -z "$window_id" ]]; then
    echo "Error: failed to spawn Terminal window" >&2
    return 1
  fi

  sleep 5  # wait for session to initialize

  # Find the newly spawned process (not in existing list)
  local all_pids
  all_pids=$(pgrep -f "claude --remote-control" 2>/dev/null || true)

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

  _reg_write "$name" "$window_id" "$pid" "$workdir" "$MODEL"
  echo "Spawned '$name' — window=$window_id pid=$pid model=$MODEL"
}

main "$@"
