# Harness repo — agent notes

This repository is the **source of truth** for the user's Claude Code harness. Skills, the global `CLAUDE.md`, safety hooks, local schedules, and the optional Codex adapter all live here and are version-controlled in one place.

## Install / refresh

| Command | What it does |
| --- | --- |
| `./skills/install.sh` | Discovers every `SKILL.md` under `skills/` (any depth, skipping `.git/`) and flat-symlinks each directory into `~/.claude/skills/<name>/`. Prunes stale symlinks pointing into `$REPO_ROOT` or legacy `~/Documents/skills/`. You can run this |
| `./codex/install.sh` | Optional Codex adapter. Installs shared skills into `~/.codex/skills/<name>/`; non-role skills are symlinks, role skills are generated copies with Codex `$role-*` invocation wording so Claude role files stay untouched. Copies `CLAUDE.md` into ignored `codex/generated/AGENTS.md` and symlinks it to `~/.codex/AGENTS.md`. You can run this |
| `./hooks/install.sh` | Merges safety hooks (native deny rules + the PreToolUse bash gate and codex-timeout hooks) into `~/.claude/settings.json`. Writes to user settings. The user will run this |
| `./schedules/install.sh` | Syncs `schedules/*.cron` specs into the user's crontab under a delimited block. Writes to crontab, and needs macOS Full Disk Access. The user will run this |

`CLAUDE.md` is a one-time manual symlink: `ln -sf "$PWD/CLAUDE.md" ~/.claude/CLAUDE.md`

Installers are Bash 3.2-compatible so they run on macOS's default shell. Re-run an installer after adding, moving, or renaming anything in its directory. The repo is the source of truth: installers unconditionally overwrite their destinations, no adoption check or diff dance

## Constraints

- Two skill folders with the same basename anywhere under `skills/` will fail the script. Names must be unique across the whole tree since loaders flatten by basename

## Hooks

`hooks/settings.json` is the source of truth for `permissions.deny`. `hooks/install.sh` replaces the whole array in `~/.claude/settings.json` on each run, so any deny rule added through the Claude Code UI gets wiped. Copy it into `hooks/settings.json` to persist

When `bash_gate.py` blocks a command, tell the user what it wanted to do. If they OK it, re-run with an inline shell comment `# claude-hook-approved: <what the user said>`. Bash ignores the comment, the gate allows it through, and the approval shows up in the transcript for audit

## Schedules

`schedules/` holds local cron jobs. To add a recurring `claude -p` run, use the **`claude-cron`** skill: its `scripts/add.sh` generates the spec and syncs the crontab. Direct spec authoring is supported but rarely needed

Non-obvious bits:
- **Crontab edits inside the harness block don't stick.** `schedules/install.sh` rebuilds the delimited `# >>> harness schedules >>>` block on every run. Non-harness crontab entries pass through, but any edit inside the block via `crontab -e` gets wiped. Change the `.cron` spec instead
- **macOS Full Disk Access.** `crontab` needs FDA granted to the shell running the installer (System Settings → Privacy & Security → Full Disk Access → add Terminal/iTerm). Claude Code's own shell doesn't have FDA, so run `./schedules/install.sh` from a terminal you've granted access to
- **`state/` is gitignored.** The wrapper only updates the stamp on exit-0 runs, so failures retry on the next tick instead of silently falling behind a day

## Orchestration

Root is the user's base session — `claude` with no args injects `/role-root` (a zsh function in `~/.zshrc`; a prompt or flags bypass it). It does the work directly when it fits one context, orchestrates when it doesn't, and is the user's only point of contact

Orchestration is fire-and-collect, not a session hierarchy. Root spawns builders as `codex:codex-rescue` couriers — GPT 5.6 Luna in a real codex process, `$role-build` opening the forwarded prompt — and the other roles as `general-purpose` subagents opened with the role's slash command, each on its own worktree (the `Agent` tool, `isolation: "worktree"`). The worker runs to done and returns to root — subagents don't message each other, don't stay resident, and never ping the user

The loop: cut a batch into units → a `$role-build` luna courier per unit, parallel where independent → root merges every worktree branch to main → `/role-qa` on Fable against the assembled batch → re-build what it breaks → `/role-deploy`. Root reads each return and decides the next move

- **build** — one unit of work, architected then verified in-code, committed, returned. Proves its unit fully (trace, units, integration, every acceptance point) — a `/role-verify` subagent on Claude, its own pass on codex — but stands up no environments
- **verify** — the fast independent is-it-done check on one claimed artifact, medium effort, report-don't-fix. Unit-scale and in-code; the assembled running batch is qa's
- **qa** — breaks the assembled, running batch on Fable, through the project's own test discipline: integration and the hard cases that surface only once it's together. Tests hard, returns a verdict root can redelegate, does not fix
- **deploy** — ships a verified batch through the project's own deploy skill, which owns the pipeline and the gates for risky writes
- **harness-engineer** — evolves the harness from retros, outside the product loop. Does the work directly, spawns nothing

build and qa run against local or test, never production — verification that touches prod is an incident, not a check. Only deploy reaches production, through the deploy skill's gated pipeline

Inline `/effort medium` in a subagent's prompt sets that one spawn's effort — drop it beside the `/role-*` command to run a straightforward unit below root's xhigh; position in the prompt doesn't matter. verify runs medium — checking work, not hard reasoning. Luna's effort is the `--effort` flag in the courier prompt; Claude-side effort never reaches codex. Medium is faster and often sharper on straightforward or checking work; xhigh is for the hard reasoning

Role skills live under `skills/roles-skillset/role-<name>/` and install on a subagent via `/role-<name>` at the top of its prompt. Retros at `~/Documents/harness/retros/` are written at a workstream's close and read by the harness-engineer; the directory is gitignored, don't delete them

## Editing harness content

When you fix friction and the right place to capture it is a skill or `AGENTS.md`, follow the **`updating-ai-knowledge`** skill. Especially: do not change a skill's `name:` field (it aligns with symlink names and loaders), and prefer small, evidence-based edits

**Keep `README.md` in sync** with major structural changes to the layout — new top-level directories, installers, or install steps. README is the install/layout doc, not a skill or agent index, so routine additions under `skills/` or `agents/` don't need a README entry

### Voice

Match the surrounding file before writing anything new. Existing SKILL.md and role files are the reference — the ethos is enforced through them, not a style guide. The harness is a vessel, not a sports car: edits are deliberate, existing patterns beat personal preferences from other repos

- Drop end-of-line periods. Keep punctuation only where it separates mid-line clauses
- Imperative verbs, sentence fragments where tighter. No "you should", "it's important", "remember to", "always"
- Every rule carries its reason in one clause, not a paragraph. "Green tests are necessary, not sufficient" beats three sentences about testing discipline
- Admit cognitive limits where real (root can't hold every unit's full context; qa can't trust a unit's self-report). Keeps agents from faking capabilities they don't have
- No meta-narration or trust-building filler. Describe what to do, skip how the agent should feel about doing it
- Bold lead verb, then a fragment — the user's bullet format. Not "**Spawn a builder:** This is how you should..." but "**Spawn a builder** per unit, parallel where independent"
