---
name: updating-ai-knowledge
description: Guidance for updating agent-facing files (skills, AGENTS.md, subagent definitions) when you discover they are wrong, incomplete, or stale. Use when you've solved a problem that revealed a gap, or when the user says to update a skill, AGENTS.md, or agent. The trigger is friction; you learned something the knowledge base should have told you
---

## The friction

You hit something the knowledge base should have warned you about. Before editing anything, articulate the gap in one sentence: *"This file says X, but the correct behavior is Y."* If you can't say that yet, you don't have the fix yet. Synthesize from what the session already produced

## Where it belongs

- **Skill** (`~/Documents/harness/skills/`) → cross-repo knowledge about tools, platforms, workflows. Test: *"Would this be true in another repo?"* Group by skillset folder (`project-skillset/`, `harness-skillset/`, `skillscake-skillset/`). Run `./skills/install.sh` from the harness repo root to refresh symlinks after adding or moving a skill directory.
- **Global CLAUDE.md** (`~/Documents/harness/CLAUDE.md`, symlinked to `~/.claude/CLAUDE.md`) → user-scope operating principles that every main-session Claude inherits. Distinct from `AGENTS.md` (per-repo) and subagent bodies (per-agent); note subagents do **not** inherit this file
- **AGENTS.md** (at the affected repo root) → repo-specific context. Nearest file wins; most agents read it automatically
- **Agent** (`~/Documents/harness/agents/<name>.md`, symlinked to `~/.claude/agents/`) → fixes to a subagent's behavior (fires at the wrong time, wrong output format, missing domain coverage). You're editing *how the subagent thinks*, not facts it looks up

Files in `~/Documents/harness` are maintained by the harness-engineer role. Instead of updating, consider reporting in your project's retro.

## Making the edit

**Read the whole file first** (skill body, global `CLAUDE.md`, `AGENTS.md`, or agent). Then make the smallest edit that closes the gap. Preserve everything accurate. Restructure only if the structure itself caused the confusion

**Write with reasoning, not just rules.** *"Use `--runInBand` because tests share a database and parallel runs corrupt each other"* is durable. *"Always use `--runInBand`"* is fragile: it breaks the moment the flag name changes or someone needs to know why. Reasoning survives cases your example doesn't cover

If you reach for all-caps emphasis or absolute prohibitions, pause and ask whether explaining the consequence would be clearer

**Drop trailing periods.** End-of-line periods (bullets, paragraph endings) waste tokens for no readability gain. Keep internal punctuation that separates sentences mid-line

## Constraints

- **Skill `name:`** — don't change; tied to symlinks and the loader
- **Skill `description:`** — edit only if triggering is wrong (fires when it shouldn't, or doesn't fire when it should)
- **Agent `description:`** — LLM-only routing signal (not shown to users). Keep it short and trigger-phrased ("Use when X", "Proactively Y"). Edit it when the agent fires wrong
- **Agent body** — the agent's system prompt. Keep it tight (~30–40 lines)
- **Agent user-interaction** — subagents should not call `AskUserQuestion` or `PushNotification` directly; they return a single message to the parent, which is responsible for any user-facing pause or ping. Add both to `disallowedTools:` to enforce the contract structurally
- **Agent CLAUDE.md context** — subagents do not inherit global `~/.claude/CLAUDE.md` or project `CLAUDE.md`; their system prompt is only the agent body plus runtime injections. If an agent needs that context, duplicate the relevant rules into the body

## Example calls

- Jira skill has a wrong field name → skill
- Repo needs `npm ci` before tests but `AGENTS.md` doesn't say so → AGENTS.md
- A new cross-session operating rule you want every main Claude to follow → global `CLAUDE.md`
- `verify` agent misses a domain (never probes migrations) → agent (extend the domain playbook)
- `verify` description so broad it fires on trivial tasks → agent (tighten `description:`)
- Terraform module changed its variable interface → skill
- Build kept failing because of an undocumented env var → AGENTS.md
