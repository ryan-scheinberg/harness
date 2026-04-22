# Harness

Source of truth for the Claude Code / Cursor harness: skills, subagents, the global `CLAUDE.md`, and safety hooks. A single `setup.sh` symlinks everything into the locations the tools expect.

## Install

```bash
git clone <this-repo-url> ~/Documents/harness
cd ~/Documents/harness
./setup.sh
```

Re-run `./setup.sh` whenever you add, move, or rename anything under `skills/`, `agents/`, `hooks/`, `schedules/`, or edit `CLAUDE.md`.

## Layout

| Path | What it is | Where it symlinks to |
| --- | --- | --- |
| `skills/` | SKILL.md directories grouped by skillset folder | `~/.claude/skills/<name>` and `~/.cursor/skills/<name>` (flat) |
| `agents/` | Subagent definition files (`.md`) | `~/.claude/agents/<name>.md` |
| `CLAUDE.md` | Global user instructions | `~/.claude/CLAUDE.md` |
| `hooks/` | Native deny rules + PreToolUse bash gate for destructive commands | Merged into `~/.claude/settings.json` via `hooks/install.sh` |
| `schedules/` | Local cron jobs (one `.cron` spec per job) with catch-up wrapper | Merged into the user's crontab via `schedules/install.sh` |

## Safety

`setup.sh` treats `CLAUDE.md` and agent files cautiously: if a real file already exists at the destination, it diffs against the harness source and only replaces it when they are byte-identical. If they differ, setup.sh errors out with reconciliation instructions — the harness will never silently overwrite local edits.

## License

MIT
