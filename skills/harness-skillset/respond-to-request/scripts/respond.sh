#!/usr/bin/env bash
# Reply to a subordinate's request by tmux session name.
# Usage: respond.sh <session_name> "<text>"

set -e

TMUX_BIN=/opt/homebrew/bin/tmux
target=$1
text=$2

if [[ -z "$target" || -z "$text" ]]; then
  echo "Usage: respond.sh <session_name> \"<text>\"" >&2
  exit 1
fi

if ! "$TMUX_BIN" has-session -t "$target" 2>/dev/null; then
  echo "Session '$target' not found in tmux." >&2
  exit 1
fi

from=${CLAUDE_SESSION_NAME:-manager}
# Flatten newlines so the whole message submits as one Claude turn.
flat=${text//$'\n'/ }
msg="[from $from] $flat"

"$TMUX_BIN" send-keys -t "$target" -l "$msg"
"$TMUX_BIN" send-keys -t "$target" Enter

echo "Reply sent to '$target'."
