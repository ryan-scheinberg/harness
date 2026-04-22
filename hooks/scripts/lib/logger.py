"""Audit log for hook decisions.

One JSON object per line, appended to ~/.claude-hooks/logs/YYYY-MM-DD.log.
Failures are silent — a logging crash must never block a tool call.
"""
from __future__ import annotations

import datetime as _dt
import json
import os
from pathlib import Path
from typing import Any


def log_dir() -> Path:
    d = Path.home() / ".claude-hooks" / "logs"
    try:
        d.mkdir(parents=True, exist_ok=True)
    except OSError:
        pass
    return d


def log_event(event: dict[str, Any]) -> None:
    """Append a single JSON-line event. Silent on any failure."""
    try:
        event.setdefault("ts", _dt.datetime.now(_dt.timezone.utc).isoformat())
        event.setdefault("pid", os.getpid())
        today = _dt.datetime.now(_dt.timezone.utc).strftime("%Y-%m-%d")
        path = log_dir() / f"{today}.log"
        with path.open("a", encoding="utf-8") as f:
            f.write(json.dumps(event, ensure_ascii=False, default=str) + "\n")
    except Exception:
        # Logging is best-effort. A failing log must not break tool calls.
        pass
