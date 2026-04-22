#!/usr/bin/env python3
"""PreToolUse hook for the Bash tool.

Reads a PreToolUse payload on stdin, enforces HARD_BLOCK and APPROVAL_GATE
rules from lib/patterns.py, logs the decision, exits:
  0  -> allow
  2  -> block (stderr is shown to Claude)
  0  -> also on any exception (fail-open invariant)

Payload shape (Claude Code / Cowork hooks, informally):
{
  "hook_event_name": "PreToolUse",
  "tool_name": "Bash",
  "tool_input": {"command": "<cmd>", ...},
  ...
}
"""
from __future__ import annotations

import json
import os
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from lib import patterns as P  # noqa: E402
from lib.logger import log_event  # noqa: E402


def _heartbeat() -> None:
    """Write a heartbeat so we can verify hooks are wired up without tailing logs."""
    try:
        import tempfile
        p = Path(tempfile.gettempdir()) / "claude-hooks" / "heartbeat.txt"
        p.parent.mkdir(parents=True, exist_ok=True)
        import datetime as _dt
        ts = _dt.datetime.now(_dt.timezone.utc).isoformat()
        with p.open("a", encoding="utf-8") as f:
            f.write(f"{ts} bash_gate\n")
    except Exception:
        pass


def run(payload: dict) -> tuple[int, str]:
    command = (
        (payload.get("tool_input") or {}).get("command")
        or ""
    )
    if not command:
        return 0, ""

    # 1) Hard-block: fires even if an approval marker is present.
    hit = P.match_first(command, P.HARD_BLOCK)
    if hit is not None:
        log_event({
            "event": "bash_gate",
            "decision": "hard_block",
            "reason": hit.label,
            "command": command,
        })
        msg = (
            f"BLOCKED (hard): {hit.label}. This is permanently blocked and "
            "cannot be overridden in-session — if you truly need it, tell Ryan "
            "and have him run it manually in Terminal."
        )
        return 2, msg

    # 2) Approval gate: require marker.
    hit = P.match_first(command, P.APPROVAL_GATE)
    if hit is not None:
        has_marker, reason = P.has_approval_marker(command)
        if has_marker:
            log_event({
                "event": "bash_gate",
                "decision": "approved",
                "reason": hit.label,
                "approval_reason": reason,
                "command": command,
            })
            return 0, ""
        log_event({
            "event": "bash_gate",
            "decision": "requires_approval",
            "reason": hit.label,
            "command": command,
        })
        msg = (
            f"REQUIRES APPROVAL: {hit.label}.\n"
            f"Command: {command}\n"
            "Ask Ryan for approval in chat. When he says ok, re-issue the "
            "command with an approval comment anywhere in it, e.g.:\n"
            "    # claude-hook-approved: <short reason Ryan approved>\n"
            f"    {command}"
        )
        return 2, msg

    # 3) Clear — log as info only if log is enabled.
    log_event({
        "event": "bash_gate",
        "decision": "allow",
        "command": command,
    })
    return 0, ""


def main() -> int:
    _heartbeat()
    try:
        raw = sys.stdin.read()
        if not raw.strip():
            return 0
        payload = json.loads(raw)
    except Exception as e:
        log_event({"event": "bash_gate", "decision": "fail_open", "error": str(e)})
        return 0

    try:
        code, msg = run(payload)
    except Exception as e:
        log_event({"event": "bash_gate", "decision": "fail_open", "error": str(e)})
        return 0  # fail-open invariant

    if msg:
        print(msg, file=sys.stderr)
    return code


if __name__ == "__main__":
    raise SystemExit(main())
