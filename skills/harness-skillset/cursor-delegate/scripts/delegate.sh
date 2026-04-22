#!/usr/bin/env bash
# Spawn Composer 2 on a task in background. Returns job_id.
# Usage: delegate.sh <task> [workspace]

set -e

REGISTRY=~/.claude/cursor-registry.json
MAX_CONCURRENT=4

_reg_init() {
  [[ -f "$REGISTRY" ]] || echo '{}' > "$REGISTRY"
}

_count_active() {
  # Count jobs still running (process alive)
  local count=0
  while IFS= read -r pid; do
    [[ -z "$pid" ]] && continue
    if kill -0 "$pid" 2>/dev/null; then
      count=$((count+1))
    fi
  done < <(jq -r '.[].pid' "$REGISTRY" 2>/dev/null)
  echo "$count"
}

_reg_write() {
  local job_id=$1 pid=$2 workspace=$3 task=$4 log_file=$5
  local tmp
  tmp=$(mktemp)
  jq --arg j "$job_id" --argjson p "$pid" \
     --arg w "$workspace" --arg t "$task" --arg l "$log_file" \
     --arg ts "$(date -u +%FT%TZ)" \
     '.[$j] = {pid: $p, workspace: $w, task: $t, log_file: $l, started: $ts, status: "running"}' \
     "$REGISTRY" > "$tmp" && mv "$tmp" "$REGISTRY"
}

main() {
  local task=$1 workspace=${2:-.}

  if [[ -z "$task" ]]; then
    echo "Error: task is required" >&2
    echo "Usage: delegate.sh <task> [workspace]" >&2
    return 1
  fi

  _reg_init

  local active
  active=$(_count_active)
  if (( active >= MAX_CONCURRENT )); then
    echo "Error: $active cursor jobs running (max $MAX_CONCURRENT). Do something else or wait." >&2
    echo "Check: bash scripts/list.sh" >&2
    return 1
  fi

  local job_id="cursor-$(date +%s)-$$"
  local log_file="/tmp/cursor-delegate-${job_id}.log"

  nohup cursor agent \
    --print \
    --output-format json \
    --model composer-2 \
    --workspace "$workspace" \
    --trust \
    "$task" > "$log_file" 2>&1 &
  local pid=$!
  disown

  _reg_write "$job_id" "$pid" "$workspace" "$task" "$log_file"
  echo "Spawned $job_id (pid=$pid)"
  echo "Check: bash scripts/status.sh $job_id"
}

main "$@"
