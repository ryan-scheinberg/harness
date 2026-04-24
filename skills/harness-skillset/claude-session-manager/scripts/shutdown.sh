#!/usr/bin/env bash
# Gracefully shut down a tmux-hosted session and close its viewer window.

set -e

REGISTRY=~/.claude/session-registry.json
TMUX_BIN=/opt/homebrew/bin/tmux

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
    return 1
  fi

  _reg_init

  local window_id
  window_id=$(_reg_get "$name" window_id)

  echo "Shutting down '$name'..."

  # Try a graceful /exit through tmux first; then kill the tmux session if it lingers.
  if "$TMUX_BIN" has-session -t "$name" 2>/dev/null; then
    "$TMUX_BIN" send-keys -t "$name" -l "/exit" 2>/dev/null || true
    "$TMUX_BIN" send-keys -t "$name" Enter 2>/dev/null || true
    local i=0
    while "$TMUX_BIN" has-session -t "$name" 2>/dev/null && (( i < 25 )); do
      sleep 0.2
      (( i++ ))
    done
    if "$TMUX_BIN" has-session -t "$name" 2>/dev/null; then
      echo "Warning: forcing tmux kill-session"
      "$TMUX_BIN" kill-session -t "$name" 2>/dev/null || true
    fi
  else
    echo "Note: no live tmux session — registry cleanup only"
  fi

  # Close the viewer Terminal window if we have one
  if [[ -n "$window_id" && "$window_id" != "0" ]]; then
    osascript -e "tell application \"Terminal\" to close (every window whose id is $window_id) saving no" 2>/dev/null || true
  fi

  _reg_delete "$name"
  echo "Shut down '$name'"
}

main "$@"
