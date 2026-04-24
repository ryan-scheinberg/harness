---
name: plan-to-slices
description: Decompose a PROJECT_BRIEF.md into vertical, TDD-ready implementation slices. Each slice is independently demoable. Use when user wants to break down a project into slices
---

Read `PROJECT_BRIEF.md` and produce `SLICES.md` — an ordered sequence of vertical, demoable slices, each with acceptance criteria a dev can turn into tests

If there's no brief, tell the user to run `define-project` first. Slicing without a brief just ships the ambiguity forward into dev turns

## Process

1. **Read the brief.** Scope, MVP, technical approach, risks
2. **Explore the codebase** if one exists. Module boundaries, test patterns, what's already there. Slices land where seams already exist
3. **Identify vertical slices.** Slice 1 is the thinnest end-to-end path that proves the core approach
4. **Order by dependency and risk.** Uncertain integrations push forward so you learn early. User-facing value before internal polish. Clearly label dependencies so the manager can parallelize
5. **Write acceptance criteria** — 3–5 observable outcomes per slice

## Slicing rules

- Every slice is vertical. No "set up the database" slice unless the project is pure infra. A horizontal slice can't be demoed, so you lose the feedback that makes slicing valuable
- O11y lives inside the slice that introduces the behavior
- Sizes within an order of magnitude. If one slice is 10x the others, split it; if one is 1/10th, fold it in. Agents complete well-sized vertical slices strongly — don't over-fragment out of caution

## Acceptance criteria

Observable and verifiable. "POST /users returns 201 with user ID" — not "user creation works." Scoped to this slice; don't duplicate criteria earlier slices already own

Cover: happy path always; input validation where a new interface appears; edge cases when core to the slice; integration with prior slices from slice 2 onward. The implementer discovers more tests during red-green-refactor — you're defining the boundary of done, not the full test plan

## Output — SLICES.md

```markdown
# [Project Name] — Implementation Slices

> Generated from [PROJECT_BRIEF.md](./PROJECT_BRIEF.md)

## Slice 1: [Verb] [what] *(MVP)*

### What this delivers
One sentence — what a user/system can do once this ships

### Acceptance criteria
1. ...
2. ...

### Implementation notes
Key decisions, constraints, layers touched. For slice 2+: **Depends on**: Slice N

---

(repeat per slice)
```

## Quality bar

- One `SLICES.md`, not scattered files
- Every slice is demoable and testable
- Dependencies between slices are explicit
- A dev reading `SLICES.md` knows what to build first, what done looks like, and what order to go in
- Slices are right sized for expert agents
