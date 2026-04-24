#!/usr/bin/env bash
# Queue a message in your manager's tmux session.
# Usage: message.sh "<text>"
# Reads $CLAUDE_SESSION_MANAGER for the target. Fails if unset.

set -e

TMUX_BIN=/opt/homebrew/bin/tmux
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

if ! "$TMUX_BIN" has-session -t "$manager" 2>/dev/null; then
  echo "Manager tmux session '$manager' not found." >&2
  exit 1
fi

from=${CLAUDE_SESSION_NAME:-unknown}
# Flatten newlines so the whole message submits as one Claude turn.
flat=${text//$'\n'/ }
msg="[from $from] $flat"

"$TMUX_BIN" send-keys -t "$manager" -l "$msg"
# Wait out Claude TUI's bracketed-paste detection window — rapid send-keys
# input gets coalesced as a "paste" and an immediate Enter falls inside it.
sleep 0.5
"$TMUX_BIN" send-keys -t "$manager" Enter

echo "Message sent to manager '$manager'."
