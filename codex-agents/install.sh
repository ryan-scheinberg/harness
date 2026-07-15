#!/usr/bin/env bash
# Install harness custom agents into Codex.

set -euo pipefail

SOURCE_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
DEST_DIR="$HOME/.codex/agents"
MARKER="# Managed by harness codex-agents/install.sh"

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

echo "Codex agents: $count installed into $DEST_DIR"
