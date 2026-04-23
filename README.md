# Harness

Source of truth for the Claude Code / Cursor harness: skills, subagents, the global `CLAUDE.md`, and safety hooks. `setup.sh` symlinks everything into the locations the tools expect. Safety hooks are installed separately via `hooks/install.sh` — they are intentionally opt-in and not part of `setup.sh`.

## Install

```bash
git clone <this-repo-url> ~/Documents/harness
cd ~/Documents/harness
./setup.sh           # skills, agents, CLAUDE.md, schedules
./hooks/install.sh   # safety hooks (opt-in, run once)
```

Re-run `./setup.sh` whenever you add, move, or rename anything under `skills/`, `agents/`, `schedules/`, or edit `CLAUDE.md`. Re-run `./hooks/install.sh` whenever you change anything under `hooks/`.

## Layout

| Path | What it is | Where it symlinks to |
| --- | --- | --- |
| `skills/` | SKILL.md directories grouped by skillset folder | `~/.claude/skills/<name>` and `~/.cursor/skills/<name>` (flat) |
| `agents/` | Subagent definition files (`.md`) | `~/.claude/agents/<name>.md` |
| `CLAUDE.md` | Global user instructions | `~/.claude/CLAUDE.md` |
| `hooks/` | Native deny rules + PreToolUse bash gate for destructive commands | Merged into `~/.claude/settings.json` via `hooks/install.sh` (run manually) |
| `schedules/` | Local cron jobs (one `.cron` spec per job) with catch-up wrapper | Merged into the user's crontab via `schedules/install.sh` |

## License

MIT
