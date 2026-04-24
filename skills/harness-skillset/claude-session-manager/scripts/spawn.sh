#!/usr/bin/env bash
# Spawn a named Claude --remote-control session inside a tmux session, hosted in a Terminal window.
# Usage: spawn.sh <name> <role> <workdir> "<initial brief>"
# Manager is always the spawner ($CLAUDE_SESSION_NAME); unset when spawned from the user's terminal.
# Initial brief folds into the slash-command launch — one turn, no follow-up paste.
# Model is hardcoded — update MODEL below when a new frontier model ships.

set -e

MODEL="claude-opus-4-7[1m]"
REGISTRY=~/.claude/session-registry.json
TMUX_BIN=/opt/homebrew/bin/tmux

_reg_init() {
  [[ -f "$REGISTRY" ]] || echo '{}' > "$REGISTRY"
}

_reg_write() {
  local name=$1 window_id=$2 workdir=$3 model=$4 manager=$5
  _reg_init
  local tmp=$(mktemp)
  jq --arg n "$name" --argjson w "$window_id" \
     --arg d "$workdir" --arg m "$model" --arg mgr "$manager" --arg t "$(date -u +%FT%TZ)" \
     '.[$n] = {window_id: $w, workdir: $d, model: $m, manager: $mgr, started: $t}' \
     "$REGISTRY" > "$tmp" && mv "$tmp" "$REGISTRY"
}

main() {
  local name=$1 role=$2 workdir=$3 initial=$4
  local manager=$CLAUDE_SESSION_NAME

  if [[ -z "$name" || -z "$role" || -z "$workdir" || -z "$initial" ]]; then
    echo "Usage: spawn.sh <name> <role> <workdir> \"<initial brief>\""
    echo "Example: spawn.sh dev-kiwi dev ~/Documents/skillscake \"build the MVP slice\""
    return 1
  fi

  if "$TMUX_BIN" has-session -t "$name" 2>/dev/null; then
    echo "Error: tmux session '$name' already exists" >&2
    return 1
  fi

  # Role + brief go together as one slash-command invocation — one turn, no flaky post-spawn paste.
  # Flatten newlines (so the launch line stays a single shell command) and escape single quotes
  # in $initial using the bash '\'' close/escape/reopen idiom.
  local from=${CLAUDE_SESSION_NAME:-user}
  local oneline=${initial//$'\n'/ }
  local prompt_arg="/role-$role [from $from] ${oneline//"'"/"'\\''"}"

  # Create the tmux session detached, running claude with the role+brief as initial prompt.
  # Session identity + manager exported so request-manager / respond-to-request can route.
  # env -u TMUX so the spawn works when the caller is itself inside a tmux session
  # (CEO spawning manager, manager spawning architect/dev) — tmux refuses to nest by default.
  local launch="export CLAUDE_SESSION_NAME='$name' CLAUDE_SESSION_MANAGER='$manager'; cd '$workdir' && claude '$prompt_arg' --remote-control -n '$name' --model '$MODEL'"
  env -u TMUX "$TMUX_BIN" new-session -d -s "$name" "$launch"

  # Open a Terminal window that attaches to the tmux session as a viewer.
  # Closing the window detaches; the tmux session keeps running.
  # The trailing `; exit` makes the host shell exit when tmux detaches/dies,
  # so the Terminal window auto-closes (subject to the user's "close on shell
  # exit" pref) even when shutdown.sh can't reach it via window_id.
  local attach_cmd="$TMUX_BIN attach -t $name; exit"
  local as_cmd=${attach_cmd//\\/\\\\}
  as_cmd=${as_cmd//\"/\\\"}
  local window_id
  window_id=$(osascript -e "
    tell application \"Terminal\"
      activate
      set newTab to do script \"$as_cmd\"
      set current settings of newTab to settings set \"Basic\"
      return id of front window
    end tell" | grep -oE '[0-9]+$')

  if [[ -z "$window_id" ]]; then
    echo "Warning: failed to open viewer window — tmux session is still running, attach with: tmux attach -t $name" >&2
    window_id=0
  fi

  _reg_write "$name" "$window_id" "$workdir" "$MODEL" "$manager"
  echo "Spawned '$name' — tmux=$name window=$window_id model=$MODEL role=$role manager=${manager:-none}"
}

main "$@"
