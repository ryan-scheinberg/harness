#!/usr/bin/env bash
# Check status of a cursor job. Returns output if done.
# Usage: status.sh <job_id>

set -e

REGISTRY=~/.claude/cursor-registry.json

_reg_get() {
  local job_id=$1 field=$2
  jq -r --arg j "$job_id" --arg f "$field" '.[$j][$f] // empty' "$REGISTRY"
}

_reg_update_status() {
  local job_id=$1 status=$2
  local tmp=$(mktemp)
  jq --arg j "$job_id" --arg s "$status" '.[$j].status = $s' "$REGISTRY" > "$tmp" && mv "$tmp" "$REGISTRY"
}

main() {
  local job_id=$1

  if [[ -z "$job_id" ]]; then
    echo "Error: job_id is required" >&2
    echo "Usage: status.sh <job_id>" >&2
    return 1
  fi

  if [[ ! -f "$REGISTRY" ]]; then
    echo "Error: registry not found" >&2
    return 1
  fi

  local pid log_file status
  pid=$(_reg_get "$job_id" pid)
  log_file=$(_reg_get "$job_id" log_file)
  status=$(_reg_get "$job_id" status)

  if [[ -z "$pid" ]]; then
    echo "Error: '$job_id' not found" >&2
    return 1
  fi

  # Still running?
  if kill -0 "$pid" 2>/dev/null; then
    echo "status: running"
    return 0
  fi

  # Ended — mark done
  if [[ "$status" == "running" ]]; then
    _reg_update_status "$job_id" "done"
  fi

  echo "status: done"
  if [[ -f "$log_file" ]]; then
    echo "---"
    cat "$log_file"
  fi
}

main "$@"
