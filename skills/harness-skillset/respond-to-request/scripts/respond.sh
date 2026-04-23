#!/usr/bin/env bash
# Reply to a subordinate's request by session name.
# Usage: respond.sh <session_name> "<text>"

set -e

REGISTRY=~/.claude/session-registry.json
target=$1
text=$2

if [[ -z "$target" || -z "$text" ]]; then
  echo "Usage: respond.sh <session_name> \"<text>\"" >&2
  exit 1
fi

if [[ ! -f "$REGISTRY" ]]; then
  echo "No session registry at $REGISTRY." >&2
  exit 1
fi

window_id=$(jq -r --arg n "$target" '.[$n].window_id // empty' "$REGISTRY")

if [[ -z "$window_id" ]]; then
  echo "Session '$target' not found in registry." >&2
  exit 1
fi

from=${CLAUDE_SESSION_NAME:-manager}
msg="[from $from] $text"

esc=${msg//\\/\\\\}
esc=${esc//\"/\\\"}

osascript -e "tell application \"Terminal\" to do script \"$esc\" in window id $window_id" >/dev/null

echo "Reply queued for '$target' (window $window_id)."
