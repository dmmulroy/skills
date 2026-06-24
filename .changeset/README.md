# Changesets

This repo uses Changesets for release notes, version bumps, git tags, and GitHub releases.

For a user-facing change, run:

```bash
npm run changeset
```

Commit the generated `.changeset/*.md` file with the change. When it reaches `main`, the release workflow opens or updates the version PR.
