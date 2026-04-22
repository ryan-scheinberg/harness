#!/usr/bin/env bash
# List all active sessions from registry

REGISTRY=~/.claude/session-registry.json

main() {
  if [[ ! -f "$REGISTRY" ]]; then
    echo "No active sessions"
    return 0
  fi

  local count
  count=$(jq 'length' "$REGISTRY" 2>/dev/null || echo 0)

  if [[ "$count" -eq 0 ]]; then
    echo "No active sessions"
    return 0
  fi

  echo "Active sessions:"
  jq -r 'to_entries[] | "  \(.key)\t pid=\(.value.pid) window=\(.value.window_id) model=\(.value.model) dir=\(.value.workdir)"' "$REGISTRY"
}

main "$@"
