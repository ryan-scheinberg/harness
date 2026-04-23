---
name: request-manager
description: Send a message to your manager session — ask for a decision, report a slice done, push back on scope, flag a blocker. Use this instead of interrupting the user. Works for anything the session hierarchy should handle. Clarifications, permissions ("OK to do X?"), approvals, status updates, handing artifacts back
---

Queue a message in your manager's Claude session. Your manager was set at your spawn time. The message lands in their TUI input queue. If they're busy, Claude Code queues it until their current turn finishes. No polling, no reply file. The manager responds back through the symmetric `respond-to-request` skill, which types into your window the same way

## Usage

```bash
bash ~/Documents/harness/skills/harness-skillset/request-manager/scripts/message.sh "<question + enough context for a decision>"
```

Write the message as if the manager has no context on your work, but still keep it concise. Include what you want to do, why, and what you'll do next if approved.

## After sending

The script does not end your turn; you decide. Two cases:

- **Blocking** — the answer gates your next step (permission, scope call, unresolved tradeoff). End your turn after sending. The manager's reply will land as your next input
- **Non-blocking** — status update, slice-done report, FYI. Keep working. If you hit a blocker while waiting, end the turn then

Do not poll, do not loop waiting for a reply. Either end the turn or move on

## When NOT to use

- The manager has already answered the same question. Just act
- You're scope-creeping a question the slice already answers. Re-read the slice first
- `message.sh` returned an error (no manager set, manager not in registry). Only then call `PushNotification` for the user

Escalations to the user (launch, spend, compliance, strategic pivot) still go through your manager. They own the judgment call of whether it bumps up further. Don't bypass them
