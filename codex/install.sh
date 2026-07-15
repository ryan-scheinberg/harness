#!/usr/bin/env bash
# Install harness skills into Codex.
#
# Non-role skills are symlinked directly from skills/. A direct Codex role
# source wins when present; shared roles only rewrite their invocation syntax.

set -e

CODEX_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT=$(dirname "$CODEX_DIR")
SKILLS_DIR="$REPO_ROOT/skills"
ROLE_SKILLS_DIR="$SKILLS_DIR/roles-skillset"
CODEX_ROLE_SKILLS_DIR="$CODEX_DIR/roles"
LINK_ROOT="$HOME/.codex/skills"
CODEX_GLOBAL_SRC="$CODEX_DIR/AGENTS.md"
LEGACY_GENERATED_DIR="$CODEX_DIR/generated"
GLOBAL_LINK="$HOME/.codex/AGENTS.md"

mkdir -p "$LINK_ROOT"

install_global_agents() {
  [[ -f "$CODEX_GLOBAL_SRC" ]] || { echo "missing $CODEX_GLOBAL_SRC; create the separate local Codex instructions before installing"; exit 1; }

  if [[ -e "$GLOBAL_LINK" && ! -L "$GLOBAL_LINK" ]]; then
    echo "error: refusing to overwrite non-symlink Codex global instructions: $GLOBAL_LINK" >&2
    exit 1
  fi

  rm -f "$GLOBAL_LINK"
  ln -s "$CODEX_GLOBAL_SRC" "$GLOBAL_LINK"

  if [[ -f "$LEGACY_GENERATED_DIR/AGENTS.md" ]]; then
    rm "$LEGACY_GENERATED_DIR/AGENTS.md"
  fi
  rmdir "$LEGACY_GENERATED_DIR" 2>/dev/null || true

  if [[ -f "$HOME/.codex/AGENTS.override.md" ]]; then
    echo "warning: ~/.codex/AGENTS.override.md exists and will override $GLOBAL_LINK" >&2
  fi
}

remove_owned_dest() {
  local dest="$1"
  if [[ -L "$dest" ]]; then
    local target
    target=$(readlink "$dest")
    [[ "$target" == "$REPO_ROOT"* ]] && rm "$dest"
    return 0
  fi
  if [[ -f "$dest/.harness-codex-generated" ]]; then
    rm -rf "$dest"
  fi
}

write_codex_role() {
  local src="$1"
  local dest="$2"
  local format="$3"

  remove_owned_dest "$dest"
  if [[ -e "$dest" ]]; then
    echo "error: refusing to overwrite non-harness Codex skill: $dest" >&2
    exit 1
  fi

  mkdir -p "$dest"
  printf 'generated from %s\n' "$src" > "$dest/.harness-codex-generated"
  case "$format" in
    copy)
      cp "$src" "$dest/SKILL.md"
      ;;
    shared)
      sed 's#/role-#\$role-#g' "$src/SKILL.md" > "$dest/SKILL.md"
      ;;
    *)
      echo "error: unknown Codex role format: $format" >&2
      exit 1
      ;;
  esac
}

write_symlinked_skill() {
  local src="$1"
  local dest="$2"

  remove_owned_dest "$dest"
  if [[ -e "$dest" && ! -L "$dest" ]]; then
    echo "error: refusing to overwrite non-harness Codex skill: $dest" >&2
    exit 1
  fi

  rm -f "$dest"
  ln -s "$src" "$dest"
}

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
done < <(find "$SKILLS_DIR" -name SKILL.md -not -path '*/.git/*' -not -path '*/tests/*' -not -path '*/.eval-history/*' 2>/dev/null | sort)

for i in "${!names[@]}"; do
  name="${names[i]}"
  src="${srcs[i]}"
  dest="$LINK_ROOT/$name"

  case "$src" in
    "$ROLE_SKILLS_DIR"/role-*)
      codex_role="$CODEX_ROLE_SKILLS_DIR/$name/SKILL.md"
      if [[ -f "$codex_role" ]]; then
        write_codex_role "$codex_role" "$dest" copy
      else
        write_codex_role "$src" "$dest" shared
      fi
      ;;
    *)
      write_symlinked_skill "$src" "$dest"
      ;;
  esac
done

install_global_agents

echo "Codex skills: ${#names[@]} installed into $LINK_ROOT"
echo "Codex global instructions: $GLOBAL_LINK"
