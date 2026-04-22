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
- Runs `hooks/setup-hooks` to merge safety hooks into `~/.claude/settings.json`.

Stale symlinks pointing into `$REPO_ROOT` or legacy `~/Documents/skills/` are pruned before re-linking.

## Adoption safety

For `CLAUDE.md` and agent `.md` files that already exist as real files at the destination, `setup.sh` diffs against the harness copy. It only removes + symlinks when the content is identical; if it differs, setup aborts with reconciliation instructions. Skills are symlinked directly (no adoption check) because the harness is assumed to be the source of truth for skill directory content.

## Constraints

- Two skill folders with the same basename anywhere under `skills/` will fail the script — names must be unique across the whole tree (loaders flatten by basename).
- Agent file basenames must be unique under `agents/`.

## Editing harness content

When you fix friction and the right place to capture it is a skill, agent, or `AGENTS.md`, follow the **`updating-ai-knowledge`** skill — especially: do not change a skill's `name:` field (it aligns with symlink names and loaders), and prefer small, evidence-based edits.

**Keep `README.md` in sync** with new skills, agents, and major structural changes. The README is the canonical reference for harness layout.
