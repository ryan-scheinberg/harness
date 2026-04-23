# Harness

Claude Code / Cursor agent OS: skills, subagents, the global `CLAUDE.md`, safety hooks, and local schedules. Each top-level dir has its own `install.sh`. Nothing is bundled, every installer is opt-in, and installers unconditionally overwrite their destinations

## Install

```bash
git clone https://github.com/ryan-scheinberg/harness.git ~/Documents/harness
cd ~/Documents/harness

./skills/install.sh                    # symlinks into ~/.claude/skills and ~/.cursor/skills
./agents/install.sh                    # symlinks into ~/.claude/agents
ln -sf "$PWD/CLAUDE.md" ~/.claude/CLAUDE.md   # one-time: global user instructions

./hooks/install.sh                     # optional: safety hooks (writes ~/.claude/settings.json)
./schedules/install.sh                 # optional: local cron jobs (writes crontab)
```

Re-run each installer whenever you add, move, or rename anything in its directory. `CLAUDE.md` is a plain symlink, no re-install needed

## Layout


| Path         | What it is                                      | Installed by           | Where it goes                                                  |
| ------------ | ----------------------------------------------- | ---------------------- | -------------------------------------------------------------- |
| `skills/`    | SKILL.md directories grouped by skillset folder | `skills/install.sh`    | `~/.claude/skills/<name>` and `~/.cursor/skills/<name>` (flat) |
| `agents/`    | Subagent definition files (`.md`)               | `agents/install.sh`    | `~/.claude/agents/<name>.md`                                   |
| `CLAUDE.md`  | Global user instructions                        | manual `ln -s`         | `~/.claude/CLAUDE.md`                                          |
| `hooks/`     | Native deny rules + PreToolUse bash gate        | `hooks/install.sh`     | Merged into `~/.claude/settings.json`                          |
| `schedules/` | Local cron jobs with catch-up wrapper           | `schedules/install.sh` | Merged into the user's crontab                                 |


## License

MIT