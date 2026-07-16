#!/usr/bin/env bash
# Install harness custom agents and multi-agent defaults into Codex.

set -euo pipefail

SOURCE_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
DEST_DIR="$HOME/.codex/agents"
MARKER="# Managed by harness codex-agents/install.sh"
CONFIG_FILE="$HOME/.codex/config.toml"
CONFIG_START="# >>> harness Codex multi-agent >>>"
CONFIG_END="# <<< harness Codex multi-agent <<<"

mkdir -p "$DEST_DIR"
shopt -s nullglob

count=0
for source in "$SOURCE_DIR"/*.toml; do
  cp "$source" "$DEST_DIR/$(basename "$source")"
  count=$((count + 1))
done

for installed in "$DEST_DIR"/*.toml; do
  [[ "$(head -n 1 "$installed")" == "$MARKER" ]] || continue
  [[ -f "$SOURCE_DIR/$(basename "$installed")" ]] || rm "$installed"
done

install_multi_agent_config() {
  local tmp
  tmp=$(mktemp "${CONFIG_FILE}.XXXXXX")

  if [[ -f "$CONFIG_FILE" ]]; then
    awk -v start="$CONFIG_START" -v end="$CONFIG_END" '
      $0 == start { managed = 1; next }
      $0 == end { managed = 0; next }
      !managed { lines[++count] = $0 }
      END {
        while (count > 0 && lines[count] == "") count--
        for (i = 1; i <= count; i++) print lines[i]
      }
    ' "$CONFIG_FILE" > "$tmp"
  fi

  if grep -Eq '^[[:space:]]*\[features\.multi_agent_v2\]|^[[:space:]]*(features\.)?multi_agent_v2[.=[:space:]]' "$tmp"; then
    rm "$tmp"
    echo "error: unmanaged multi_agent_v2 config already exists in $CONFIG_FILE" >&2
    exit 1
  fi

  [[ ! -s "$tmp" ]] || printf '\n' >> "$tmp"
  printf '%s\n' \
    "$CONFIG_START" \
    '[features.multi_agent_v2]' \
    'hide_spawn_agent_metadata = false' \
    'max_concurrent_threads_per_session = 8' \
    "$CONFIG_END" >> "$tmp"
  mv "$tmp" "$CONFIG_FILE"
}

install_multi_agent_config

echo "Codex agents: $count installed into $DEST_DIR"
echo "Codex multi-agent defaults: installed into $CONFIG_FILE"
