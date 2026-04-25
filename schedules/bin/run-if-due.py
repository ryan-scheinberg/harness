#!/usr/bin/env python3
# Cron wrapper. Runs the spec's body if a scheduled fire has happened since
# the last successful run, unless the next fire is within 10 minutes (let the
# natural cron tick handle it). Stamps on success. Single-flight via mkdir lock.
# Requires: croniter (pip install croniter).
import os
import subprocess
import sys
import time
from datetime import datetime
from pathlib import Path

from croniter import croniter

if len(sys.argv) != 2:
    sys.exit("usage: run-if-due.py <job>")

job = sys.argv[1]
repo = Path(__file__).resolve().parent.parent
spec = repo / f"{job}.cron"
state = repo / "state"
stamp = state / f"{job}.stamp"
lock = state / f"{job}.lock"

if not spec.exists():
    sys.exit(f"no spec at {spec}")
state.mkdir(exist_ok=True)

try:
    lock.mkdir()
except FileExistsError:
    sys.exit(0)

try:
    lines = spec.read_text().splitlines()
    sched = next(
        line.split("schedule:", 1)[1].strip()
        for line in lines
        if line.lstrip().startswith("# schedule:")
    )

    now = datetime.now()
    prev_fire = croniter(sched, now).get_prev(datetime)
    next_fire = croniter(sched, now).get_next(datetime)
    last_stamp = int(stamp.read_text()) if stamp.exists() else 0

    if last_stamp >= prev_fire.timestamp():
        sys.exit(0)
    if (next_fire - now).total_seconds() <= 600:
        sys.exit(0)

    body = "\n".join(
        line for line in lines
        if line.strip() and not line.lstrip().startswith("#")
    )
    if not body:
        sys.exit(f"{spec} has no command body")

    env = {
        **os.environ,
        "PATH": "/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:" + os.environ.get("PATH", ""),
    }
    rc = subprocess.run(["bash", "-c", body], env=env).returncode
    if rc == 0:
        stamp.write_text(str(int(time.time())))
    sys.exit(rc)
finally:
    lock.rmdir()
