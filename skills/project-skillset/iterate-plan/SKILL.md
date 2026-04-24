---
name: iterate-plan
description: Refine any plan/artifact through rigorous, structured questioning until every decision is resolved. Use when user wants to stress-test a plan, iterate on a brief or be grilled on a PROJECT_BRIEF.md
---

This skill intends architects to directly communicate with the user via `AskUserQuestion`

Truly challenge every assumption in the artifact. This is where the user's judgment, taste, and experience get injected into the project — don't short-circuit that by deciding too much yourself, and don't waste it on defaults either. Rigor with convergence: probe every tradeoff that shapes implementation, and surface the ones where the user's answer actually improves the plan

## Work the decision tree

Branch by branch. Resolve dependencies before moving forward. The stack decision shapes the testing question, the MVP decision shapes the deployment question. Out of order, you waste earlier answers

For each branch:

- Read what the brief already commits to
- Explore the codebase for anything it can resolve — `ls`, `grep`, config files, existing patterns
- Identify the real tradeoff — the thing that will actually split opinions
- Form your own recommendation before asking

## When to ask the user

Ask when the user's answer will make the plan stronger:

- A tradeoff where the user's taste, experience, or business context is what makes the call right
- A decision that changes a slice, a dependency, the architecture, or the risk surface
- An assumption in the brief worth challenging — even one you think holds up
- A place where you genuinely don't have a recommendation

Don't ask about naming, file layout, test placement, obvious library picks, log format, standard health-check shape. Decide these, write them into the brief, move on. The user is paying for judgment on tradeoffs, not for sign-off on defaults

## How to ask

Batch via one `AskUserQuestion` call covering the current branch. Each question names the tradeoff, offers your recommendation, and says why the alternative might be right — the user should be able to reply "go with your picks" and the brief still ends up stronger than before. The user should always be able to reply with a freeform option too

When an answer unlocks a new branch, send another batched call. Don't drift into one-at-a-time — the context-switch cost is what makes this skill feel long

## Updating the artifact

Edit the brief in place as branches close. Resolved decisions land in the relevant section with a short reason. Genuinely uncertain items move to Risks & Open Questions, each with what would close them. Don't re-open a decision once it's written unless new information contradicts it

## Stop condition

Stop when the next-best unresolved question wouldn't improve what gets built. Confirm with the user that nothing else is nagging them. Run `plan-to-slices` when the brief is internally consistent and every committed decision has a reason attached