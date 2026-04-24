#!/usr/bin/env bash
# Queue a message in your manager's tmux session.
# Usage: message.sh "<text>"
# Reads $CLAUDE_SESSION_MANAGER for the target. Fails if unset.

set -e

TMUX=/opt/homebrew/bin/tmux
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

if ! "$TMUX" has-session -t "$manager" 2>/dev/null; then
  echo "Manager tmux session '$manager' not found." >&2
  exit 1
fi

from=${CLAUDE_SESSION_NAME:-unknown}
# Flatten newlines so the whole message submits as one Claude turn.
flat=${text//$'\n'/ }
msg="[from $from] $flat"

"$TMUX" send-keys -t "$manager" -l "$msg"
"$TMUX" send-keys -t "$manager" Enter

echo "Message sent to manager '$manager'."
