---
name: claude-cron
description: Schedule a recurring headless `claude -p` run on the user's laptop. Use when the user wants daily or periodic automated Claude sessions — morning briefs, recurring brainstorms, scheduled checks, anything that fires a prompt on a cadence and logs the output
---

Schedule, list, or remove recurring `claude -p` runs. Specs live in `~/Documents/harness/schedules/<name>.cron` so the user can see what's configured; logs go to `~/.claude/logs/scheduled/<name>.log`. Do not manually edit unless asked

**Daily only.** Schedule must be in `M H * * *` format (e.g., `0 9 * * *` for 9am daily). Catch-up is automatic: if the laptop was asleep at the scheduled moment, the job runs on the next cron tick after wake, and still fires at the intended time the next day

## Schedule a run

```bash
bash scripts/add.sh <name> "<cron-schedule>" "<prompt>"
```

Example:

```bash
bash scripts/add.sh daily-angle "0 9 * * *" "/skillscake-marketing-ideation"
```

- `name` — kebab-case, unique; becomes the filename, log name, and stamp key
- `cron-schedule` — cron expression `M H * * *`. Any other format (weekly, hourly, every-N-minutes) is rejected
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

## How it works

1. `add.sh` writes a spec file to `~/Documents/harness/schedules/<name>.cron` and calls `~/Documents/harness/schedules/install.sh`
2. The installer writes one crontab line per job — an hourly tick at the user's minute (e.g., `0 * * * *` for a job scheduled at `0 9 * * *`). Non-harness crontab entries are untouched
3. Each tick invokes `~/Documents/harness/schedules/bin/run-if-due.sh <name>`
4. The wrapper runs the command iff (a) the job hasn't succeeded today and (b) the current hour is ≥ the target hour. Otherwise it no-ops
5. On exit-0 runs the wrapper writes a stamp to `~/Documents/harness/schedules/state/<name>.stamp`
