---
name: claude-session-manager
description: Spawn and manage multiple independent Claude --remote-control sessions. Each is controllable from terminal and iOS Claude simultaneously. Use when the user wants to dispatch remote sessions
---

Spawn independent `claude --remote-control` sessions in Terminal windows

## Quick Start

Spawn a session:

```bash
bash scripts/spawn.sh stripe-webhooks-kiwi dev ~/project "build the MVP slice from SLICES.md"
```
Required args: session name, role, workdir, initial brief

The spawned session's manager is your `$CLAUDE_SESSION_NAME`. New windows open in Terminal's "Basic" profile for readability

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
Required args: session name

## How it works

Each spawned session runs inside a `tmux` session named after the spawn (`smoke-test-lemon`, etc.) and is hosted by a Terminal window that attaches to it. The Terminal window is just a viewer — closing it detaches but does not kill the session. Re-attach any time with `tmux attach -t <name>`, including from a different terminal app like Warp

`spawn.sh` calls `tmux new-session` with `env -u TMUX` so it works when the caller is itself inside a tmux session — every spawned role lives in tmux, so any further spawn happens from inside one. Without unsetting `TMUX`, tmux refuses to nest

Inter-session messaging (`request-manager`, `respond-to-request`) targets the tmux session by name via `tmux send-keys`, so delivery and submit are focus-independent — no AppleScript keystroke roulette

Sessions are registered in `~/.claude/session-registry.json` for manager-chain metadata. `list.sh` self-prunes entries whose tmux session has died

**Note**: Multiple dispatcher agents may spawn sessions concurrently. `list.sh` shows all registered sessions regardless of which dispatcher created them. Only clean up extra sessions if the user requests it
