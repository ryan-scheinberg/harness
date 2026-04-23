# Harness repo — agent notes

This repository is the **source of truth** for the user's Claude Code / Cursor harness. It bundles skills, subagents, hooks, and the global `CLAUDE.md` under one installer so the harness is reproducible and version-controlled in one place.

## Install / refresh

From the repo root (`setup.sh` is a Bash 3.2-compatible script so it runs on macOS's default shell):

```bash
./setup.sh
```

This:

- Discovers every `SKILL.md` under `skills/` (at any depth, skipping `.git/`) and creates **flat** symlinks under `~/.claude/skills/<name>/` and `~/.cursor/skills/<name>/`.
- Symlinks every `.md` under `agents/` into `~/.claude/agents/<name>.md`.
- Symlinks `CLAUDE.md` into `~/.claude/CLAUDE.md`.
- Runs `schedules/install.sh` to sync `schedules/*.cron` specs into the user's crontab under a delimited block.

Safety hooks are **not** part of `setup.sh` — they are installed separately by running `./hooks/install.sh` manually by the user. This keeps hook installation opt-in and independent of routine setup re-runs.

Stale symlinks pointing into `$REPO_ROOT` or legacy `~/Documents/skills/` are pruned before re-linking.

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
- **macOS Full Disk Access.** `crontab` needs FDA granted to the shell running the installer (System Settings → Privacy & Security → Full Disk Access → add Terminal/iTerm). Claude Code's own shell doesn't have FDA; `setup.sh` warns and continues if the schedules installer fails, so the user has to run `./setup.sh` from a terminal they've granted access to.
- **`state/` is gitignored.** The wrapper only updates the stamp on exit-0 runs, so failures retry on the next tick instead of silently falling behind a day.

## Editing harness content

When you fix friction and the right place to capture it is a skill, agent, or `AGENTS.md`, follow the **`updating-ai-knowledge`** skill — especially: do not change a skill's `name:` field (it aligns with symlink names and loaders), and prefer small, evidence-based edits.

**Keep `README.md` in sync** with new skills, agents, and major structural changes. The README is the canonical reference for harness layout.
