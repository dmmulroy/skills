# Skills

Personal agent skills for engineering, planning, writing, and tooling.

Thanks to [Matt Pocock](https://github.com/mattpocock) for the inspiration and tooling patterns from his [`mattpocock/skills`](https://github.com/mattpocock/skills) repo.

List or install with the open skills CLI:

```bash
npx skills@latest add dmmulroy/skills --list
npx skills@latest add dmmulroy/skills
```

Install a specific skill:

```bash
npx skills@latest add dmmulroy/skills --skill codebase-design
```

## Engineering standards

- [`code-review`](./code-review/SKILL.md) — review code against my coding standards and preferences.
- [`codebase-design`](./codebase-design/SKILL.md) — design and implement code in my preferred software-design style.
- [`coding-standards`](./coding-standards/SKILL.md) — shared reference package for vocabulary, design principles, review lens, and technology standards.
- [`improve-codebase-architecture`](./improve-codebase-architecture/SKILL.md) — scan for deepening opportunities and choose one to explore.

## Development

Link local skills into the dotfiles-managed Agent Skills directory:

```bash
./scripts/link-skills.sh
```

List skills:

```bash
./scripts/list-skills.sh
```

Create a release note for user-facing changes:

```bash
npm run changeset
```

Merges to `main` run the release workflow, which opens/updates the Changesets version PR and tags releases after that PR is merged.

