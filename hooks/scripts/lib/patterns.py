"""Regex patterns for bash_gate.

Two tiers: HARD_BLOCK fires even when an approval marker is present (these are
things Claude should never run, period). APPROVAL_GATE fires unless an approval
marker is present (high-blast-radius but legitimate with human consent).

Patterns are evaluated in order; first match wins. Keep patterns narrow —
false positives cost Ryan an extra round-trip, false negatives cost real damage.

When editing: also edit the smoke-test examples at the bottom of bash_gate.py.
"""
from __future__ import annotations

import re
from dataclasses import dataclass


@dataclass(frozen=True)
class Rule:
    regex: re.Pattern[str]
    label: str

    @classmethod
    def mk(cls, pattern: str, label: str) -> "Rule":
        return cls(re.compile(pattern, re.IGNORECASE), label)


# ---------------------------------------------------------------------------
# HARD_BLOCK — never run, approval marker is ignored.
# ---------------------------------------------------------------------------
HARD_BLOCK: list[Rule] = [
    # rm -rf on system-critical paths
    Rule.mk(r"\brm\s+-[a-z]*r[a-z]*f[a-z]*\s+/(\s|$|#)", "rm -rf /"),
    Rule.mk(r"\brm\s+-[a-z]*f[a-z]*r[a-z]*\s+/(\s|$|#)", "rm -rf /"),
    Rule.mk(r"\brm\s+-[a-z]*r[a-z]*\s+/\*", "rm -rf /*"),
    Rule.mk(r"\brm\s+-[a-z]*r[a-z]*\s+(\$HOME|~)[\s/]", "rm -rf on $HOME/~"),
    Rule.mk(r"\bsudo\s+rm\b", "sudo rm"),

    # classic fork bomb
    Rule.mk(r":\(\)\s*\{\s*:\s*\|\s*:\s*&\s*\}\s*;\s*:", "fork bomb"),

    # disk / filesystem destruction
    Rule.mk(r"\bmkfs(\.[a-z0-9]+)?\b", "filesystem format"),
    Rule.mk(r"\bfdisk\b", "fdisk (partition edit)"),
    Rule.mk(r"\bdiskutil\s+(eraseDisk|eraseVolume|zeroDisk|secureErase)\b", "diskutil erase"),
    Rule.mk(r"\bdd\s+.*of=/dev/(r?disk\d|sd[a-z]|nvme\d|nbd\d)", "raw disk write via dd"),

    # system power
    Rule.mk(r"\b(shutdown|halt|poweroff|reboot)\b(\s|$)", "system power command"),

    # pipe-to-shell installers
    Rule.mk(r"\bcurl\b[^|;]+\|\s*(sudo\s+)?(sh|bash|zsh|ksh)\b", "curl | sh"),
    Rule.mk(r"\bwget\b[^|;]+\|\s*(sudo\s+)?(sh|bash|zsh|ksh)\b", "wget | sh"),

    # force-push to protected branches
    Rule.mk(
        r"\bgit\s+push\b.*(--force\b|--force-with-lease\b|\s-f\s).*\b(main|master|production|prod|release)\b",
        "git force-push to protected branch",
    ),
    Rule.mk(
        r"\bgit\s+push\b.*\b(main|master|production|prod|release)\b.*(--force\b|--force-with-lease\b|\s-f(\s|$))",
        "git force-push to protected branch",
    ),

    # kill PID 1 / init
    Rule.mk(r"\bkill\s+-9?\s+1\b", "kill PID 1"),
]


# ---------------------------------------------------------------------------
# APPROVAL_GATE — run only when an approval marker is present.
# ---------------------------------------------------------------------------
APPROVAL_GATE: list[Rule] = [
    # ----------- package installers / global state changers -----------------
    Rule.mk(r"\bbrew\s+(install|uninstall|cask|upgrade|tap|link|unlink|reinstall)\b", "brew mutation"),
    Rule.mk(r"\bnpm\s+(install|i|add)\s+-g\b", "npm global install"),
    Rule.mk(r"\byarn\s+global\s+add\b", "yarn global add"),
    Rule.mk(r"\bpnpm\s+(install|add)\s+-g\b", "pnpm global install"),
    Rule.mk(r"\bnpm\s+(install|i|add)\b(?!.*(--save-dev|--dev|-D\b))", "npm install (prod dep)"),
    Rule.mk(r"\bpip3?\s+install\b", "pip install"),
    Rule.mk(r"\bpipx\s+(install|upgrade|reinstall)\b", "pipx install"),
    Rule.mk(r"\buv\s+(add|pip\s+install)\b", "uv package install"),
    Rule.mk(r"\bgem\s+install\b", "gem install"),
    Rule.mk(r"\bcargo\s+install\b", "cargo install"),
    Rule.mk(r"\bgo\s+install\b", "go install"),
    Rule.mk(r"\bcocoapods\s+.*install\b|\bpod\s+install\b", "pod install"),

    # ----------- filesystem mutations outside scratch dirs ------------------
    # rm -rf on anything not clearly ephemeral (tmp, var/tmp, .cache, node_modules)
    Rule.mk(
        r"\brm\s+-[a-z]*r[a-z]*\b(?!.*(\s|^)(/tmp/|/var/tmp/|\./tmp/|\.cache/|node_modules|__pycache__|\.pytest_cache|\.next/|\.turbo/|dist/|build/))",
        "rm -rf outside scratch dirs",
    ),
    Rule.mk(r"\bchmod\s+-R\b(?!.*(/tmp/|/var/tmp/))", "recursive chmod outside scratch"),
    Rule.mk(r"\bchown\s+-R\b(?!.*(/tmp/|/var/tmp/))", "recursive chown outside scratch"),

    # ----------- git destructive (non-main branches included in gate) -------
    Rule.mk(r"\bgit\s+reset\s+--hard\b", "git reset --hard"),
    Rule.mk(r"\bgit\s+push\b.*(--force\b|--force-with-lease\b|\s-f\s)", "git force-push (non-protected)"),
    Rule.mk(r"\bgit\s+branch\s+-D\b", "git branch -D (force delete)"),
    Rule.mk(r"\bgit\s+clean\s+.*-[fFxXdD]", "git clean (force)"),
    Rule.mk(r"\bgit\s+filter-(branch|repo)\b", "git rewrite history"),
    Rule.mk(r"\bgit\s+rebase\s+.*-i\b", "git interactive rebase"),
    Rule.mk(r"\bgit\s+remote\s+(add|remove|set-url)\b", "git remote mutation"),

    # ----------- GitHub / GitLab CLIs (write operations) --------------------
    Rule.mk(r"\bgh\s+pr\s+(merge|close|reopen)\b", "gh pr mutation"),
    Rule.mk(r"\bgh\s+release\s+(create|upload|delete|edit)\b", "gh release mutation"),
    Rule.mk(r"\bgh\s+repo\s+(delete|archive|transfer|rename|edit)\b", "gh repo mutation"),
    Rule.mk(r"\bgh\s+issue\s+(create|close|reopen|delete)\b", "gh issue mutation"),
    Rule.mk(r"\bgh\s+workflow\s+(run|disable|enable)\b", "gh workflow trigger"),

    Rule.mk(r"\bglab\s+mr\s+(merge|close|reopen|create)\b", "glab mr mutation"),
    Rule.mk(r"\bglab\s+release\s+(create|delete|update)\b", "glab release mutation"),
    Rule.mk(r"\bglab\s+repo\s+(delete|archive|transfer|fork)\b", "glab repo mutation"),
    Rule.mk(r"\bglab\s+issue\s+(create|close|reopen|delete)\b", "glab issue mutation"),
    Rule.mk(r"\bglab\s+ci\s+(run|trigger|retry)\b", "glab CI trigger"),

    # ----------- AWS CLI write operations ----------------------------------
    Rule.mk(r"\baws\s+s3(api)?\s+(rm|mv|cp\s+.*\s+s3://|sync\s+.*\s+s3://|delete-object|delete-objects|delete-bucket|put-object|put-bucket-.*)\b", "aws s3 write/delete"),
    Rule.mk(
        r"\baws\s+(ec2|rds|lambda|iam|dynamodb|cloudformation|route53|ses|sqs|sns|cloudfront|ecs|eks|elasticbeanstalk|secretsmanager|ssm|kms|apigateway|events)\s+"
        r"(create-|delete-|put-|update-|terminate-|modify-|run-|start-|stop-|reboot-|invoke|publish|send-|attach-|detach-|register-|deregister-|associate-|disassociate-|enable-|disable-|tag-|untag-|grant-|revoke-|authorize-|import-|reset-|restore-|rollback-|release-)",
        "aws write operation",
    ),
    Rule.mk(r"\baws\s+configure\b", "aws configure (credential write)"),
    Rule.mk(r"\baws\s+sts\s+assume-role\b", "aws assume role"),

    # ----------- secrets / keychain access ---------------------------------
    Rule.mk(
        r"(^|[\s;&|])(cat|less|more|head|tail|cp|mv|rsync|scp|open|grep)\s+.*~/\.ssh/",
        "read/copy from ~/.ssh",
    ),
    Rule.mk(
        r"(^|[\s;&|])(cat|less|more|head|tail|cp|mv|rsync|scp|open|grep)\s+.*~/\.aws/credentials",
        "read ~/.aws/credentials",
    ),
    Rule.mk(
        r"\bsecurity\s+(add-generic-password|add-internet-password|delete-.*-password|find-.*-password|set-keychain-password|unlock-keychain|lock-keychain)\b",
        "macOS keychain mutation/read",
    ),
    Rule.mk(r"\bssh-keygen\b", "ssh-keygen (may overwrite keys)"),
    Rule.mk(r"\bssh-add\s+.*-D\b", "ssh-add -D (delete identities)"),
    Rule.mk(r"(^|\s)(cat|less|more|head|tail|cp|mv|rsync|scp)\s+.*\.env(\.|\s|$)", "read/copy .env file"),

    # ----------- prod deploy / release surfaces ----------------------------
    Rule.mk(r"\bvercel\s+(deploy|alias|env).*--prod\b", "vercel production deploy"),
    Rule.mk(r"\bvercel\s+--prod\b", "vercel production deploy"),
    Rule.mk(r"\bnetlify\s+deploy\b.*--prod\b", "netlify production deploy"),
    Rule.mk(r"\bfly\s+(deploy|launch|scale|secrets|machine)\b", "fly.io mutation"),
    Rule.mk(r"\brailway\s+(up|deploy|run)\b", "railway mutation"),
    Rule.mk(r"\bheroku\s+(releases:rollback|apps:destroy|pg:|config:set|run\s+)", "heroku mutation"),

    # ----------- skillscake / production env markers -----------------------
    Rule.mk(r"\b(SKILLSCAKE|NEXT_PUBLIC|NODE)_(ENV|STAGE|TARGET|ENVIRONMENT)=(prod|production|live)\b", "production env var"),
    Rule.mk(r"\bDATABASE_URL=.*@.*(prod|production)", "prod DATABASE_URL"),
    # Pattern intentionally coarse; refine once Ryan specifies real prod markers.

    # ----------- Typefully API writes via curl (no MCP yet) ----------------
    Rule.mk(
        r"\bcurl\b.*api\.typefully\.com.*(-X\s+(POST|DELETE|PUT|PATCH)|--data|--request\s+(POST|DELETE|PUT|PATCH))",
        "typefully API write",
    ),
    # SMTP / mail sending via curl
    Rule.mk(r"\bcurl\b.*smtp://", "curl SMTP send"),

    # ----------- process / network mutations -------------------------------
    Rule.mk(r"\bpkill\s+-9\b", "pkill -9"),
    Rule.mk(r"\biptables\b", "iptables mutation"),
    Rule.mk(r"\bpfctl\b.*(-[efd]|enable|disable|flush)", "pfctl mutation"),
    Rule.mk(r"\blaunchctl\s+(load|unload|bootstrap|bootout|enable|disable|remove)\b", "launchctl mutation"),
    Rule.mk(r"\bscutil\s+--", "scutil system config mutation"),

    # ----------- schemas / databases ---------------------------------------
    Rule.mk(r"\b(psql|mysql|mongo|mongosh|sqlite3)\b.*(DROP\s+|TRUNCATE\s+|DELETE\s+FROM)", "database destructive SQL"),
    Rule.mk(r"\bprisma\s+(migrate|db)\s+(reset|push|deploy)\b", "prisma migration"),
    Rule.mk(r"\bsupabase\s+(db\s+reset|projects\s+delete)\b", "supabase reset/delete"),
]


# ---------------------------------------------------------------------------
# APPROVAL_MARKER — comment in a bash command indicating user consent.
# ---------------------------------------------------------------------------
APPROVAL_MARKER_RE = re.compile(r"#\s*claude-hook-approved\s*:\s*(.+?)\s*$", re.MULTILINE)


def has_approval_marker(command: str) -> tuple[bool, str | None]:
    """Return (has_marker, reason). Reason is the text after the colon."""
    m = APPROVAL_MARKER_RE.search(command)
    if m:
        return True, m.group(1).strip()
    return False, None


def match_first(command: str, rules: list[Rule]) -> Rule | None:
    for r in rules:
        if r.regex.search(command):
            return r
    return None
