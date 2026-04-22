#!/usr/bin/env bash
# Gracefully shut down a named session

set -e

REGISTRY=~/.claude/session-registry.json

_reg_init() {
  [[ -f "$REGISTRY" ]] || echo '{}' > "$REGISTRY"
}

_reg_get() {
  local name=$1 field=$2
  jq -r --arg n "$name" --arg f "$field" '.[$n][$f] // empty' "$REGISTRY"
}

_reg_delete() {
  local name=$1
  local tmp=$(mktemp)
  jq --arg n "$name" 'del(.[$n])' "$REGISTRY" > "$tmp" && mv "$tmp" "$REGISTRY"
}

main() {
  local name=$1

  if [[ -z "$name" ]]; then
    echo "Error: name is required" >&2
    echo "Usage: shutdown.sh <name>" >&2
    echo "Example: shutdown.sh Worker1" >&2
    return 1
  fi

  _reg_init

  local window_id pid
  window_id=$(_reg_get "$name" window_id)
  pid=$(_reg_get "$name" pid)

  if [[ -z "$window_id" || -z "$pid" ]]; then
    echo "Error: '$name' not found in registry" >&2
    return 1
  fi

  # Check if process is still alive
  if ! kill -0 "$pid" 2>/dev/null; then
    echo "Warning: process already exited — cleaning up registry"
    _reg_delete "$name"
    osascript -e "tell application \"Terminal\" to close (every window whose id is $window_id) saving no" 2>/dev/null || true
    return 0
  fi

  echo "Shutting down '$name'..."

  # Send /exit to gracefully exit the session
  osascript -e "tell application \"Terminal\" to do script \"/exit\" in tab 1 of window id $window_id" 2>/dev/null || true

  # Wait for process to exit (up to 10 seconds)
  local i=0
  while kill -0 "$pid" 2>/dev/null && (( i < 50 )); do
    sleep 0.2
    (( i++ ))
  done

  # If still running, force with SIGINT
  if kill -0 "$pid" 2>/dev/null; then
    echo "Warning: forcing shutdown with SIGINT"
    kill -INT "$pid" 2>/dev/null || true
    sleep 1
  fi

  # Exit the shell too so the window has no running process, then force-close
  osascript -e "tell application \"Terminal\" to do script \"exit\" in tab 1 of window id $window_id" 2>/dev/null || true
  sleep 0.5
  osascript -e "tell application \"Terminal\" to close (every window whose id is $window_id) saving no" 2>/dev/null || true

  # Clean up registry
  _reg_delete "$name"
  echo "Shut down '$name'"
}

main "$@"
