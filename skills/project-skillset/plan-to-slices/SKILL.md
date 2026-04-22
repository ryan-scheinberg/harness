---
name: plan-to-slices
description: Decompose a PROJECT_BRIEF.md into vertical, TDD-ready implementation slices. Each slice is independently demoable. Use when user wants to break down a project into slices.
---

# Plan to Slices

Read `PROJECT_BRIEF.md` and produce `SLICES.md` — an ordered sequence of vertical, TDD-ready implementation slices as `##` sections in that single document.

Always require a `PROJECT_BRIEF.md`. If one doesn't exist, tell the user to run `define-project` first.

## Why vertical slices

Horizontal slicing (build the DB layer, then the API, then the UI) delays feedback and creates integration risk. A vertical slice cuts through every layer needed to deliver one observable outcome. You can demo it, test it end-to-end, and ship it. Each slice proves something works before you move on.

## Why TDD-ready

A slice isn't ready to build until you can state acceptance criteria you could verify. If you can't describe observable outcomes, the slice is too vague. The criteria define what "done" means and force precision about inputs, outputs, and behavior — the implementer turns them into tests and code.

## Process

1. Read `PROJECT_BRIEF.md`. Understand scope, technical approach, MVP definition, and risks.
2. If there's a codebase, explore it — understand module boundaries, existing test patterns, what's already there. This shapes where slices land.
3. Identify the vertical slices (see slicing rules below).
4. Order slices by dependency and risk — build confidence early.
5. For each slice, define acceptance criteria — observable, verifiable outcomes.

## Slicing Rules

- **Every slice is vertical** — it touches whatever layers are needed (data, logic, API, UI, infra) to deliver one demoable outcome. No "set up the database" slices unless the project is pure infra.
- **Slice 1 is the MVP slice** — the thinnest end-to-end path from the brief's scope section. This slice proves the core approach works. It should be surprisingly thin.
- **Each subsequent slice adds one dimension** — more depth (handle edge cases), more breadth (another entity/flow), or hardening (error handling, performance, security).
- **Greenfield projects**: the first slice is project scaffolding + the MVP path. Include repo setup, test runner config, and CI in this slice — they're part of proving the approach, not a separate phase.
- **O11y is woven in, not bolted on** — structured logging, key metrics, and health checks belong inside slices, not in a dedicated "add observability" slice at the end.
- **Deployment is a slice when warranted** — pipeline config, environment setup, rollback plan. If the brief mentions deployment, it's a first-class slice.
- **Each slice should take roughly the same effort** — if one slice is 10x bigger than the others, break it down further.

## Acceptance Criteria, Not Tests

The slicer defines *what* each slice must achieve — observable, testable outcomes. The implementer decides *how* to test and build it (typically via TDD with red-green-refactor cycles). Keep acceptance criteria concrete enough that an implementer can start coding without asking clarifying questions.

Keeping slices focused matters for AI context too — each slice should be completable in a single agent command without losing track of what's been built and what's left. Our agents' ability to complete tdd code is strong. Don't underestimate and make tiny slices, but you can help agents by creating these useful vertical slices.

### What good acceptance criteria look like

- Observable and verifiable — "endpoint returns 201 with user ID", not "user creation works"
- Scoped to this slice — don't repeat criteria from other slices
- Cover the important behaviors: happy path (always), input validation (when introducing interfaces), edge cases (when core to the slice), integration with prior slices (from slice 2 onward)

3-5 criteria per slice is typical. The goal is to define the boundary of "done" — the implementer will discover additional edge cases and tests during development.

## Output Format — SLICES.md

```markdown
# [Project Name] — Implementation Slices

> Generated from [PROJECT_BRIEF.md](./PROJECT_BRIEF.md)

## Slice 1: [Verb] [what] *(MVP)*

### What this delivers
One sentence: what a user/system can do after this slice ships.

### Acceptance criteria
1. [Observable, testable outcome — e.g. "POST /users returns 201 with user ID"]
2. [Another criterion]
3. ...

### Implementation notes
Key decisions, constraints, or patterns from the brief that apply here. What layers this touches.

### Done when
- [ ] All acceptance criteria met
- [ ] [Observable outcome — can demo X / can hit endpoint Y / logs show Z]

---

## Slice 2: [Verb] [what]

### What this delivers
...

### Acceptance criteria
...

### Implementation notes
- **Depends on**: Slice 1
- ...

### Done when
...

---

(repeat for each slice)
```

## Ordering Principles

1. **MVP first** — always. Prove the approach before expanding.
2. **Dependencies before dependents** — a slice that introduces an API comes before the slice that consumes it.
3. **Risk early** — if a slice involves an uncertain technology or integration, push it forward. Learn if it works before building on top of it.
4. **User-facing before internal polish** — deliver visible value, then harden.

## Quality Bar

- Output is exactly one `SLICES.md` — no scattered slice files unless the user overrides
- Every slice is vertical — no "build the data layer" or "set up auth middleware" slices that aren't independently demoable
- Acceptance criteria are concrete and verifiable — an implementer can start building without asking clarifying questions
- Slice 1 is genuinely thin — if it takes more than a day or two, it's too thick
- Dependencies between slices are explicit
- The slice plan is shorter and more actionable than the brief it came from
- A developer reading SLICES.md knows exactly what to build first, what "done" looks like, and what order to go in
