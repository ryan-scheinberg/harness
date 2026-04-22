#!/usr/bin/env bash
# Install harness safety config into ~/.claude/settings.json.
#
# Owns: permissions.deny (fully replaced), and the single PreToolUse hook
# entry pointing at bash_gate.py (replaced or added).
# Preserves: everything else in ~/.claude/settings.json.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$HERE/settings.json"
HOOK="$HERE/bash_gate.py"
DST="${HOME}/.claude/settings.json"

command -v jq >/dev/null || { echo "jq is required (brew install jq)"; exit 1; }
[[ -f "$SRC"  ]] || { echo "missing $SRC"; exit 1; }
[[ -f "$HOOK" ]] || { echo "missing $HOOK"; exit 1; }
mkdir -p "$(dirname "$DST")"
[[ -f "$DST" ]] || echo '{}' > "$DST"
chmod +x "$HOOK"

HOOK_CMD="python3 $HOOK"

jq -n \
  --slurpfile dst <(cat "$DST") \
  --slurpfile src <(cat "$SRC") \
  --arg hook "$HOOK_CMD" '
    ($dst[0] // {}) as $d |
    ($src[0].permissions // {}) as $s |
    ($d.hooks // {}) as $dh |
    (($dh.PreToolUse // []) | map(select(
      (.matcher != "Bash") or
      ((.hooks // []) | any((.command // "") | contains("bash_gate.py")) | not)
    )) + [{matcher:"Bash", hooks:[{type:"command", command:$hook}]}]) as $new_pre |
    $d
    | .permissions = (($d.permissions // {}) + $s)
    | .hooks = ($dh + {PreToolUse: $new_pre})
  ' > "$DST.tmp"

mv "$DST.tmp" "$DST"
echo "installed -> $DST"
echo "deny rules: $(jq '.permissions.deny | length' "$DST")"
echo "hook: $HOOK_CMD"
