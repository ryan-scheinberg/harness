---
name: cursor-delegate
description: Delegate tasks to Composer 2 agent. Use this different model to code, QA, attack your design, catch blind spots, or explore alternatives.
---

Spawn a Composer 2 job on a task. Runs async in background so your chat isn't blocked. There is a max of 4 agents between you and other delegators; extra and `delegate.sh` fails with a clear error; do other work or wait for a job to finish, then retry

**Important**: Composer has no session history, but will draw on agent skills. Give it full context: what branch/files to work with, what you've tried, what you want back, and where to write results. Set the workspace to the project it needs to read or edit

**Parallel runs**: Spawning 2+ jobs at once is powerful—e.g., have two Composers try different approaches to the same problem. Especially useful if you think you're being too positive; give each a different viewpoint to defend. *Note*: Wait ~2 seconds between spawns; Cursor's CLI has a startup race on its config file that can fail jobs launched in the same second

## Usage

Spawn a job (returns job_id):
```bash
bash scripts/delegate.sh "I'm on branch feature/auth in this repo. QA my changes for bugs and edge cases." ~/my-project
bash scripts/delegate.sh "Read docs/plan.md. Write a revised version addressing [issues] to docs/plan-v2.md." ~/my-project
```

Poll for results:
```bash
bash scripts/status.sh cursor-1234567890-5678
```

List all jobs:
```bash
bash scripts/list.sh
```

## How it works

- `delegate.sh` spawns Composer 2 in background with `--trust` (edit mode) and returns a `job_id`
- Output streams to `/tmp/cursor-delegate-<job_id>.log`
- `status.sh` returns `running` or `done` + full JSON output
- Jobs end on their own (no shutdown needed)
- Registry at `~/.claude/cursor-registry.json` tracks jobs globally. Do not manually edit unless asked
