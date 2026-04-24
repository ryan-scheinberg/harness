---
name: complete-slice
description: Implement a vertical slice from SLICES.md end-to-end using TDD. Use when user wants to code a slice of a project or mentions "complete slice"
---

Take one slice from `SLICES.md` and ship it. Often for dev work, but might be a different task that you should still complete to the standards of the company

## Process

1. **Read the slice and the brief.** Find the target slice. Internalize what it delivers. Read `PROJECT_BRIEF.md` for architectural context

2. **Orient in the codebase.** Module boundaries, test patterns, naming, DI style, config approach, what prior slices built. Your code should feel native — same seams, same style. Greenfield: scaffolding + test runner + lint + CI belong inside slice 1, not as separate phases

3. **Plan the TDD sequence.** Map acceptance criteria to red-green-refactor cycles. Start with the criterion that proves the core approach. Decide what's a real collaborator and what's a system boundary to mock. Keep the plan light. Use judgement for when to use TDD or take a different approach

4. **Build one test at a time.** Red → green → refactor. One failing test, minimum code to pass, clean up while green, next. Public interfaces only; mock system boundaries only; tests survive internal refactors. Writing all tests first produces tests that describe imagined behavior, not actual. See [tdd-reference.md](tdd-reference.md) for the full methodology

5. **Bake SRE in as you go.** Structured logs at decision points and error paths; metrics on the behaviors this slice introduces; health checks on new endpoints; errors that fail explicitly at boundaries with context; config externalized. Operational readiness isn't a final step — if it's not present when tests go green, it won't be added

6. **Verify.** All acceptance criteria met and covered by passing tests. Observable outcomes demonstrably work — run it, hit the endpoint, read the logs. Full suite green, not just new tests. No unrelated changes mixed in

7. **Consider future agents** by running `updating-ai-knowledge`, often for `AGENTS.md`

8. **Close the slice.** Check the boxes in `SLICES.md`. Follow-up work, discovered edge cases, or risks land in the relevant future slice, or in a `## Notes` section at the bottom of `SLICES.md`

9. **Report** with `request-manager`

## Scope

Feature work, infrastructure-as-code, migrations, instrumentation, perf, bug fixes, deploy automation. Language, framework, and cloud agnostic

Not for: research spikes with no code deliverable, pure documentation, project planning (use `plan-to-slices`)

Skills you lean on: `verify` subagent before declaring done, `cursor-delegate` for a second opinion or implementation partner
