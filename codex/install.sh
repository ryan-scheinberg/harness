#!/usr/bin/env bash
# Install harness skills into Codex.
#
# Non-role skills are symlinked directly from skills/. Role skills are generated
# into ~/.codex/skills so Claude-specific slash-command wording stays out of the
# source role files.

set -e

CODEX_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT=$(dirname "$CODEX_DIR")
SKILLS_DIR="$REPO_ROOT/skills"
LINK_ROOT="$HOME/.codex/skills"
GLOBAL_SRC="$REPO_ROOT/CLAUDE.md"
GLOBAL_GENERATED_DIR="$CODEX_DIR/generated"
GLOBAL_GENERATED="$GLOBAL_GENERATED_DIR/AGENTS.md"
GLOBAL_LINK="$HOME/.codex/AGENTS.md"

mkdir -p "$LINK_ROOT" "$GLOBAL_GENERATED_DIR"

install_global_agents() {
  [[ -f "$GLOBAL_SRC" ]] || { echo "missing $GLOBAL_SRC"; exit 1; }

  cp "$GLOBAL_SRC" "$GLOBAL_GENERATED"

  if [[ -e "$GLOBAL_LINK" && ! -L "$GLOBAL_LINK" ]]; then
    echo "error: refusing to overwrite non-symlink Codex global instructions: $GLOBAL_LINK" >&2
    exit 1
  fi

  rm -f "$GLOBAL_LINK"
  ln -s "$GLOBAL_GENERATED" "$GLOBAL_LINK"

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
  local name="$3"

  remove_owned_dest "$dest"
  if [[ -e "$dest" ]]; then
    echo "error: refusing to overwrite non-harness Codex skill: $dest" >&2
    exit 1
  fi

  mkdir -p "$dest"
  printf 'generated from %s\n' "$src" > "$dest/.harness-codex-generated"
  LC_ALL=C perl -0pe '
    s/When the user runs `claude`, you appear/When the user runs bare `codex`, you appear/g;
    s/role'\''s slash command/role'\''s skill invocation/g;
    s#/role-#\$role-#g;
    s#beside the `\$role-\*` command#beside the `\$role-*` skill invocation#g;
    s#role command#role invocation#g;
  ' "$src/SKILL.md" > "$dest/SKILL.md"
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
    "$SKILLS_DIR/roles-skillset"/role-*)
      write_codex_role "$src" "$dest" "$name"
      ;;
    *)
      write_symlinked_skill "$src" "$dest"
      ;;
  esac
done

install_global_agents

echo "Codex skills: ${#names[@]} installed into $LINK_ROOT"
echo "Codex global instructions: $GLOBAL_LINK -> $GLOBAL_GENERATED"
