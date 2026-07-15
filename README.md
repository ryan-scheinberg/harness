# Harness

Claude Code + Codex agent OS: skills, separate global instructions, safety hooks, and local schedules. Each top-level dir has its own `install.sh`. Nothing is bundled, every installer is opt-in, and installers unconditionally overwrite their destinations

## Install

```bash
git clone https://github.com/ryan-scheinberg/harness.git ~/Documents/harness
cd ~/Documents/harness

./skills/install.sh                    # symlinks into ~/.claude/skills
ln -sf "$PWD/CLAUDE.md" ~/.claude/CLAUDE.md   # one-time: global user instructions

./codex/install.sh                     # optional: Codex adapter (writes ~/.codex/skills and ~/.codex/AGENTS.md)
./codex-agents/install.sh              # optional: native Codex agents (writes ~/.codex/agents)
./hooks/install.sh                     # optional: safety hooks (writes ~/.claude/settings.json)
./schedules/install.sh                 # optional: local cron jobs (writes crontab; needs `pip install croniter`)
```

Re-run each installer whenever you add, move, or rename anything in its directory. `CLAUDE.md` is a plain symlink, no re-install needed

## Starting a session

Bare `claude` enters the **root** role — the user's base session, where direct work happens and from which `build`/`verify`/`qa`/`deploy`/`harness-engineer` workers get spawned to orchestrate larger work. Add this to `~/.zshrc` (or `~/.zprofile`) so a no-arg invocation hits root and any flagged invocation passes through:

```bash
claude() {
  if (( $# == 0 )); then
    command claude '/role-root'
  else
    command claude "$@"
  fi
}
```

Role skills live under `skills/roles-skillset/role-<name>/`. A subagent gets its role by opening its prompt with `/role-<name>`

## Codex adapter

Codex invokes skills with `$skill-name`, not Claude slash commands. `./codex/install.sh` installs shared skills into `~/.codex/skills`. The Codex sources for `role-root`, `role-build`, and `role-verify` live in `codex/roles/` because they contain platform-specific execution behavior; every other role keeps its shared source and only rewrites `/role-` to `$role-` on install

The Codex adapter keeps its global instructions separate from Claude. It symlinks `~/.codex/AGENTS.md` to the ignored personal `codex/AGENTS.md`; create that local file before installing the adapter. It never reads or rewrites `CLAUDE.md`

`./codex-agents/install.sh` installs the thin native `luna_builder` agent into `~/.codex/agents/`, which Codex discovers directly. Root selects the role with `agent_type`; `task_name` is only the spawn handle. Its TOML pins the builder model and effort while the delegated prompt begins `$role-build`; Fable QA is a single blocking `claude -p --model fable --effort xhigh` call owned by `role-root`, so there is no reverse bridge plugin to install or maintain

```bash
codex() {
  if (( $# == 0 )); then
    command codex '$role-root'
  else
    command codex "$@"
  fi
}
```

## Layout


| Path         | What it is                                      | Installed by           | Where it goes                                                  |
| ------------ | ----------------------------------------------- | ---------------------- | -------------------------------------------------------------- |
| `skills/`    | SKILL.md directories grouped by skillset folder | `skills/install.sh`    | `~/.claude/skills/<name>` (flat)                                      |
| `codex/`     | Codex adapter installer                         | `codex/install.sh`     | `~/.codex/skills/<name>`                                             |
| `codex-agents/` | Native Codex custom agents                  | `codex-agents/install.sh` | `~/.codex/agents/<name>.toml`                                     |
| `codex/AGENTS.md` | Ignored personal Codex global instructions | `codex/install.sh` | `~/.codex/AGENTS.md` |
| `CLAUDE.md`  | Global user instructions                        | manual `ln -s`         | `~/.claude/CLAUDE.md`                                                |
| `hooks/`     | Native deny rules + PreToolUse bash gate + codex timeout | `hooks/install.sh`     | Merged into `~/.claude/settings.json`                                |
| `schedules/` | Local cron jobs with catch-up wrapper           | `schedules/install.sh` | Merged into the user's crontab                                       |


## License

MIT
