# Harness repo — agent notes

This repository is the **source of truth** for the user's Claude Code / Cursor harness. Skills, subagents, the global `CLAUDE.md`, safety hooks, and local schedules all live here and are version-controlled in one place.

## Install / refresh

| Command | What it does |
| --- | --- |
| `./skills/install.sh` | Discovers every `SKILL.md` under `skills/` (any depth, skipping `.git/`) and flat-symlinks each directory into `~/.claude/skills/<name>/` and `~/.cursor/skills/<name>/`. Prunes stale symlinks pointing into `$REPO_ROOT` or legacy `~/Documents/skills/`. You can run this |
| `./agents/install.sh` | Symlinks every `.md` under `agents/` into `~/.claude/agents/<name>.md`. Prunes stale symlinks pointing into `agents/`. You can run this |
| `./hooks/install.sh` | Merges safety hooks (native deny rules + PreToolUse bash gate) into `~/.claude/settings.json`. Writes to user settings. The user will run this |
| `./schedules/install.sh` | Syncs `schedules/*.cron` specs into the user's crontab under a delimited block. Writes to crontab, and needs macOS Full Disk Access. The user will run this |

`CLAUDE.md` is a one-time manual symlink: `ln -sf "$PWD/CLAUDE.md" ~/.claude/CLAUDE.md`

Installers are Bash 3.2-compatible so they run on macOS's default shell. Re-run an installer after adding, moving, or renaming anything in its directory. The repo is the source of truth: installers unconditionally overwrite their destinations, no adoption check or diff dance

## Constraints

- Two skill folders with the same basename anywhere under `skills/` will fail the script. Names must be unique across the whole tree since loaders flatten by basename
- Agent file basenames must be unique under `agents/`

## Hooks

`hooks/settings.json` is the source of truth for `permissions.deny`. `hooks/install.sh` replaces the whole array in `~/.claude/settings.json` on each run, so any deny rule added through the Claude Code UI gets wiped. Copy it into `hooks/settings.json` to persist

When `bash_gate.py` blocks a command, tell the user what it wanted to do. If they OK it, re-run with an inline shell comment `# claude-hook-approved: <what the user said>`. Bash ignores the comment, the gate allows it through, and the approval shows up in the transcript for audit

## Schedules

`schedules/` holds local cron jobs. To add a recurring `claude -p` run, use the **`claude-cron`** skill: its `scripts/add.sh` generates the spec and syncs the crontab. Direct spec authoring is supported but rarely needed

Non-obvious bits:
- **Crontab edits inside the harness block don't stick.** `schedules/install.sh` rebuilds the delimited `# >>> harness schedules >>>` block on every run. Non-harness crontab entries pass through, but any edit inside the block via `crontab -e` gets wiped. Change the `.cron` spec instead
- **macOS Full Disk Access.** `crontab` needs FDA granted to the shell running the installer (System Settings → Privacy & Security → Full Disk Access → add Terminal/iTerm). Claude Code's own shell doesn't have FDA, so run `./schedules/install.sh` from a terminal you've granted access to
- **`state/` is gitignored.** The wrapper only updates the stamp on exit-0 runs, so failures retry on the next tick instead of silently falling behind a day

## Session hierarchy

Multiple spawned sessions form a strict one-layer-down chain: **user → CEO → manager → architect/dev**. `claude-session-manager/scripts/spawn.sh` always derives the spawned session's manager from the spawner's `$CLAUDE_SESSION_NAME` — whoever runs spawn.sh becomes the new session's manager, no override. Spawned from the user's terminal (no env var set), the manager field is empty, which is correct for the CEO

- **CEO** spawns managers only. Routes work and holds the portfolio view; does not write code or produce briefs
- **Manager** owns a workstream end-to-end. Spawns an architect when the work needs real slicing, then up to 3 devs. Fields their questions, verifies output, ships
- **Architect** plans and exits. Hands back `PROJECT_BRIEF.md` + `SLICES.md` via `request-manager` and departs. Does not supervise devs — that decouples planning from execution so devs have exactly one upward channel
- **Dev** implements a single slice, verifies, reports back via `request-manager`

Role skills live under `skills/roles-skillset/role-<name>/` and are applied at spawn time via `/role-<name>` (the slash command the spawn script invokes inside the new session)

Direct user contact surfaces: CEO session (standing channel) and architect during `define-project` / `iterate-plan` (short bursts for scoping and the grill). Everything else reaches the user only by bubbling up the chain. Subagents (e.g. `verify`) never contact the user — they return to their parent

## Inter-session messaging

Two skills wire the hierarchy: `request-manager` (subordinate → manager) and `respond-to-request` (manager → subordinate), both in `skills/harness-skillset/`. Transport is AppleScript `do script "<text>" in window id X` against the target session's Terminal window — Claude Code's TUI queues typed input when the target is mid-turn, so no polling, inbox files, or reply tracking

- Session identity flows via env: spawn.sh exports `CLAUDE_SESSION_NAME` and `CLAUDE_SESSION_MANAGER` before `claude` launches. The registry at `~/.claude/session-registry.json` gained a `manager` field. Both message scripts read registry + env to route
- `PushNotification` is the fallback for sessions with no manager configured — normally the CEO, but also any session the user spawns directly from their terminal (a manager or architect launched without going through a CEO first). Everyone else escalates through their own manager, even for launch/spend/compliance. Single upward channel per session, and only the top of the chain ever pings the user
- `request-manager` does not end the agent's turn. Blocking asks (permission, unresolved tradeoff) require the agent to end the turn after sending so the reply lands as next input; non-blocking sends (status, slice-done, hand-off) keep working

## Editing harness content

When you fix friction and the right place to capture it is a skill, agent, or `AGENTS.md`, follow the **`updating-ai-knowledge`** skill. Especially: do not change a skill's `name:` field (it aligns with symlink names and loaders), and prefer small, evidence-based edits

**Keep `README.md` in sync** with new skills, agents, and major structural changes. The README is the canonical reference for harness layout

### Voice

Match the surrounding file before writing anything new. Existing SKILL.md and role files are the reference — the ethos is enforced through them, not a style guide. The harness is a vessel, not a sports car: edits are deliberate, existing patterns beat personal preferences from other repos

- Drop end-of-line periods. Keep punctuation only where it separates mid-line clauses
- Imperative verbs, sentence fragments where tighter. No "you should", "it's important", "remember to", "always"
- Every rule carries its reason in one clause, not a paragraph. "Green tests are necessary, not sufficient" beats three sentences about testing discipline
- Admit cognitive limits where real (manager cannot hold full dev context; architect cannot ship slices themselves). Keeps agents from faking capabilities they don't have
- No meta-narration or trust-building filler. Describe what to do, skip how the agent should feel about doing it
- Bold lead verb, then a fragment — the user's bullet format. Not "**Spawn devs:** This is how you should..." but "**Spawn devs** for parallelizable slices. Up to 3 concurrent"
