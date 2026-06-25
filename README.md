# Skills

Personal coding-agent skills for TypeScript software design, review, refactoring, and implementation workflows.

These skills are designed to work together:

- `coding-standards/` — the shared standards package. Model-invoked. Defines the user's TypeScript design taste, vocabulary, non-negotiables, and topic references.
- `code-review/` — user-invoked standards-backed review workflow. Selects a review target, loads relevant standards, requires evidence for findings, and stays review-only.
- `tech-spec/` — user-invoked typed call-stack architecture handoff workflow. Produces code-shaped specs with alternatives, interfaces, seams, adapters, call stacks, and an RGR TDD plan.
- `improve-codebase-architecture/` — user-invoked architecture scan workflow. Finds standards-backed refactor opportunities and prepares focused briefs for `tech-spec`.

### Vendored from Matt Pocock

These skills are vendored from [mattpocock/skills](https://github.com/mattpocock/skills) so our workflows are self-contained for consumers (e.g. `tech-spec` and `improve-codebase-architecture` route into the grilling skills). Do not edit them by hand; re-sync instead.

- `grilling/` — model-invoked relentless interview loop.
- `grill-me/` — user-invoked grilling session.
- `grill-with-docs/` — user-invoked grilling session that also builds docs (ADRs, glossary).
- `tdd/` — model-invoked red-green-refactor test-driven development.

Resync with:

```sh
scripts/sync-matt-skills.sh                 # from upstream main
MATT_SKILLS_REF=<sha|tag|branch> scripts/sync-matt-skills.sh
```

## Design principles

- Keep standards in one place: `coding-standards/` owns the substantive rules.
- Keep workflow skills thin: review, spec, and architecture skills route to the standards instead of duplicating them.
- Prefer typed contracts, call stacks, interfaces, seams, and concrete evidence over vague architecture prose.
- Treat user-invoked workflows as deliberate modes; do not surprise-run heavy reviews/specs/refactors.

## Credits

Thanks to Matt Pocock for inspiration around writing high-quality agent skills, especially the `writing-great-skills` skill and its emphasis on predictable execution, progressive disclosure, context pointers, completion criteria, and pruning duplication.
