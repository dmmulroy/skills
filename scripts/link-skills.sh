#!/usr/bin/env bash
set -euo pipefail

# Links all skills in this repository into the dotfiles-managed Agent Skills
# directory:
#   ~/.dotfiles/home/.agents/skills
# Each entry is a symlink into this repo, so a `git pull` is all that's needed
# to keep installed skills up to date.

REPO="$(cd "$(dirname "$0")/.." && pwd)"
DEST="$HOME/.dotfiles/home/.agents/skills"

# If $DEST is a symlink that resolves into this repo, we'd end up writing the
# per-skill symlinks back into the repo. Detect and bail out instead of
# polluting the working copy.
if [ -L "$DEST" ]; then
  resolved="$(python3 -c 'import os, sys; print(os.path.realpath(sys.argv[1]))' "$DEST")"
  case "$resolved" in
    "$REPO"|"$REPO"/*)
      echo "error: $DEST is a symlink into this repo ($resolved)." >&2
      echo "Remove it (rm \"$DEST\") and re-run; the script will recreate it as a real dir." >&2
      exit 1
      ;;
  esac
fi

mkdir -p "$DEST"

while IFS= read -r -d '' skill_md; do
  src="$(dirname "$skill_md")"
  name="$(basename "$src")"
  target="$DEST/$name"

  if [ -e "$target" ] && [ ! -L "$target" ]; then
    echo "error: $target already exists and is not a symlink." >&2
    echo "Move or remove it manually before linking $name." >&2
    exit 1
  fi

  ln -sfn "$src" "$target"
  echo "linked $name -> $src ($DEST)"
done < <(find "$REPO" \
  -name SKILL.md \
  -not -path '*/node_modules/*' \
  -not -path '*/.git/*' \
  -print0)
