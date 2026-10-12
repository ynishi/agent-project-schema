# agent-project-schema (APS)

A small, harness-independent schema for the per-project environment that coding agents need: where the project's private instructions live, which ignored files every checkout must carry, how a build cache is seeded, where working state is kept, and how each agent harness (Claude Code, Codex, ...) is wired in. One schema, one instance per project, thin adapters, nothing else scattered on disk.

APS exists because the alternative is what most of us have today: instruction files, `.env` copies, settings and worktree hacks sprinkled across repositories by whichever tool was fashionable that month, with no model of what belongs where. The tools keep changing; the tree does not.

## The tree

```
User                         a person; independent of host and harness
└─ Project                   key = repository name; the unit of design (a worktree is not)
   ├─ instruction            the project's private instruction text (Markdown, one file)
   ├─ env                    ignored files every checkout needs (.env, local settings, ...)
   ├─ build                  how to seed a build cache for a new checkout (optional)
   ├─ state                  where working state lives: hosted, never inside a checkout
   ├─ adapter[harness]       a thin wiring per harness (a one-line stub, an include list)
   └─ checkout[n]            main + worktrees; they receive a fork of the above, own nothing
```

Invariants:

1. `instruction`, `env`, `build` and `state` exist once per project, never per checkout.
2. An adapter carries no content: a stub that imports the instruction, a list of files to copy, nothing more.
3. Host-specific data is limited to secret values and paths.
4. Nothing goes into a checkout that a fork cannot reproduce. If it cannot be forked, it does not belong in the tree.

See [docs/tree.md](docs/tree.md) for the full model and [docs/adapters.md](docs/adapters.md) for what each harness adapter writes.

## What is in this repository

| path | what |
|---|---|
| `schema/project.schema.json` | JSON Schema for one project instance |
| `examples/project.json` | an example instance (placeholder values only) |
| `bin/aps-validate` | structural validation of an instance (`jq`) |
| `bin/aps-gen-adapter` | write the harness adapter files into a checkout |
| `bin/aps-wt-fork` | copy the forkable files from one checkout into a new worktree, then seed the build cache |
| `bin/aps-wt-check` | report what a worktree is missing (exit 2 when anything is) |
| `justfile` | the same four operations as recipes |
| `tests/smoke.sh` | end-to-end check in a temporary repository |

What is **not** here, by design: any project's instruction text, any instance with real values, any secret. Those stay in the owner's private configuration repository, which references this one (git submodule or vendoring). This repository has no place where a private value could land, which is the point.

## Usage

```sh
# validate an instance
bin/aps-validate path/to/example.json

# write the Claude Code adapter (stub + .worktreeinclude) into a checkout
bin/aps-gen-adapter path/to/example.json ~/projects/example

# after `git worktree add`, fork the environment into the new worktree
bin/aps-wt-fork path/to/example.json ~/projects/example ~/projects/example/.worktrees/feature-x

# before working in a worktree, confirm nothing is missing
bin/aps-wt-check path/to/example.json ~/projects/example/.worktrees/feature-x
```

Requirements: POSIX `sh`, `jq`, `git`. Optional: `just`.

## Status

Early. The Claude Code adapter is implemented and tested against the documented behaviour of `CLAUDE.md` imports and `.worktreeinclude`. The Codex adapter is a placeholder until its local-override file format is confirmed. See [CHANGELOG.md](CHANGELOG.md).

## License

Dual-licensed under MIT or Apache-2.0, at your option.
