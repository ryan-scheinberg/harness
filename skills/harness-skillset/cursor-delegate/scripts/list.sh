#!/usr/bin/env bash
# List all cursor jobs
# Usage: list.sh

set -e

REGISTRY=~/.claude/cursor-registry.json

main() {
  if [[ ! -f "$REGISTRY" ]] || [[ $(jq 'length' "$REGISTRY" 2>/dev/null || echo 0) -eq 0 ]]; then
    echo "No jobs"
    return 0
  fi

  # Refresh status: mark dead processes as done
  local tmp
  tmp=$(mktemp)
  cp "$REGISTRY" "$tmp"
  while IFS= read -r job_id; do
    local pid status
    pid=$(jq -r --arg j "$job_id" '.[$j].pid' "$tmp")
    status=$(jq -r --arg j "$job_id" '.[$j].status' "$tmp")
    if [[ "$status" == "running" ]] && ! kill -0 "$pid" 2>/dev/null; then
      local tmp2
      tmp2=$(mktemp)
      jq --arg j "$job_id" '.[$j].status = "done"' "$tmp" > "$tmp2" && mv "$tmp2" "$tmp"
    fi
  done < <(jq -r 'keys[]' "$tmp")
  mv "$tmp" "$REGISTRY"

  echo "Cursor jobs:"
  jq -r 'to_entries[] | "  \(.key)\tstatus=\(.value.status) pid=\(.value.pid) workspace=\(.value.workspace)"' "$REGISTRY"
}

main "$@"
