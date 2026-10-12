# Public development

This repository is developed in the open from the first commit. This file says what that means in practice so that nothing private leaks and nothing public is a surprise.

## What is public

- The tree model, the schema, the scripts, the tests, this documentation.
- Issues and pull requests.
- The example instance in `examples/`, which uses placeholder values only.

## What is never here

- Any real project instance. Instances live in the owner's private configuration repository.
- Instruction text for any project.
- Secrets, tokens, private hostnames, private URLs, internal ticket identifiers, internal tool names.
- Session logs, working notes, drafts.

## How the private side references this repository

A private configuration repository either adds APS as a git submodule or vendors a tagged copy. It keeps its instances next to its instruction files and runs the APS scripts against them. The private repository never pushes anything back here except through a normal pull request that contains no private values.

## Boundaries that agents and humans both follow

| action | who |
|---|---|
| edit files, run tests, commit on a branch | agent or human |
| push, open or merge a pull request, tag a release | human |
| add a dependency beyond `sh` and `jq` | discussed in an issue first |

## Leak handling

If something private lands here, it is treated as published. The remedy is rotation of whatever was exposed and a history rewrite only when the maintainer decides it is worth it. Prevention is cheaper: keep private values out of the working tree in the first place, which is what this project is for.
