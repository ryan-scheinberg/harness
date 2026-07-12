#!/usr/bin/env python3
"""Long Bash timeout for codex courier calls.

Fires on PreToolUse for Bash. A codex-companion.mjs `task --wait` call blocks
until the codex process finishes building — far past the 2-minute Bash default,
and past the few minutes a courier guesses on its own. Enforces a 4-hour
floor so orchestrator spawn prompts stay plain task text.

Fail-open on any exception — a crashing hook must not brick Claude.
"""
from __future__ import annotations
import json, sys

TIMEOUT_MS = 14_400_000

try:
    data = json.load(sys.stdin)
    tool_input = data.get("tool_input", {})
    command = tool_input.get("command", "")
    if "codex-companion.mjs" in command and (tool_input.get("timeout") or 0) < TIMEOUT_MS:
        print(json.dumps({
            "hookSpecificOutput": {
                "hookEventName": "PreToolUse",
                "updatedInput": {**tool_input, "timeout": TIMEOUT_MS},
            }
        }))
except Exception:
    pass
