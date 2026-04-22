#!/usr/bin/env bash
# Unified harness installer: skills, agents, global CLAUDE.md, hooks.
# Safe to re-run. For CLAUDE.md and agent files that already exist as real
# files at the destination, setup.sh verifies content matches the harness
# source before removing + symlinking; if content differs, it errors out
# so you can reconcile first.

set -e

REPO_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
SKILL_LINK_ROOTS=("$HOME/.claude/skills" "$HOME/.cursor/skills")
AGENT_LINK_ROOT="$HOME/.claude/agents"
CLAUDE_MD_DEST="$HOME/.claude/CLAUDE.md"
# Old locations we migrate symlinks away from. Any symlink currently pointing
# into one of these is considered stale and pruned before re-linking.
OLD_LOCATIONS=("$HOME/Documents/skills")

# --- shared helpers ---------------------------------------------------------

# Replace dest with symlink to src, but only if a real file at dest matches
# src byte-for-byte. If it differs, abort so the user can reconcile.
adopt_file() {
  local dest="$1" src="$2" label="$3"
  if [[ -L "$dest" ]]; then
    rm "$dest"
    ln -s "$src" "$dest"
    return 0
  fi
  if [[ -e "$dest" ]]; then
    if diff -q "$dest" "$src" >/dev/null 2>&1; then
      rm "$dest"
      ln -s "$src" "$dest"
    else
      echo "error: $label at $dest differs from $src" >&2
      echo "  Reconcile with: diff $dest $src" >&2
      echo "  Copy the canonical version into $src, then re-run setup.sh" >&2
      return 1
    fi
    return 0
  fi
  mkdir -p "$(dirname "$dest")"
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
    adopt_file "$dest" "$agent" "agent $(basename "$agent")"
    count=$((count+1))
  done
  echo "Agents: $count symlinked into $AGENT_LINK_ROOT"
}

# --- CLAUDE.md --------------------------------------------------------------

install_claude_md() {
  local src="$REPO_ROOT/CLAUDE.md"
  [[ -f "$src" ]] || { echo "CLAUDE.md: no source, skipping"; return 0; }
  adopt_file "$CLAUDE_MD_DEST" "$src" "global CLAUDE.md"
  echo "CLAUDE.md: symlinked $CLAUDE_MD_DEST"
}

# --- hooks ------------------------------------------------------------------

install_hooks() {
  local hooks_installer="$REPO_ROOT/hooks/setup-hooks"
  if [[ -x "$hooks_installer" ]]; then
    "$hooks_installer"
  else
    echo "Hooks: no executable installer at $hooks_installer, skipping"
  fi
}

# --- main -------------------------------------------------------------------

main() {
  install_skills
  install_agents
  install_claude_md
  install_hooks
  echo "Harness install complete"
}

main "$@"
