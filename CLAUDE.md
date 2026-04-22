# Ryan's Operating Principles

**Vision**: Multi-agent company execution platform. All agents coordinate to ship. Ryan stays in control from phone. Built on infrastructure + AI harness experience (K8s, MCP, session dispatch, hook-driven tooling)

**Companies**: Agent Horizon LLC, Unicorn Hill Farm LLC

**North Star**: LTV/CAC. Unit economics over vanity metrics. Speed to revenue. Clean work driven to completion

**Skillscake**: Browser SaaS optimizing AI skills. Next.js + FastAPI Fargate, Stripe live. Launch mid-May (X, LinkedIn, HN, dev.to)Token-pack model (never-expiring)

**Multi-Agent Execution**
- Agents coordinate to ship fast
- Ryan always in the loop (decisions, pivots, launches)
- Breadcrumbs: Use `/updating-ai-knowledge` to update CLAUDE.md, AGENTS.md, skills when you learn something the next agent needs
- Assume other agents will read and extend your work

**SDLC & Testing**
- Everything is a skill (code, deploy, test, validate)
- Execute end-to-end: run tests via API, validate output, verify state
- Checkpoints: Ryan decides when work needs approval (launches, infrastructure changes, compliance)
- No half-finished implementations. Test before claiming done
- Autonomous execution is the default; checkpoints are the exception

**Code Readability**
- Next agent must understand in 30 seconds
- No premature abstraction; three lines before DRY
- WHY comments only (not WHAT)
- Bulletproof > clever. Clean > optimized

**Communication**
- Direct, pessimistic OK, pushback on vague reasoning
- Imprecision is a blocker
- Constraints matter: employment, compliance, unit economics

**Harness Architecture**
- Personal agent OS at `~/Documents/harness/` (git-tracked source of truth): `skills/`, `agents/`, `hooks/`, `triggers/`, `CLAUDE.md`, `setup.sh`
- `setup.sh` symlinks everything into the loaders Claude Code and Cursor read from (`~/.claude/skills/`, `~/.cursor/skills/`, `~/.claude/agents/`, `~/.claude/CLAUDE.md`) and installs safety hooks via `hooks/install.sh`
- Skills are shared between Claude Code and Cursor (cursor-delegate uses them)
- This file lives inside the harness — edits belong in `~/Documents/harness/CLAUDE.md`, not the `~/.claude/` symlink

**Pinging Ryan**
- Call `PushNotification` before ending your turn when: (a) you're blocked on his input, or (b) a substantial task just finished and he may have walked away. Turn-end does NOT auto-ping — if you don't call it, he hears nothing
- If `PushNotification` returns "Not sent", sleep 90s in background and retry. Repeat until it lands. Only retry when you're blocked. For "done" pings, fire once
- In --remote-control sessions, *always* fire `PushNotification` in the same response as any `AskUserQuestion` call. Do the same for other calls that will end your turn based on the rules above

**Research Approach**
- Read codebases (`setup.sh`, `AGENTS.md`) before asking questions
- Many design answers live in script implementations and guidance files, not in chat context
- Codebase truth > assumptions; if unsure, grep and read
