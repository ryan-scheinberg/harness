#!/usr/bin/env python3
"""PostToolUse hook: append a tool-call completion event to the audit log.

Never blocks, never fails loudly.
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from lib.logger import log_event  # noqa: E402


def main() -> int:
    try:
        raw = sys.stdin.read()
        if not raw.strip():
            return 0
        payload = json.loads(raw)
    except Exception as e:
        log_event({"event": "post_log", "decision": "parse_error", "error": str(e)})
        return 0

    try:
        log_event({
            "event": "post_log",
            "tool": payload.get("tool_name"),
            "tool_input_brief": _brief(payload.get("tool_input")),
            "tool_response_brief": _brief(payload.get("tool_response")),
        })
    except Exception:
        pass
    return 0


def _brief(v, limit: int = 200) -> str:
    try:
        s = json.dumps(v, ensure_ascii=False, default=str)
    except Exception:
        s = str(v)
    return s if len(s) <= limit else s[:limit] + "…"


if __name__ == "__main__":
    raise SystemExit(main())
