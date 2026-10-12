# The project tree

APS models one thing: what a coding agent needs around a repository, and where each piece lives. The model is a tree rooted at the person, with the project as the unit of design.

```
User                         a person; independent of host and harness
└─ Project                   key = repository name
   ├─ instruction            private instruction text, Markdown, one file, harness-independent
   ├─ env                    list of gitignored files every checkout needs; values live on the host
   ├─ build                  how to seed a build cache for a new checkout (optional)
   ├─ state                  where working state lives: a hosted document, never a checkout
   ├─ adapter[harness]       thin wiring: a stub that imports the instruction, a list of files to copy
   └─ checkout[n]            main + worktrees; each receives a fork of the above and owns nothing
```

## Why the project, not the worktree, is the unit

A worktree is a checkout. Its reason to exist is isolation of source changes, not a separate identity. If instructions, env or state could differ per worktree, every worktree would drift into its own small project and the drift would be invisible until it bit. The tree therefore puts everything that gives a project its identity directly under `Project`, once, and treats a checkout as a consumer that is given a copy.

## Why state is outside the checkout

Working notes, journals and design drafts that live in a gitignored directory inside a checkout are the two classic failure modes in one place: they leak (an agent quotes a path or a paragraph into a public file) and they scatter (each host, each worktree, each archive has a different copy). Keeping state in a hosted document the agent reaches over a network interface removes the file from the working tree, and with it both failure modes. The schema records only the URL.

## Why adapters carry no content

A harness changes. The project does not. If the instruction text sat inside a harness-specific file, moving to another harness would mean rewriting the text in the new format, and keeping two harnesses would mean keeping two copies. A stub that says "import that file" costs one line per harness and nothing to migrate.

## Invariants

1. `instruction`, `env`, `build`, `state` exist once per project and never per checkout.
2. An adapter is a stub plus a file list. No text, no defaults, no policy.
3. Host-specific data is limited to secret values and filesystem paths.
4. Nothing is placed in a checkout that `aps-wt-fork` cannot reproduce from the main checkout. If it cannot be forked, it is not part of the tree.
5. Every file an adapter writes is listed in the instance. Nothing is written that the instance does not name.

## Instance

One JSON file per project, validated by `schema/project.schema.json`. Instances hold paths and lists, not content. A private configuration repository keeps the instances next to the instruction files they point at; this repository keeps only the schema and the tools.

## What is deliberately not modelled

- Team-shared instructions committed to the repository (`CLAUDE.md`, `AGENTS.md`). They are part of the project's public surface and belong to the repository, not to this tree.
- Skills, commands and plugins. They are distributed by the harness's own packaging and are project-scoped by that packaging.
- Container definitions. A devcontainer describes a machine; APS describes what sits around a checkout on whatever machine you have.
