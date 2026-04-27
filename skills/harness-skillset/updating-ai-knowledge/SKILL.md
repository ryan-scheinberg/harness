---
name: updating-ai-knowledge
description: Guidance for updating agent-facing files (skills, AGENTS.md, subagent definitions) when you discover they are wrong, incomplete, or stale. Use when you've solved a problem that revealed a gap, or when the user says to update a skill, AGENTS.md, or agent. The trigger is friction; you learned something the knowledge base should have told you
---

## Is this worth updating?

Not every lesson belongs in a file. Before editing, pass these gates:

1. **Name the gap in one sentence.** *"This file says X, but the correct behavior is Y."* If you can't say that, you don't have the fix yet — synthesize from what the session produced
2. **Would the next agent hit the same wall?** If the problem was a one-off misread, a transient environment issue, or a one-time deploy workaround, the knowledge base isn't the problem
3. **Is the gap already covered somewhere?** Search the target file first. Duplicating a rule in a second location creates two things to maintain and eventually contradicts

Stop if any gate fails. Not every session produces a knowledge update, and that's fine

## Route to the right file

Work through these tests in order. The first match wins

### Skill (`~/Documents/harness/skills/`)

**Test**: Would this fact be true in a different repo using the same tool or platform? If you swapped the repo but kept the tool, would the lesson still apply?

Cross-repo knowledge about tools, platforms, workflows. Group by skillset folder (`project-skillset/`, `harness-skillset/`, `skillscake-skillset/`). Run `./skills/install.sh` from the harness repo root after adding or moving a skill directory

**Guardrails**: Don't change `name:` — tied to symlinks and the loader. Edit `description:` only if triggering is wrong (fires when it shouldn't, or doesn't fire when it should)

*Examples: Jira skill has a wrong field name. Terraform module changed its variable interface*

### AGENTS.md (at the affected repo root)

**Test**: Is this fact specific to one repo's codebase, build, or local environment? Would it be meaningless or wrong if you pasted it into a different project?

Repo-specific context. Nearest file wins in nested structures; most agents read it automatically

*Examples: Repo needs `npm ci` before tests. Build kept failing because of an undocumented env var*

### Global CLAUDE.md (`~/Documents/harness/CLAUDE.md`, symlinked to `~/.claude/CLAUDE.md`)

**Test**: Is this a user-scope operating principle every main-session Claude should follow, regardless of repo? Would it feel wrong scoped to just one project?

Distinct from AGENTS.md (per-repo) and subagent bodies (per-agent). Subagents do **not** inherit this file — if an agent needs a rule from here, duplicate it into that agent's body

*Examples: A new cross-session operating rule. A change to collaboration style*

### Agent (`~/Documents/harness/agents/<name>.md`, symlinked to `~/.claude/agents/`)

**Test**: Is the problem in how a specific subagent thinks — wrong triggers, wrong output format, missing domain coverage? If you fixed the facts it reads (skills, AGENTS.md), would it still get this wrong?

You're editing the subagent's system prompt, not facts it looks up

**Guardrails**:
- `description:` is an LLM-only routing signal (not shown to users). Keep it short and trigger-phrased ("Use when X", "Proactively Y"). Edit only when the agent fires wrong
- Keep bodies tight (~30–40 lines)
- Subagents must not call `AskUserQuestion` or `PushNotification` — they return a single message to the parent. Add both to `disallowedTools:` to enforce structurally
- Subagents do not inherit global or project `CLAUDE.md`. Their system prompt is only the agent body plus runtime injections

*Examples: `verify` agent misses a domain (never probes migrations). `verify` description so broad it fires on trivial tasks*

## Self-serve vs defer

Files in `~/Documents/harness` are maintained by the harness-engineer role. **Self-serve** when the fix is surgical and you're confident in it (wrong field name, missing build step, stale path). **Defer** by noting it in your project's retro when the change is structural (new skill, reorganizing agent responsibilities, changing operating principles) — those benefit from deliberate design rather than mid-task edits

## Making the edit

**Match the edit to the gap's size.** Read the whole file first, then make the smallest change that closes the gap. A missing flag gets one line. A wrong procedure gets its section rewritten. A structural problem (the file's organization itself caused confusion) justifies restructuring — but only that section, not the whole file. Preserve everything that's accurate

**Write reasoning, not just rules.** Knowledge rots when it encodes *how* instead of *why*. Command flags change, tool versions shift, APIs evolve — but the constraints that motivated a decision are stable. *"Use `--runInBand` because tests share a database and parallel runs corrupt each other"* survives flag renames and tells the next reader when the rule no longer applies. *"Always use `--runInBand`"* does neither. Reasoning lets agents generalize to cases you didn't write down

**Don't duplicate what's in code.** If a config file, type definition, or error message captures the truth, point to it — code stays current, prose won't

If you reach for all-caps emphasis or absolute prohibitions, ask whether explaining the consequence would be clearer

**Drop trailing periods.** End-of-line periods waste tokens. Keep internal punctuation that separates sentences mid-line
