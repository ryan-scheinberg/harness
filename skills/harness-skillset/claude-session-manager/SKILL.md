---
name: claude-session-manager
description: Spawn and manage multiple independent Claude --remote-control sessions. Each is controllable from terminal and iOS Claude simultaneously. Use when the user wants to dispatch remote sessions.
---

Spawn independent `claude --remote-control` sessions in Terminal windows

## Quick Start

Spawn sessions:

```bash
bash scripts/spawn.sh stripe-webhooks-mango ~/project
```

## Naming

Unless the user specified, use two words describing what the session is for plus one random fruit or veggie, hyphen-separated

List sessions:

```bash
bash scripts/list.sh
```

Shut down a session:

```bash
bash scripts/shutdown.sh web-qa-banana
```

## How it works

Each spawned session:
- Runs in a new Terminal window (visible and interactive)
- Can be controlled from terminal directly or from phone
- Changes sync bidirectionally across terminal and remote

Sessions are registered in `~/.claude/session-registry.json` — managed automatically, no manual editing needed

**Note**: Multiple dispatcher agents may spawn sessions concurrently. `list.sh` shows all registered sessions regardless of which dispatcher created them. Only clean up extra sessions if the user requests it
