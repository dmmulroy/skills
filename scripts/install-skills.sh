#!/usr/bin/env bash
set -euo pipefail

# Installs all skills in this repository into the dotfiles-managed Agent Skills
# directory:
#   ~/.dotfiles/home/.agents/skills
# Each skill is copied as a real directory (not symlinked), so the installed
# copies are self-contained and survive even if this repo is moved or removed.
# Re-run after a `git pull` (or after scripts/sync-matt-skills.sh) to refresh.

REPO="$(cd "$(dirname "$0")/.." && pwd)"
DEST="$HOME/.dotfiles/home/.agents/skills"

mkdir -p "$DEST"

while IFS= read -r -d '' skill_md; do
  src="$(dirname "$skill_md")"
  name="$(basename "$src")"
  target="$DEST/$name"

  rm -rf "$target"
  cp -R "$src" "$target"
  rm -rf "$target/.git"
  echo "installed $name -> $target"
done < <(find "$REPO" \
  -name SKILL.md \
  -not -path '*/node_modules/*' \
  -not -path '*/.git/*' \
  -print0)
