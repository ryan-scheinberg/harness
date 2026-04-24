---
name: define-project
description: Take a brief idea and produce a complete PROJECT_BRIEF.md as if the user wrote it on their best day. Covers features, fixes, infra, and full products alike. Use when user wants to define a project, scope a feature, plan a complex fix, or mentions "project brief" or "new project"
---

Produce a `PROJECT_BRIEF.md` proficient agents can pick up and build from without clarifying questions. Terse, opinionated, decisions made not deferred. The user's persona and preferences already live in `CLAUDE.md` — don't restate them

## Process

1. **Read the user's input.** Infer what you can as an architect. `iterate-plan` closes the rest after the first draft
2. **Explore the codebase if one exists** starting with `AGENTS.md` files. Tech stack, test setup, CI, module boundaries, naming conventions. Don't ask what code can answer
3. **Decide.** Pick the stack and scope the MVP — the thinnest end-to-end vertical path that proves the approach. Genuine uncertainty goes in Risks & Open Questions. Default to deciding. Hedged briefs ship ambiguity forward into dev turns. Don't name downstream slices here — that's `plan-to-slices`' job, and pre-slicing the brief locks in a shape before the MVP has taught you anything
4. **Write the brief** using the template. Adapt freely — drop sections that don't apply, add sections when the project needs them. A bug fix doesn't need a business model; a SaaS needs all of it

## Template

<brief-template>

# [Project Name]

## Context
What this is, why it exists, the problem it solves. No throat-clearing

## Audience
Who uses or benefits. For internal or infra work this may be "the deployment pipeline" or "future contributors to this repo"

## Scope

### The MVP Slice
One sentence: "A user/system can [do X] and [see/get Y]"

### In Scope
- ...

### Out of Scope
- What's excluded and why

## Technical Approach
Stack, architecture, data, auth, infra with rationale. For existing codebases: what changes, what doesn't

## Testing & Observability
What gets tested and instrumented. Structured logging, key metrics, health checks. What tells you this is working or broken in prod

## Deployment & Rollout
Environments, rollout strategy, flags, rollback. Skip for non-deployable work

## Risks & Open Questions
What's uncertain. Each item notes what would close it

</brief-template>

## Quality bar

- Every section is specific. If you can only fill it with boilerplate, drop it
- Decisions are committed or flagged, never hedged