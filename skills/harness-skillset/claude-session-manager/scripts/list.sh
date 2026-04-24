#!/usr/bin/env bash
# List sessions from registry, pruning entries whose tmux session has died.

set -e

REGISTRY=~/.claude/session-registry.json
TMUX=/opt/homebrew/bin/tmux

main() {
  if [[ ! -f "$REGISTRY" ]]; then
    echo "No active sessions"
    return 0
  fi

  # Drop entries whose tmux session no longer exists — keeps registry self-healing.
  local names tmp
  names=$(jq -r 'keys[]' "$REGISTRY")
  tmp=$(mktemp)
  cp "$REGISTRY" "$tmp"
  while IFS= read -r n; do
    [[ -z "$n" ]] && continue
    if ! "$TMUX" has-session -t "$n" 2>/dev/null; then
      jq --arg n "$n" 'del(.[$n])' "$tmp" > "$tmp.new" && mv "$tmp.new" "$tmp"
    fi
  done <<< "$names"
  mv "$tmp" "$REGISTRY"

  local count
  count=$(jq 'length' "$REGISTRY")

  if [[ "$count" -eq 0 ]]; then
    echo "No active sessions"
    return 0
  fi

  echo "Active sessions:"
  jq -r 'to_entries[] | "  \(.key)\t window=\(.value.window_id) model=\(.value.model) dir=\(.value.workdir)"' "$REGISTRY"
}

main "$@"
