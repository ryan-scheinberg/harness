#!/usr/bin/env bash
# Queue a message in your manager's Claude session.
# Usage: message.sh "<text>"
# Reads $CLAUDE_SESSION_MANAGER for the target. Fails if unset.

set -e

REGISTRY=~/.claude/session-registry.json
text=$1

if [[ -z "$text" ]]; then
  echo "Usage: message.sh \"<text>\"" >&2
  exit 1
fi

if [[ -z "$CLAUDE_SESSION_MANAGER" ]]; then
  echo "No manager set for this session. Escalate to the user via PushNotification instead." >&2
  exit 1
fi

manager=$CLAUDE_SESSION_MANAGER

if [[ ! -f "$REGISTRY" ]]; then
  echo "No session registry at $REGISTRY." >&2
  exit 1
fi

window_id=$(jq -r --arg n "$manager" '.[$n].window_id // empty' "$REGISTRY")

if [[ -z "$window_id" ]]; then
  echo "Manager session '$manager' not found in registry." >&2
  exit 1
fi

from=${CLAUDE_SESSION_NAME:-unknown}
msg="[from $from] $text"

# Escape for AppleScript double-quoted string: backslash then double-quote
esc=${msg//\\/\\\\}
esc=${esc//\"/\\\"}

osascript -e "tell application \"Terminal\" to do script \"$esc\" in window id $window_id" >/dev/null

echo "Message queued for manager '$manager' (window $window_id)."
