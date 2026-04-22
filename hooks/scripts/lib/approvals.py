"""File-based approval tokens for MCP tool calls.

Claude records an approval by writing a token file to
    $TMPDIR/claude-hooks/approvals/<hash>.json
with TTL and a summary of what's approved. The PreToolUse hook consumes the
token (single-use) on match and allows the call through.

This is not a security boundary — Claude itself writes the tokens, so a
misbehaving agent could forge one. It exists to surface a "here's what I'm
about to do" moment in chat and require an explicit human OK loop in between.
"""
from __future__ import annotations

import hashlib
import json
import os
import re
import tempfile
import time
from pathlib import Path
from typing import Any


DEFAULT_TTL_SECONDS = 600  # 10 minutes


def approvals_dir() -> Path:
    d = Path(tempfile.gettempdir()) / "claude-hooks" / "approvals"
    d.mkdir(parents=True, exist_ok=True)
    return d


def token_hash(tool_name: str, tool_input: Any) -> str:
    """Deterministic hash of a tool call for approval-token matching."""
    blob = json.dumps(
        {"tool": tool_name, "input": tool_input},
        sort_keys=True,
        ensure_ascii=False,
    )
    return hashlib.sha256(blob.encode("utf-8")).hexdigest()[:24]


def token_path(h: str) -> Path:
    return approvals_dir() / f"{h}.json"


def write_token(
    tool_matcher: str,
    tool_input: Any,
    summary: str,
    reason: str,
    ttl_seconds: int = DEFAULT_TTL_SECONDS,
    *,
    concrete_tool: str | None = None,
) -> Path:
    """Record an approval. `tool_matcher` is a regex (matches actual tool name
    when the hook fires); `concrete_tool` is the exact name we expect it to
    fire on, used for the hash. If concrete_tool is None, tool_matcher is also
    used as the hashed tool name (caller takes responsibility for exact match).
    """
    tool_for_hash = concrete_tool or tool_matcher
    h = token_hash(tool_for_hash, tool_input)
    payload = {
        "tool_matcher": tool_matcher,
        "tool_for_hash": tool_for_hash,
        "tool_input": tool_input,
        "input_hash": h,
        "summary": summary,
        "reason": reason,
        "approved_at": time.time(),
        "ttl_seconds": ttl_seconds,
    }
    p = token_path(h)
    p.write_text(json.dumps(payload, indent=2, ensure_ascii=False))
    return p


def consume_token(tool_name: str, tool_input: Any) -> dict[str, Any] | None:
    """If a matching token exists and is unexpired, delete it and return its
    payload. Otherwise return None."""
    h = token_hash(tool_name, tool_input)
    p = token_path(h)
    if not p.exists():
        return None
    try:
        data = json.loads(p.read_text())
    except (OSError, json.JSONDecodeError):
        # Corrupt token — best to delete and treat as absent.
        try:
            p.unlink()
        except OSError:
            pass
        return None
    age = time.time() - float(data.get("approved_at", 0))
    if age > float(data.get("ttl_seconds", DEFAULT_TTL_SECONDS)):
        try:
            p.unlink()
        except OSError:
            pass
        return None
    # Single-use — consume.
    try:
        p.unlink()
    except OSError:
        pass
    return data


def matcher_matches(matcher: str, tool_name: str) -> bool:
    try:
        return re.search(matcher, tool_name) is not None
    except re.error:
        return False
