#!/usr/bin/env python3
"""Ask-tier bash gate. Pairs with native permissions.deny for hard blocks.

Fires on PreToolUse for Bash. On pattern match, exits 2 so Claude asks the user.
Approval escape hatch: include `# claude-hook-approved: <reason>` anywhere
in the command to bypass the gate on re-issue.

Fail-open on any exception — a crashing gate must not brick Claude.
"""
from __future__ import annotations
import json, re, sys

ASK = [
    (r"\bbrew\s+(install|uninstall|cask|upgrade|tap|link|unlink|reinstall)\b", "brew mutation"),
    (r"\bnpm\s+(install|i|add)\s+-g\b", "npm global install"),
    (r"\bnpm\s+(install|i|add)\s+[^\-\s]", "npm install (prod dep)"),
    (r"\buv\s+(add|pip\s+install)\b", "uv package install"),

    (r"\bgit\s+reset\s+--hard\b", "git reset --hard"),
    (r"\bgit\s+push\b.*(--force\b|--force-with-lease\b|\s-f(\s|$))", "git force-push"),
    (r"\bgit\s+branch\s+-D\b", "git branch -D"),
    (r"\bgit\s+clean\s+.*-[fFxXdD]", "git clean (force)"),
    (r"\bgit\s+rebase\s+.*-i\b", "git interactive rebase"),
    (r"\bgit\s+remote\s+(add|remove|set-url)\b", "git remote mutation"),

    (r"\bgh\s+pr\s+(merge|close|reopen)\b", "gh pr mutation"),
    (r"\bgh\s+release\s+(create|upload|delete|edit)\b", "gh release mutation"),
    (r"\bgh\s+repo\s+(delete|archive|transfer|rename|edit)\b", "gh repo mutation"),
    (r"\bgh\s+issue\s+(create|close|reopen|delete)\b", "gh issue mutation"),
    (r"\bgh\s+workflow\s+(run|disable|enable)\b", "gh workflow"),
    (r"\bglab\s+mr\s+(merge|close|reopen|create)\b", "glab mr mutation"),
    (r"\bglab\s+release\s+(create|delete|update)\b", "glab release mutation"),
    (r"\bglab\s+repo\s+(delete|archive|transfer|fork)\b", "glab repo mutation"),
    (r"\bglab\s+issue\s+(create|close|reopen|delete)\b", "glab issue mutation"),
    (r"\bglab\s+ci\s+(run|trigger|retry)\b", "glab ci"),

    (r"\baws\s+s3(api)?\s+(rm|mv|delete-|put-bucket-)", "aws s3 destructive"),
    (r"\baws\s+s3\s+sync\b.*--delete\b", "aws s3 sync --delete"),
    (r"\baws\s+ecs\s+update-service\b", "aws ecs update-service (prod deploy)"),
    (r"\baws\s+lambda\s+update-function-code\b", "aws lambda update (prod deploy)"),
    (r"\baws\s+cloudfront\s+create-invalidation\b", "cloudfront invalidation"),
    (r"\baws\s+(ec2|rds|iam|dynamodb|cloudformation|route53|secretsmanager|ssm|kms)\s+(create-|delete-|put-|update-|terminate-|modify-|run-|start-|stop-|reboot-|attach-|detach-|register-|deregister-|associate-|disassociate-|enable-|disable-|grant-|revoke-|authorize-|import-|reset-|restore-|rollback-)", "aws write"),
    (r"\baws\s+configure\b", "aws configure"),
    (r"\baws\s+sts\s+assume-role\b", "aws assume-role"),

    (r"\b(tofu|terraform)\s+(apply|destroy|import|taint|untaint)\b", "tofu/terraform apply/destroy"),
    (r"\b(tofu|terraform)\s+state\s+(rm|mv|push|replace-provider)\b", "tofu/terraform state mutation"),

    (r"\balembic\s+(upgrade|downgrade|stamp)\b", "alembic migration"),

    (r"\bdocker\s+push\b", "docker push"),

    (r"\bssh-keygen\b", "ssh-keygen"),
    (r"\bssh-add\s+.*-D\b", "ssh-add -D"),
    (r"\bsecurity\s+(add-generic-password|add-internet-password|delete-.*-password|set-keychain-password|lock-keychain)\b", "keychain mutation"),
    (r"(^|\s)(cat|less|more|head|tail|cp|mv)\s+[^\n]*\.env(\.|\s|$)", ".env file read/copy"),

    (r"\bpkill\s+-9\b", "pkill -9"),
    (r"\biptables\b", "iptables"),
    (r"\bpfctl\b.*(-[efd]|enable|disable|flush)", "pfctl"),
    (r"\blaunchctl\s+(load|unload|bootstrap|bootout|enable|disable|remove)\b", "launchctl"),

    (r"\bcurl\b.*api\.typefully\.com.*(-X\s+(POST|DELETE|PUT|PATCH)|--data|--request\s+(POST|DELETE|PUT|PATCH))", "typefully api write"),
    (r"\bcurl\b.*(skillscake|agenthorizonai).*(-X\s+(POST|DELETE|PUT|PATCH)|--data|--request\s+(POST|DELETE|PUT|PATCH))", "skillscake/agenthorizon api write"),
]

MARKER = re.compile(r"#\s*claude-hook-approved\s*:", re.IGNORECASE)

def main() -> int:
    try:
        data = json.loads(sys.stdin.read() or "{}")
        cmd = (data.get("tool_input") or {}).get("command") or ""
    except Exception:
        return 0

    if not cmd or MARKER.search(cmd):
        return 0

    for pat, label in ASK:
        if re.search(pat, cmd, re.IGNORECASE):
            print(
                f"REQUIRES APPROVAL: {label}.\n"
                f"Command: {cmd}\n"
                "Ask the user. When they say ok, re-run with a comment anywhere in the command:\n"
                "    # claude-hook-approved: <what the user said>",
                file=sys.stderr,
            )
            return 2
    return 0

if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except Exception:
        raise SystemExit(0)
