# Contributing

Thanks for looking. APS is small on purpose; the bar for adding to it is "does the tree need this?", not "would it be convenient?".

## Ground rules

- **The tree comes first.** `docs/tree.md` defines what a project is made of. The schema implements the tree; the scripts implement the schema. A proposal that adds a file to checkouts without a node in the tree will be declined.
- **Adapters are thin.** An adapter may write a stub that imports the instruction and a list of files to copy. It may not carry instruction text, defaults, or harness-specific policy.
- **No runtime beyond `sh` + `jq`.** If a feature needs more, it probably belongs in a separate tool that consumes APS instances.
- **Nothing private, ever.** No real paths to private services, no tokens, no instruction content. CI runs the smoke test; reviewers reject private values, since no pattern list can be published without leaking the names it guards.

## Workflow

1. Open an issue describing the change in terms of the tree (which node, which invariant).
2. Branch from `main`, make the change, run `just test`.
3. Update `docs/`, `schema/` and `CHANGELOG.md` in the same change.
4. Open a pull request. A maintainer reviews and merges; contributors do not push to `main`.

## Adding a harness adapter

1. Document the harness's behaviour with a link to its official documentation in `docs/adapters.md`: where it reads project instructions, whether it supports an import directive, how it treats gitignored files in worktrees.
2. Add the adapter key to `schema/project.schema.json` under `adapters`.
3. Implement the writer in `bin/aps-gen-adapter` and the fork rule in `bin/aps-wt-fork`.
4. Add a case to `tests/smoke.sh`.

Mark anything unverified as such in the docs. An adapter based on a guess is worse than no adapter.

## Commit messages

Imperative, one line, no trailers that name a tool or model. Example: `Add codex adapter stub writer`.
