#!/usr/bin/env bash
set -euo pipefail

# Syncs a curated set of Matt Pocock's agent skills
# (https://github.com/mattpocock/skills) into this repository as top-level
# skills, alongside our own. This makes our skills self-contained for
# consumers: the grilling/TDD workflows our skills reference are vendored here
# rather than assumed to be installed separately.
#
# Run from anywhere:
#   scripts/sync-matt-skills.sh            # sync from upstream main
#   MATT_SKILLS_REF=<sha|tag|branch> scripts/sync-matt-skills.sh
#
# Each synced skill directory is copied wholesale (including any sibling .md
# files it links to), so internal relative file links keep working. The skills
# are flattened to the repo root, so any `/slash-command` references between
# them resolve the same way once installed.
#
# After copying, we apply our own patches (see apply_patches below) so the
# vendored skills agree with our coding-standards instead of contradicting
# them. Patches fail loudly if upstream text drifts, so we notice and re-review.

REPO="$(cd "$(dirname "$0")/.." && pwd)"
UPSTREAM_URL="${MATT_SKILLS_URL:-https://github.com/mattpocock/skills.git}"
UPSTREAM_REF="${MATT_SKILLS_REF:-main}"

# Map of upstream skill paths (relative to the upstream `skills/` dir) that we
# vendor as top-level skills here. The destination name is the basename.
SKILLS=(
  "productivity/grill-me"
  "productivity/grilling"
  "engineering/grill-with-docs"
  "engineering/tdd"
)

# Replace an exact literal substring in a file, erroring if it is absent.
# Guards against upstream rewording silently dropping our patch.
patch_replace() {
  python3 - "$1" "$2" "$3" <<'PY'
import sys
path, search, repl = sys.argv[1], sys.argv[2], sys.argv[3]
with open(path, encoding="utf-8") as f:
    text = f.read()
if search not in text:
    sys.stderr.write(f"error: patch target not found in {path}:\n  {search!r}\n")
    sys.exit(1)
n = text.count(search)
with open(path, "w", encoding="utf-8") as f:
    f.write(text.replace(search, repl))
print(f"  patched {path} ({n}x)")
PY
}

# Append a marker-delimited override block to a file. Idempotent because each
# sync re-copies the file fresh before patching.
append_override() {
  printf '\n%s\n' "$2" >> "$1"
  echo "  appended override to $1"
}

# All local divergences from upstream live here, one place to review.
apply_patches() {
  echo
  echo "Applying local patches..."

  # tdd: upstream points at a `/codebase-design` skill we don't vendor.
  # Repoint to our equivalent standards doc.
  patch_replace "$REPO/tdd/SKILL.md" \
    'run the `/codebase-design` skill for the vocabulary and the testability checks' \
    'see `../coding-standards/DESIGNING_MODULES.md` for the vocabulary and testability checks'

  # tdd: upstream mocking.md permits boundary mocking and never bans spies/module
  # mocks. Our TESTING_AND_VERIFICATION.md forbids them. Make our doc win.
  append_override "$REPO/tdd/SKILL.md" "$TDD_OVERRIDE"

  # grill-with-docs: upstream points at a `/domain-modeling` skill we don't
  # vendor. Repoint to our equivalent standards doc.
  patch_replace "$REPO/grill-with-docs/SKILL.md" \
    'using the `/domain-modeling` skill.' \
    'using `../coding-standards/DOMAIN_MODELING.md`.'
}

read -r -d '' TDD_OVERRIDE <<'MD' || true
## Local overrides (dmmulroy/skills)

This skill is vendored from mattpocock/skills. In this repository,
`../coding-standards/TESTING_AND_VERIFICATION.md` is the source of truth for
testing and **supersedes `mocking.md`** wherever they disagree:

- Do not use module-patching APIs (`vi.mock`, `jest.mock`) or method-spy APIs
  (`vi.spyOn`, `jest.spyOn`). Replace behavior through a real seam instead
  (constructor-injected dependency, Effect service/layer, recording fake adapter,
  local database, runtime binding).
- Prefer recording fakes supplied through production seams over mocks, even at
  system boundaries.
- Use risk-matched evidence and the project tooling (Effect, Fast-Check,
  `vp test`) as described in the standards.
MD

tmp="$(mktemp -d)"
cleanup() { rm -rf "$tmp"; }
trap cleanup EXIT

echo "Cloning $UPSTREAM_URL ($UPSTREAM_REF)..."
git clone --quiet --depth 1 --branch "$UPSTREAM_REF" "$UPSTREAM_URL" "$tmp/upstream" 2>/dev/null \
  || git clone --quiet "$UPSTREAM_URL" "$tmp/upstream"

if [ "$UPSTREAM_REF" != "main" ]; then
  git -C "$tmp/upstream" checkout --quiet "$UPSTREAM_REF"
fi

synced_sha="$(git -C "$tmp/upstream" rev-parse --short HEAD)"

for entry in "${SKILLS[@]}"; do
  src="$tmp/upstream/skills/$entry"
  name="$(basename "$entry")"
  dest="$REPO/$name"

  if [ ! -f "$src/SKILL.md" ]; then
    echo "error: upstream skill not found: skills/$entry" >&2
    exit 1
  fi

  rm -rf "$dest"
  mkdir -p "$dest"
  # Copy contents (including sibling docs), excluding any VCS noise.
  cp -R "$src/." "$dest/"
  rm -rf "$dest/.git"

  echo "synced $entry -> $name/"
done

apply_patches

echo
echo "Done. Vendored from mattpocock/skills@$synced_sha (with local patches)"
echo "Review changes with: git -C \"$REPO\" status"
