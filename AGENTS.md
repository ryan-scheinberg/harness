# Harness repo — agent notes

This repository is the **source of truth** for the user's Claude Code / Cursor harness. Skills, subagents, the global `CLAUDE.md`, safety hooks, and local schedules all live here and are version-controlled in one place.

## Install / refresh

There is no single root installer. Each top-level directory owns its own `install.sh` — nothing is bundled, every installer is opt-in:

| Command | What it does |
| --- | --- |
| `./skills/install.sh` | Discovers every `SKILL.md` under `skills/` (any depth, skipping `.git/`) and flat-symlinks each directory into `~/.claude/skills/<name>/` and `~/.cursor/skills/<name>/`. Prunes stale symlinks pointing into `$REPO_ROOT` or legacy `~/Documents/skills/`. |
| `./agents/install.sh` | Symlinks every `.md` under `agents/` into `~/.claude/agents/<name>.md`. Prunes stale symlinks pointing into `agents/`. |
| `./hooks/install.sh` | Merges safety hooks (native deny rules + PreToolUse bash gate) into `~/.claude/settings.json`. Writes to user settings — opt-in. |
| `./schedules/install.sh` | Syncs `schedules/*.cron` specs into the user's crontab under a delimited block. Writes to crontab — opt-in, and needs macOS Full Disk Access. |

`CLAUDE.md` is a one-time manual symlink: `ln -sf "$PWD/CLAUDE.md" ~/.claude/CLAUDE.md`. No installer needed — it's one file and you only do it once.

Installers are Bash 3.2-compatible so they run on macOS's default shell. Re-run an installer after adding, moving, or renaming anything in its directory. The repo is the source of truth: installers unconditionally overwrite their destinations — no adoption check, no diff dance.

## Constraints

- Two skill folders with the same basename anywhere under `skills/` will fail the script — names must be unique across the whole tree (loaders flatten by basename).
- Agent file basenames must be unique under `agents/`.

## Hooks

`hooks/settings.json` is the source of truth for `permissions.deny`. `hooks/install.sh` replaces the whole array in `~/.claude/settings.json` on each run, so any deny rule added through the Claude Code UI gets wiped — copy it into `hooks/settings.json` to persist.

When `bash_gate.py` blocks a command, tell the user what it wanted to do. If they OK it, re-run with an inline shell comment `# claude-hook-approved: <what the user said>` — bash ignores the comment, the gate allows it through, and the approval shows up in the transcript for audit.

## Schedules

`schedules/` holds local cron jobs. To add a recurring `claude -p` run, use the **`claude-cron`** skill — its `scripts/add.sh` generates the spec and syncs the crontab. Direct spec authoring is supported but rarely needed.

Non-obvious bits:
- **Crontab edits inside the harness block don't stick.** `schedules/install.sh` rebuilds the delimited `# >>> harness schedules >>>` block on every run. Non-harness crontab entries pass through, but any edit inside the block via `crontab -e` gets wiped — change the `.cron` spec instead.
- **macOS Full Disk Access.** `crontab` needs FDA granted to the shell running the installer (System Settings → Privacy & Security → Full Disk Access → add Terminal/iTerm). Claude Code's own shell doesn't have FDA — run `./schedules/install.sh` from a terminal you've granted access to.
- **`state/` is gitignored.** The wrapper only updates the stamp on exit-0 runs, so failures retry on the next tick instead of silently falling behind a day.

## Editing harness content

When you fix friction and the right place to capture it is a skill, agent, or `AGENTS.md`, follow the **`updating-ai-knowledge`** skill — especially: do not change a skill's `name:` field (it aligns with symlink names and loaders), and prefer small, evidence-based edits.

**Keep `README.md` in sync** with new skills, agents, and major structural changes. The README is the canonical reference for harness layout.
