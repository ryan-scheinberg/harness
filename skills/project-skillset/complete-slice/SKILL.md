---
name: complete-slice
description: Implement a vertical slice from SLICES.md end-to-end using TDD. Use when user wants to code a slice of a project or mentions "complete slice".
---

# Complete Slice

Take a slice from `SLICES.md` and implement it. Each slice is a vertical, TDD-ready unit with a clear "done when" checklist. This skill is for technical implementation — software engineering and SRE work.

## Process

### 1. Read the slice

Read `SLICES.md` and find the target slice (the user will tell you which one, or you pick the next unfinished slice in order). Understand:

- **What this delivers** — the demoable outcome
- **Acceptance criteria** — these define what "done" looks like
- **Implementation notes** — constraints, patterns, dependencies
- **Done when** — your exit criteria

If a `PROJECT_BRIEF.md` exists, read it for broader architectural context — tech stack decisions, integration points, deployment targets.

### 2. Understand the codebase

**Existing codebase:** explore it before writing anything. Understand module boundaries, existing test patterns, naming conventions, dependency injection style, config approach. Your implementation should feel like it belongs.

**Greenfield:** this slice likely includes project scaffolding. Set up the repo structure, test runner, linting, and CI alongside the MVP implementation — they're one slice, not separate phases.

Check what prior slices built. Your slice depends on their interfaces — make sure you understand them and integrate with them, don't duplicate or contradict them.

### 3. Plan the approach

Map the slice's acceptance criteria to an implementation sequence. Each criterion may take one or more TDD cycles to satisfy.

Decide:

- Which criterion to tackle first (start with the one that proves the core approach for this slice)
- What existing code you'll touch vs create
- Where system boundaries are (what to mock vs use real implementations)

Keep the plan lightweight. The TDD cycles will surface details you can't predict.

### 4. Build with TDD

Follow red-green-refactor for each test you create for small vertical parts of the slice. See [tdd-reference.md](tdd-reference.md) for the full methodology.

The loop:

1. **Red** — write *one* failing test
2. **Green** — write minimal code to make it pass
3. **Refactor** — clean up while green. Extract duplication, simplify interfaces, deepen modules.
4. Move to the next test.

Rules:

- One test at a time. Don't write all tests first.
- Tests verify behavior through public interfaces, not implementation details.
- Tests should survive internal refactors.
- Only mock at system boundaries (external APIs, databases, time, file system).
- The slice's acceptance criteria guide what to test — you'll discover additional tests during red-green-refactor. Write them as they come up.
- Keep the code readable and clean.

### 5. Handle SRE concerns inline

Don't bolt observability or operability on at the end. As you implement:

- **Structured logging** — log at decision points and error paths, not every function entry/exit. Include correlation IDs where relevant.
- **Metrics** — instrument the behaviors the slice introduces. Counters for operations, histograms for latencies, gauges for resource usage.
- **Health checks** — if the slice introduces a service or endpoint, add a health check.
- **Error handling** — fail explicitly with actionable errors. Catch at boundaries, propagate with context.
- **Config** — externalize environment-specific values. No hardcoded URLs, credentials, or magic numbers.

If the slice's "done when" checklist mentions any of these, treat them as acceptance criteria. If it doesn't but the implementation calls for them, add them anyway — operational readiness isn't optional.

### 6. Verify against "done when"

When all tests pass, walk the slice's "done when" checklist:

- [ ] All acceptance criteria met and covered by passing tests
- [ ] Observable outcomes work as described (can demo X, endpoint returns Y, logs show Z)
- [ ] Code follows existing codebase conventions
- [ ] No unrelated changes mixed in
- [ ] Integration with prior slices is intact (run the full test suite, not just your new tests)

### 7. Mark the slice complete

Update `SLICES.md` — mark the slice's "done when" checkboxes. If you discovered follow-up work, edge cases, or risks during implementation, add a note to the relevant future slice or to the bottom of `SLICES.md` under a `## Notes` section.

## What this skill handles

- Feature implementation (APIs, services, data pipelines, UI components)
- Infrastructure as code (Terraform, Pulumi, CloudFormation, CDK)
- CI/CD pipeline configuration
- Database migrations and schema changes
- Service instrumentation and observability
- Performance optimization
- Bug fixes and hardening
- Deployment automation and rollout config

Language, framework, and cloud provider agnostic.

## What this skill does NOT handle

- Research spikes with no code deliverable — use a different approach
- Pure documentation or content creation
- Project planning or slice decomposition — use `plan-to-slices` for that

## Additional Resources

- For TDD methodology, testing philosophy, mocking guidelines, and refactoring patterns, see [tdd-reference.md](tdd-reference.md)
