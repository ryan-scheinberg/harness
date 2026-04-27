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
./schedules/install.sh                 # optional: local cron jobs (writes crontab; needs `pip install croniter`)
```

Re-run each installer whenever you add, move, or rename anything in its directory. `CLAUDE.md` is a plain symlink, no re-install needed

## Starting a session

Bare `claude` enters the **root** role — the user's base session, where direct work happens and from which managers, a CEO, or the harness-engineer get spawned when needed. Add this to `~/.zshrc` (or `~/.zprofile`) so a no-arg invocation hits root and any flagged invocation passes through:

```bash
claude() {
  if (( $# == 0 )); then
    command claude '/role-root'
  else
    command claude "$@"
  fi
}
```

Role skills live under `skills/roles-skillset/role-<name>/`. Spawned sessions get their role applied via `/role-<name>` automatically by `claude-session-manager/scripts/spawn.sh`

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