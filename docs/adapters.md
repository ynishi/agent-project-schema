# Adapters

An adapter is the thin, harness-specific wiring that connects a checkout to the project's instruction and env. `aps-gen-adapter` writes it; `aps-wt-fork` copies it into new worktrees; `aps-wt-check` verifies it.

## Claude Code

Status: implemented.

Behaviour this adapter relies on, as documented by Anthropic in October 2026. Each item links to the page it was read from; if a page changes, the item is the thing to re-check.

- Claude Code reads `.claude/CLAUDE.md` in a checkout as project memory ([memory](https://code.claude.com/docs/en/memory)).
- A memory file may import another file with a line of the form `@~/path/to/file.md`. An import that points outside the working directory asks for approval once per project; a refusal is remembered and the dialog does not return ([memory](https://code.claude.com/docs/en/memory)).
- A gitignored `CLAUDE.local.md` exists only in the worktree where it was created; the documentation recommends importing a file from the home directory instead ([memory](https://code.claude.com/docs/en/memory)).
- When Claude Code creates a worktree it checks out tracked files only. A `.worktreeinclude` file at the repository root lists patterns; files that match a pattern **and are gitignored** are copied into the new worktree ([worktrees](https://code.claude.com/docs/en/worktrees)).
- A worktree created from a shell with the plain git command bypasses both `.worktreeinclude` and the worktree hooks ([worktrees](https://code.claude.com/docs/en/worktrees)).
- Approvals recorded with "don't ask again" inside a worktree are stored in the main checkout's `.claude/settings.local.json` and apply to every worktree of that repository ([worktrees](https://code.claude.com/docs/en/worktrees)).
- The settings `worktree.location` (where worktrees are created) and `worktree.baseRef` (`fresh` = the default branch on origin, `head` = the current local HEAD) are listed in the [settings reference](https://code.claude.com/docs/en/settings-reference#worktree).

What `aps-gen-adapter` writes:

| file | content |
|---|---|
| `<stub>` (default `.claude/CLAUDE.md`) | one line: `@<instruction>` |
| `.worktreeinclude` | the `env` list plus the stub path |

The stub must be gitignored by the project. `aps-gen-adapter` refuses to write a stub that git would track.

Unverified, and therefore not relied on: whether `.worktreeinclude` copies files under `.claude/`, and whether a checkout containing `.claude/CLAUDE.md` suppresses `AGENTS.md` the way `CLAUDE.local.md` does. Both are open questions; `aps-wt-fork` covers the first regardless, because it copies the stub itself.

Settings that are not files: `worktree.location` and `worktree.baseRef` are recorded in the instance for reference. `aps-gen-adapter` does not write Claude Code settings; that stays with the user's settings management.

## Build seed (any harness)

`build.seed` is an arbitrary command run from the main checkout with `{worktree}` substituted. The example instance uses [`cargo-shared-target`](https://crates.io/crates/cargo-shared-target), a published cargo subcommand that seeds a new `target/` from an existing one by sharing storage where the filesystem allows it. It is an example, not a dependency; a plain copy works too, it is just slower and larger.

## Codex

Status: placeholder. The instance may declare `adapters.codex.stub`, but `aps-gen-adapter` writes nothing for it and says so. The writer will be enabled once the local-override file format (`AGENTS.override.md` is the candidate) and its import behaviour are confirmed against official documentation.

## Adding an adapter

See CONTRIBUTING.md. The short version: document the harness behaviour with links first, then the schema key, then the writer, then a test case.
