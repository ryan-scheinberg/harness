#!/usr/bin/env python3
"""CLI helper to record an MCP approval token.

Used by Claude after Ryan says OK in chat, before re-issuing the gated MCP
tool call. Writes a single-use token to $TMPDIR/claude-hooks/approvals/ that
the PreToolUse hook will consume on match.

Usage:
    python3 approve.py --tool '<exact tool_name>' \\
                       --input '<tool_input JSON>' \\
                       --reason '<what Ryan said>' \\
                       [--summary '<one-line>'] \\
                       [--ttl 600]
"""
from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from lib.approvals import write_token, DEFAULT_TTL_SECONDS  # noqa: E402


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--tool", required=True, help="exact tool_name to approve")
    ap.add_argument("--input", required=True, help="tool_input as JSON string")
    ap.add_argument("--reason", required=True, help="why (what Ryan said)")
    ap.add_argument("--summary", default=None, help="one-line human summary")
    ap.add_argument("--ttl", type=int, default=DEFAULT_TTL_SECONDS, help="seconds until expiry")
    args = ap.parse_args()

    try:
        tool_input = json.loads(args.input)
    except json.JSONDecodeError as e:
        print(f"--input must be valid JSON: {e}", file=sys.stderr)
        return 1

    path = write_token(
        tool_matcher=args.tool,
        tool_input=tool_input,
        summary=args.summary or f"{args.tool} call",
        reason=args.reason,
        ttl_seconds=args.ttl,
        concrete_tool=args.tool,
    )
    print(f"approval token written: {path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
