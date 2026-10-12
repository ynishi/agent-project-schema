# agent-project-schema recipes. Each wraps one script in bin/.

set shell := ["sh", "-eu", "-c"]

default:
    @just --list

# Validate an instance file
validate instance:
    bin/aps-validate {{instance}}

# Write the harness adapter files (stub + .worktreeinclude) into a checkout
gen-adapter instance checkout:
    bin/aps-gen-adapter {{instance}} {{checkout}}

# Fork env + stubs from the main checkout into a worktree, then seed the build cache
wt-fork instance main worktree:
    bin/aps-wt-fork {{instance}} {{main}} {{worktree}}

# Report what a worktree is missing (exit 2 when anything is)
wt-check instance worktree:
    bin/aps-wt-check {{instance}} {{worktree}}

# Run the smoke test (creates a scratch repository under .smoke/, removed afterwards)
test:
    sh tests/smoke.sh
