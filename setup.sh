#!/usr/bin/env bash
# Unified harness installer: skills, agents, global CLAUDE.md, schedules.
# Hooks are installed separately via hooks/install.sh — not run from here.
# This repo is the source of truth: setup.sh unconditionally replaces the
# destinations with symlinks back here.

set -e

REPO_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
SKILL_LINK_ROOTS=("$HOME/.claude/skills" "$HOME/.cursor/skills")
AGENT_LINK_ROOT="$HOME/.claude/agents"
CLAUDE_MD_DEST="$HOME/.claude/CLAUDE.md"
# Old locations we migrate symlinks away from. Any symlink currently pointing
# into one of these is considered stale and pruned before re-linking.
OLD_LOCATIONS=("$HOME/Documents/skills")

# --- shared helpers ---------------------------------------------------------

link_file() {
  local dest="$1" src="$2"
  mkdir -p "$(dirname "$dest")"
  rm -f "$dest"
  ln -s "$src" "$dest"
}

# Remove any symlink in target_dir whose resolved target starts with one of
# the given prefix paths.
prune_symlinks_by_prefix() {
  local target_dir="$1"; shift
  local prefixes=("$@")
  [[ -d "$target_dir" ]] || return 0
  local child target prefix
  for child in "$target_dir"/*; do
    [[ -L "$child" ]] || continue
    target=$(readlink "$child")
    for prefix in "${prefixes[@]}"; do
      if [[ "$target" == "$prefix"* ]]; then
        rm "$child"
        break
      fi
    done
  done
}

# --- skills -----------------------------------------------------------------

install_skills() {
  local -a names=() srcs=()
  local seen=" " skill_md src name
  while IFS= read -r skill_md; do
    src=$(dirname "$skill_md")
    name=$(basename "$src")
    if [[ "$seen" == *" $name "* ]]; then
      echo "error: duplicate skill folder name '$name'" >&2
      return 1
    fi
    seen+="$name "
    names+=("$name")
    srcs+=("$src")
  done < <(find "$REPO_ROOT/skills" -name SKILL.md -not -path '*/.git/*' 2>/dev/null | sort)

  local td i dest
  for td in "${SKILL_LINK_ROOTS[@]}"; do
    mkdir -p "$td"
    prune_symlinks_by_prefix "$td" "$REPO_ROOT" "${OLD_LOCATIONS[@]}"
    for i in "${!names[@]}"; do
      dest="$td/${names[i]}"
      rm -f "$dest"
      ln -s "${srcs[i]}" "$dest"
    done
  done
  echo "Skills: ${#names[@]} symlinked into ${SKILL_LINK_ROOTS[*]}"
}

# --- agents -----------------------------------------------------------------

install_agents() {
  local src_dir="$REPO_ROOT/agents"
  [[ -d "$src_dir" ]] || { echo "Agents: no agents/ dir, skipping"; return 0; }

  mkdir -p "$AGENT_LINK_ROOT"
  prune_symlinks_by_prefix "$AGENT_LINK_ROOT" "$REPO_ROOT"

  local count=0 agent dest
  for agent in "$src_dir"/*.md; do
    [[ -f "$agent" ]] || continue
    dest="$AGENT_LINK_ROOT/$(basename "$agent")"
    link_file "$dest" "$agent"
    count=$((count+1))
  done
  echo "Agents: $count symlinked into $AGENT_LINK_ROOT"
}

# --- CLAUDE.md --------------------------------------------------------------

install_claude_md() {
  local src="$REPO_ROOT/CLAUDE.md"
  [[ -f "$src" ]] || { echo "CLAUDE.md: no source, skipping"; return 0; }
  link_file "$CLAUDE_MD_DEST" "$src"
  echo "CLAUDE.md: symlinked $CLAUDE_MD_DEST"
}

# --- schedules --------------------------------------------------------------

install_schedules() {
  local schedules_installer="$REPO_ROOT/schedules/install.sh"
  if [[ ! -x "$schedules_installer" ]]; then
    echo "Schedules: no executable installer at $schedules_installer, skipping"
    return 0
  fi
  # Don't abort the whole install if crontab access fails (e.g. shell lacks
  # macOS Full Disk Access). Warn and continue — other pieces already succeeded.
  if ! "$schedules_installer"; then
    echo "Schedules: installer failed — skipping. On macOS, grant Full Disk Access to the shell running this and re-run schedules/install.sh." >&2
    return 0
  fi
}

# --- main -------------------------------------------------------------------

main() {
  install_skills
  install_agents
  install_claude_md
  install_schedules
  echo "Harness install complete"
}

main "$@"
