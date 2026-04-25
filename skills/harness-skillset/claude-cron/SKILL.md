---
name: claude-cron
description: Schedule a recurring headless `claude -p` run on the user's laptop. Use when the user wants a periodic automated Claude session — morning briefs, recurring brainstorms, scheduled checks, anything that fires a prompt on a cadence and logs the output
---

Schedule, list, or remove recurring `claude -p` runs. Specs live in `~/Documents/harness/schedules/<name>.cron` so the user can see what's configured; logs go to `~/.claude/logs/scheduled/<name>.log`. Do not manually edit unless asked

Each tick is a real Claude run — be sparing on cadence. Avoid sub-hour schedules unless explicitly required

## Schedule a run

```bash
bash scripts/add.sh <name> "<cron-schedule>" "<prompt>"
```

Example:

```bash
bash scripts/add.sh morning-brief "0 9 * * *" "/skillscake-marketing-ideation"
```

- `name` — kebab-case, unique; becomes the filename, log name, and stamp key
- `cron-schedule` — any 5-field cron expression
- `prompt` — passed verbatim to `claude -p`; slash commands work. Prefer skills

## List scheduled runs

```bash
bash scripts/list.sh
```

Shows each job's schedule and last-successful-run timestamp

## Remove a scheduled run

```bash
bash scripts/remove.sh <name>
```
