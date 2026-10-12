# Agent instructions

This repository is public. Everything in it is readable by anyone, so:

- Never write a real hostname, user name, token, URL of a private service, or the content of any project's instruction file here. `examples/` holds placeholder values only.
- Keep the tree in `docs/tree.md` as the source of truth. A change to `schema/project.schema.json` must be reflected there in the same change.
- Scripts in `bin/` are POSIX `sh` with `jq` as the only runtime dependency. Do not add a language runtime.
- `tests/smoke.sh` must pass before a commit. Run `just test`.
- Pushing, releasing and opening pull requests are done by a human.

Read `CONTRIBUTING.md` and `PUBLIC_DEVELOPMENT.md` before changing anything.
