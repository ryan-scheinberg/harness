# Hooks

Safety hooks for Claude running in Cowork / Claude Code. This repo is the **source of truth**; `setup-hooks` packages it into a `.plugin` file Cowork can install.


## What it does

Three guardrails on every tool call Claude makes:

1. **Hard-block** — destructive commands that will never run, no override. Examples: `rm -rf /`, `sudo rm`, `curl | sh`, force-push to a protected branch, disk format commands, system-level kills.
2. **Approval-gate** — commands allowed only when accompanied by an explicit approval marker. Examples: package installs (`brew`, `npm -g`, `pip`), `rm -rf` outside scratch dirs, `git reset --hard`, AWS write operations, secrets access, production deploys, MCP writes (email send, GitLab issue create, Slack post, Typefully publish).
3. **Audit log** — every tool call and hook decision is appended to `~/.claude-hooks/logs/<date>.log` so you can audit what Claude tried, got blocked on, or got approved to do.

When a gated command is blocked, the hook emits a clear `REQUIRES APPROVAL: …` line explaining what Claude wanted to do and why. Claude then asks you in chat, you reply "ok" / "no" / redirect, and for the next call Claude includes the approval marker.

## Approval markers

**Bash commands:** include a comment anywhere in the command of the form:

```bash
# claude-hook-approved: <short reason you approved it>
brew install ripgrep
```

The comment is shell-legal (bash ignores it) and auditable (it shows up in the log next to the command).

**MCP tool calls** (Gmail, GitLab, Slack, Typefully, etc.): approval tokens are written to `$TMPDIR/claude-hooks/approvals/` by `scripts/approve.py` before the call. Each token is single-use and scoped to one tool + one input hash, so a stale approval can't leak to an unrelated call.

## Install

```bash
git clone <this-repo-url> ~/Documents/hooks   # or start from this local copy
cd ~/Documents/hooks
./setup-hooks
```

`setup-hooks` has two install targets and runs both by default:

- **Cowork** — produces `dist/safety-hooks.plugin`. Drag that file into a Cowork chat, accept the install card, then restart Cowork so it picks up the new plugin. Verify install with `ls ~/Library/Application Support/Claude/*/rpm/` — you should see a `safety-hooks` entry in its `manifest.json`.
- **Claude Code CLI** — merges the hook wiring into `~/.claude/settings.json` with absolute paths pointing at this repo's `scripts/` directory. Claude Code doesn't auto-discover plugins from `~/.claude/plugins/`, but it does read hooks from the user-scope `settings.json` and merges them across layers. No restart needed — hooks load on the next Claude Code session.

Re-run `./setup-hooks` after editing patterns or scripts. Cowork treats a new `.plugin` version as an update; the Claude Code install is idempotent (prior blocks keyed on this repo's `scripts/` path are stripped before the fresh ones are appended, so re-runs don't duplicate).

Skip either target with `--no-plugin` or `--no-claude-code`. Use `--dry-run` to see what would change without touching disk.

## Logs

Decision log: `~/.claude-hooks/logs/YYYY-MM-DD.log`. One JSON line per event — `{ts, event, tool, decision, reason, command_or_summary}`. Tail it live during a session to watch what Claude is up to.

## Layout

- `scripts/bash_gate.py` — PreToolUse hook for the Bash tool.
- `scripts/mcp_write_gate.py` — PreToolUse hook for MCP write-shaped tools (matchers wired in `hooks.json`).
- `scripts/post_log.py` — PostToolUse hook; audit logger.
- `scripts/approve.py` — CLI helper Claude uses to pre-record an MCP approval after you say OK in chat.
- `scripts/lib/patterns.py` — the regex pattern lists. This is where you tune coverage.
- `scripts/lib/approvals.py` — approval-token file handling.
- `scripts/lib/logger.py` — decision log helpers.
- `hooks.json` — PreToolUse / PostToolUse wiring. Referenced by the Cowork plugin manifest verbatim, and merged into `~/.claude/settings.json` with `${CLAUDE_PLUGIN_ROOT}` rewritten to this repo's absolute path for Claude Code.
- `setup-hooks` — build + install script. Produces `dist/safety-hooks.plugin` and installs Claude Code hooks into `~/.claude/settings.json`.

## Design notes

- **Fail-open on exception.** A crashing hook script returns exit 0 (allow) rather than exit 2 (block). This prevents a buggy pattern from locking you out of Cowork. The crash itself is still logged.
- **No network calls from hook scripts.** Determinism and speed matter more than cleverness here.
- **Patterns live in one file** (`scripts/lib/patterns.py`) so tuning coverage is a single-file edit.

## License

MIT
