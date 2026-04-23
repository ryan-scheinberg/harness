---
name: respond-to-request
description: Reply to a subordinate session that pinged you via request-manager. Use when you're a manager and a report has asked for a decision or permission, or has given a status update. Report requests start with a `[from <name>]` prefix
---

Queue a reply in a report's Claude session. The reply lands in their TUI input queue and they consume it on their next turn. Symmetric to `request-manager`

## Usage

```bash
bash ~/Documents/harness/skills/harness-skillset/respond-to-request/scripts/respond.sh <session_name> "<decision + reasoning>"
```

`<session_name>` is the report's session name (shown in the `[from <name>]` prefix of their incoming request, and in `list.sh`)

## How to respond

When a report asks for a decision, you have three moves:

1. **Approve** — say yes with a one-line why
2. **Redirect** — say no, or "do it this other way", with the reasoning. Be specific enough they don't come back asking the same question shaped differently
3. **Escalate** — if the call is above your pay grade (launch, spend, compliance, strategic pivot), push it up yourself: use `request-manager` to ping your own manager if you have one, or `PushNotification` for the user if you're the CEO. Do not tell the report to ping up — you already have the context loaded, bouncing it down wastes a turn and loses nuance

Trust the report to have done basic thinking. If their question is underspecified, ask them one tight clarifying question via `respond.sh` rather than guessing

Replying does not end your turn. Keep working — supervise other reports, check on slices in flight. If you're genuinely out of work until this report comes back, that's the time to end the turn

## Don'ts

- Don't bounce escalations back down to the report. You push up, they don't
- Don't queue an unclear response
- Don't poll or wait for their next message; return to your own work
