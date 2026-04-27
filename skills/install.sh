#!/usr/bin/env bash
# Symlink every SKILL.md directory under skills/ (any depth) flat into
# ~/.claude/skills/<name>/ and ~/.cursor/skills/<name>/. Safe to re-run.
# Harness is the source of truth; existing destinations are overwritten.

set -e

SKILLS_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT=$(dirname "$SKILLS_DIR")
LINK_ROOTS=("$HOME/.claude/skills" "$HOME/.cursor/skills")
# Legacy locations we migrate away from — any symlink pointing here is pruned.
OLD_LOCATIONS=("$HOME/Documents/skills")

# Remove any symlink in target_dir whose target starts with one of the prefixes.
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

# Discover skills
names=() srcs=() seen=" "
while IFS= read -r skill_md; do
  src=$(dirname "$skill_md")
  name=$(basename "$src")
  if [[ "$seen" == *" $name "* ]]; then
    echo "error: duplicate skill folder name '$name'" >&2
    exit 1
  fi
  seen+="$name "
  names+=("$name")
  srcs+=("$src")
done < <(find "$SKILLS_DIR" -name SKILL.md -not -path '*/.git/*' -not -path '*/tests/*' 2>/dev/null | sort)

for td in "${LINK_ROOTS[@]}"; do
  mkdir -p "$td"
  prune_symlinks_by_prefix "$td" "$REPO_ROOT" "${OLD_LOCATIONS[@]}"
  for i in "${!names[@]}"; do
    dest="$td/${names[i]}"
    rm -f "$dest"
    ln -s "${srcs[i]}" "$dest"
  done
done
echo "Skills: ${#names[@]} symlinked into ${LINK_ROOTS[*]}"
