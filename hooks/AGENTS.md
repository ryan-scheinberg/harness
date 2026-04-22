# Hooks repo — agent notes

This repo is the source of truth for safety hooks that gate Claude's tool calls in Cowork and Claude Code.

## Two install targets, one source

`setup-hooks` installs the same hook wiring in two places:

- **Cowork:** builds `dist/safety-hooks.plugin` (zipped plugin with `${CLAUDE_PLUGIN_ROOT}` paths). User drags the `.plugin` into Cowork chat and restarts.
- **Claude Code CLI:** merges `hooks.json` into `~/.claude/settings.json`, rewriting `${CLAUDE_PLUGIN_ROOT}` to this repo's absolute path. No auto-discovery from `~/.claude/plugins/` — Claude Code only auto-loads hooks from `settings.json` layers (user/project/local), so user-scope `settings.json` is the install surface. Merge is idempotent: blocks whose commands reference this repo's `scripts/` path are stripped before the fresh set is appended. Other tools' hook blocks are left untouched.

Skip either target with `--no-plugin` or `--no-claude-code`. `--dry-run` prints the planned changes.

## Core rules

1. **Fail-open is a load-bearing invariant.** If a hook script crashes or hits an unexpected error, it must exit 0 (allow the tool call) and log the crash. Never `raise` — always catch. The alternative is bricking Cowork, which is worse than a single missed gate.
2. **Patterns in one place.** All regexes live in `scripts/lib/patterns.py`. Do not inline patterns in gate scripts. When adding coverage, add a pattern there and a test line to the smoke tests.
3. **Defense in depth, not a bank vault.** A determined bad actor can always bypass a hook by editing the patterns file, renaming the plugin, etc. These hooks exist to catch *Claude's own* accidental destructive actions and to force a human-in-the-loop moment for high-blast-radius work. They are not a security boundary.
4. **No runtime state in the repo.** Logs go to `~/.claude-hooks/logs/`, approval tokens to `$TMPDIR/claude-hooks/approvals/`. The repo is read-only at runtime.

## Editing patterns

When adjusting `scripts/lib/patterns.py`:

- **HARD_BLOCK patterns** should be extremely narrow — they fire even with an approval marker. Only things that are destructive, irreversible, and never useful even with user consent in a session (system power commands, `rm -rf /`, force-push to protected branches).
- **APPROVAL_GATE patterns** should cover anything with real blast radius but a legitimate use case. When in doubt, gate — the friction is one round-trip.
- Test a new pattern by piping a synthetic PreToolUse payload into the gate and checking exit code + stderr (exit 2 = block, exit 0 = allow):

```bash
echo '{"tool_name":"Bash","tool_input":{"command":"brew install ripgrep"}}' \
  | python3 scripts/bash_gate.py ; echo "exit=$?"
# then re-run with "# claude-hook-approved: ..." appended to the command
# to confirm the marker path exits 0
```

## Adding a new MCP write gate

`scripts/mcp_write_gate.py` is generic — it gates any tool name by looking up an approval token keyed on `(tool_name, tool_input)`. To cover a new service, just add a matcher block to `hooks.json` under `PreToolUse`:

```json
{
  "matcher": "mcp__.*__(create_page|update_page|delete_page)",
  "hooks": [{"type":"command","command":"python3 ${CLAUDE_PLUGIN_ROOT}/scripts/mcp_write_gate.py"}]
}
```

No Python changes needed. If the tool takes an unusual input shape you want to surface nicely in the `REQUIRES APPROVAL` message, extend `_summary()` in `mcp_write_gate.py`.

## Approval-marker format

Bash approval marker:

```
# claude-hook-approved: <short reason>
```

The marker is a shell comment — it's legal in any bash command and is preserved in the audit log next to the command, which is the auditing we want.

MCP approval tokens are written by `scripts/approve.py` before the gated MCP call:

```
python3 ~/Documents/hooks/scripts/approve.py \
    --tool 'mcp__.*__create_draft' \
    --input '{"to": "alice@example.com", "subject": "hey"}' \
    --reason 'Ryan confirmed in chat'
```

The hook reads the token from `$TMPDIR/claude-hooks/approvals/<hash>.json` (flat directory, not per-tool). The hash is `sha256({"tool": <name>, "input": <tool_input>})[:24]` with sorted keys — any change to either field produces a miss, which is what makes the token bind to one specific call. The hook validates TTL, deletes the token (single-use), and allows the call.

## Rebuild flow

After any edit:

```bash
./setup-hooks                     # builds .plugin AND updates ~/.claude/settings.json
# For Cowork: drag dist/safety-hooks.plugin into chat; restart Cowork.
# For Claude Code: no restart — next session picks up the updated settings.
```

The plugin version is timestamp-suffixed so Cowork re-installs are always treated as updates. The Claude Code install is idempotent — re-runs replace our blocks in `~/.claude/settings.json` rather than duplicating.

Partial updates: `./setup-hooks --no-plugin` updates only Claude Code, `./setup-hooks --no-claude-code` updates only Cowork. `--dry-run` prints planned changes without writing.

**Rebuilding from inside a Cowork sandbox (not native Mac):** `setup-hooks` calls `/usr/bin/zip` with the output path inside `~/Documents/hooks/dist/`. The Cowork sandbox mounts `~/Documents` via FUSE, which blocks `unlink`/rename-over-existing on files it created. If a stale `dist/safety-hooks.plugin` is present, zip errors out with `Could not create output file (was replacing the original zip file)`. Workaround: stage the build in `/tmp` and `cp -f` over:

```bash
# from inside the sandbox when setup-hooks fails
rm -rf /tmp/safety-hooks-stage && mkdir -p /tmp/safety-hooks-stage/{.claude-plugin,hooks}
# ... build stage tree ... (see setup-hooks source for the layout)
(cd /tmp/safety-hooks-stage && zip -r -q /tmp/safety-hooks.plugin .)
cp -f /tmp/safety-hooks.plugin ~/Documents/hooks/dist/safety-hooks.plugin
```

On a native Mac shell this isn't an issue — the script works as-is. If this bites often, the right fix is to teach `setup-hooks` to always zip to a tempdir and `cp -f` into `dist/` rather than letting zip do in-place replacement.

## Knowledge upkeep

If you hit friction that looks like a missing hook or an over-broad pattern, either:

1. Edit `scripts/lib/patterns.py` directly and rebuild, **or**
2. If the friction looks cross-cutting (not specific to this repo), update the corresponding skill in `~/Documents/skills` via the `updating-ai-knowledge` skill workflow.
