#!/usr/bin/env python3
"""PreToolUse hook for MCP write-shaped tools.

Matcher regex is wired in hooks.json; any tool whose name matches is gated.
Allowed only if a fresh, single-use approval token exists for the exact
(tool_name, tool_input) pair.

Fail-open on exception.
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from lib.approvals import consume_token  # noqa: E402
from lib.logger import log_event  # noqa: E402


def _summary(tool_name: str, tool_input: dict) -> str:
    """Best-effort one-line human-readable summary of an MCP call."""
    # Gmail-like
    if isinstance(tool_input, dict):
        if "to" in tool_input and ("subject" in tool_input or "body" in tool_input):
            return (
                f"email to {tool_input.get('to')} "
                f"subject={tool_input.get('subject', '')!r}"
            )
        if "channel" in tool_input and "text" in tool_input:
            return (
                f"post to channel {tool_input.get('channel')}: "
                f"{(tool_input.get('text') or '')[:80]!r}"
            )
        if "project_id" in tool_input or "repository" in tool_input:
            return f"git-host write on {tool_input.get('project_id') or tool_input.get('repository')}"
    return f"{tool_name} call ({json.dumps(tool_input, ensure_ascii=False)[:160]})"


def _heartbeat() -> None:
    try:
        import tempfile, datetime as _dt
        p = Path(tempfile.gettempdir()) / "claude-hooks" / "heartbeat.txt"
        p.parent.mkdir(parents=True, exist_ok=True)
        with p.open("a", encoding="utf-8") as f:
            f.write(f"{_dt.datetime.now(_dt.timezone.utc).isoformat()} mcp_write_gate\n")
    except Exception:
        pass


def run(payload: dict) -> tuple[int, str]:
    tool_name = payload.get("tool_name") or ""
    tool_input = payload.get("tool_input") or {}
    summary = _summary(tool_name, tool_input)

    token = consume_token(tool_name, tool_input)
    if token is not None:
        log_event({
            "event": "mcp_write_gate",
            "decision": "approved",
            "tool": tool_name,
            "summary": summary,
            "approval_reason": token.get("reason"),
        })
        return 0, ""

    log_event({
        "event": "mcp_write_gate",
        "decision": "requires_approval",
        "tool": tool_name,
        "summary": summary,
    })
    msg = (
        f"REQUIRES APPROVAL: MCP write — {tool_name}\n"
        f"What it will do: {summary}\n"
        "Ask Ryan for approval in chat. When he says ok, record the approval\n"
        "with scripts/approve.py and re-issue the tool call, e.g.:\n"
        f"    python3 ~/Documents/hooks/scripts/approve.py \\\n"
        f"        --tool '{tool_name}' \\\n"
        f"        --input '<the exact tool_input JSON>' \\\n"
        f"        --reason '<what Ryan said>'"
    )
    return 2, msg


def main() -> int:
    _heartbeat()
    try:
        raw = sys.stdin.read()
        if not raw.strip():
            return 0
        payload = json.loads(raw)
    except Exception as e:
        log_event({"event": "mcp_write_gate", "decision": "fail_open", "error": str(e)})
        return 0

    try:
        code, msg = run(payload)
    except Exception as e:
        log_event({"event": "mcp_write_gate", "decision": "fail_open", "error": str(e)})
        return 0

    if msg:
        print(msg, file=sys.stderr)
    return code


if __name__ == "__main__":
    raise SystemExit(main())
