# Triggers

Version-controlled JSON specs for scheduled remote triggers (the `/schedule` skill creates these via the `RemoteTrigger` API).

Triggers live in Anthropic's cloud; this folder is a local reference and a way to track what cron-driven agents are configured. Nothing here is auto-installed by `setup.sh` — creating or updating a trigger still happens through the `/schedule` skill.

## Convention

One file per trigger, named `<trigger-name>.json`. Each file holds the `create` body used when the trigger was most recently created or updated, so the spec can be reviewed, diffed, and re-applied if needed.
