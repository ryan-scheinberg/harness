---
name: define-project
description: Take a brief idea and produce a complete PROJECT_BRIEF.md as if the user wrote it on their best day. Covers features, fixes, infra, and full products alike. Use when user wants to define a project, scope a feature, plan a complex fix, or mentions "project brief" or "new project".
---

# Define Project

Produce a complete `PROJECT_BRIEF.md`.

If there's an existing codebase, explore it to fill in context the user didn't provide.

## Who's Building This

Ryan Scheinberg. Infrastructure engineer and entrepreneur. Thinks in pipelines, IaC, TDD, vertical slices, o11y. Building businesses top-to-bottom with agents — AI is infrastructure, not a novelty. Solo + agents is the team. Jira for tracking. Opinionated about code standards, testing, and shipping small increments. Write the brief the way he would: terse, opinionated, no fluff, decisions made not deferred.

## What This Skill Handles

Anything that needs definition before building:

- A new SaaS product
- A complex feature in an existing codebase
- A refactor with migration concerns
- An infra change (new pipeline, new environment, IaC module)
- A bug fix complex enough to need a plan
- A spike or research task

The template adapts. A bug fix doesn't need a business model section. A SaaS needs all of it. Use judgment — include what's relevant, skip what isn't.

## Process

1. Read the user's input carefully. It might be vague — that's fine. Infer what you can.
2. If there's an existing codebase, explore it. Understand the current state, existing patterns, tech stack, test setup, CI config. Don't ask — look.
3. Make decisions. Pick the stack, scope the MVP, identify the vertical slices. Be opinionated. If a decision is genuinely uncertain, put it in Open Questions — but default to deciding.
4. Write `PROJECT_BRIEF.md` using the template below. Adapt the template to fit the project type. Write it in Ryan's voice — terse, direct, structured, no filler.

## Template

Use this structure. Drop sections that don't apply. Add sections if the project needs them. Modify to your heart's content. Consider deeply every line of the plan, but also commit.

<brief-template>

# [Project Name]

## Context

What this is, why it exists, what problem it solves. For features/fixes: what's broken or missing and why it matters. For products: the business case in plain language. No throat-clearing — get to the point.

## Audience

Who uses this or who benefits. Be specific. For internal/infra work, the audience might be "the deployment pipeline" or "future contributors to this repo."

## Scope

### The MVP Slice

The thinnest end-to-end path that proves this works. One sentence: "A user/system can [do X] and [see/get Y]."

### In Scope

- What's included in this effort

### Out of Scope

- What's explicitly excluded and why

## Technical Approach

How this gets built. Stack choices with rationale. Architecture decisions. For existing codebases: what changes, what doesn't, what's the blast radius.

Include data, auth, and infra decisions where relevant. Skip what doesn't apply.

## Testing & Observability

What gets tested and instrumented. Structured logging, key metrics, health checks. Even for small features — what would tell you this is working or broken in production?

## Deployment & Rollout

How this gets to production. Environments, rollout strategy, feature flags, rollback plan. What does a successful deploy look like? What would trigger a rollback? Skip for non-deployable work.

## Risks & Open Questions

What's uncertain. Each item should note what would close it. Be opinionated. Consider what risks apply to different vertical slices of the project. Consider the entire decision tree, but make your choices based on everything you've learned here.

</brief-template>

## Quality Bar

- Reads like Ryan wrote it, not like a template was filled in
- Proficient agents could pick it up and start building without asking clarifying questions
- Decisions are made, not hedged — except explicit open questions
- Scope is a vertical slice, not a feature list
- SRE best practices are present regardless of project size
- No section is boilerplate — if you can't write something specific, drop the section
