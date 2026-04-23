#!/usr/bin/env bash
# Symlink every .md under agents/ into ~/.claude/agents/<name>.md. Safe to
# re-run. Harness is the source of truth; existing destinations are overwritten.

set -e

AGENTS_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
LINK_ROOT="$HOME/.claude/agents"

# Remove any symlink in LINK_ROOT that points back into AGENTS_DIR — catches
# renamed or deleted agents on re-run.
mkdir -p "$LINK_ROOT"
for child in "$LINK_ROOT"/*; do
  [[ -L "$child" ]] || continue
  target=$(readlink "$child")
  [[ "$target" == "$AGENTS_DIR"* ]] && rm "$child"
done

count=0
for agent in "$AGENTS_DIR"/*.md; do
  [[ -f "$agent" ]] || continue
  dest="$LINK_ROOT/$(basename "$agent")"
  rm -f "$dest"
  ln -s "$agent" "$dest"
  count=$((count+1))
done
echo "Agents: $count symlinked into $LINK_ROOT"
