#!/bin/sh
# End-to-end check in a scratch git repository under <repo>/.smoke/ (not a
# tmpfs; build caches and worktrees must never go to RAM-backed temp dirs).
# Needs git and jq.
set -eu
here=$(cd "$(dirname "$0")/.." && pwd -P)
scratch="$here/.smoke"
rm -rf "$scratch"; mkdir -p "$scratch"
trap 'rm -rf "$scratch"' EXIT
fail() { echo "smoke: FAIL: $*" >&2; exit 1; }

# 1. a repository that ignores .claude, .env and .mcp.json, with one commit
repo="$scratch/repo"; mkdir -p "$repo"; cd "$repo"
git init -q; git config user.email a@b.c; git config user.name smoke
printf '.claude\n.env\n.mcp.json\n.worktrees\n' > .gitignore
echo hello > README.md; git add -A; git commit -qm init
printf 'SECRET=1\n' > .env

# 2. an instance whose build seed just creates the artifact
inst="$scratch/example.json"
cat > "$inst" <<JSON
{ "project": "smoke", "instruction": "~/agent-instructions/smoke.md",
  "env": [".env", ".mcp.json"],
  "build": { "seed": "mkdir -p {worktree}/target && touch {worktree}/target/seeded", "artifact": "target" },
  "adapters": { "claude-code": { "stub": ".claude/CLAUDE.md" } } }
JSON
"$here/bin/aps-validate" "$inst" || fail validate

# 3. adapter generation
"$here/bin/aps-gen-adapter" "$inst" "$repo" || fail gen-adapter
[ "$(cat "$repo/.claude/CLAUDE.md")" = "@~/agent-instructions/smoke.md" ] || fail "stub content"
grep -qx '.env' "$repo/.worktreeinclude" || fail ".worktreeinclude lacks .env"
grep -qx '.claude/CLAUDE.md' "$repo/.worktreeinclude" || fail ".worktreeinclude lacks stub"
[ -z "$(git -C "$repo" status --porcelain .claude)" ] || fail "stub became visible to git"

# 4. refusal when the stub would be tracked
repo2="$scratch/repo2"; mkdir -p "$repo2"; cd "$repo2"; git init -q; git config user.email a@b.c; git config user.name smoke
echo x > README.md; git add -A; git commit -qm init
if "$here/bin/aps-gen-adapter" "$inst" "$repo2" 2>/dev/null; then fail "gen-adapter should refuse an unignored stub"; fi

# 5. a plain worktree lacks everything; fork fills it; check passes
cd "$repo"; wt="$repo/.worktrees/feature"; mkdir -p "$repo/.worktrees"
git worktree add -q "$wt" -b feature
if "$here/bin/aps-wt-check" "$inst" "$wt" >/dev/null 2>&1; then fail "wt-check should report missing files before fork"; fi
"$here/bin/aps-wt-fork" "$inst" "$repo" "$wt" || fail wt-fork
[ -f "$wt/.env" ] && [ -f "$wt/.claude/CLAUDE.md" ] && [ -f "$wt/target/seeded" ] || fail "fork did not place files"
# .mcp.json is absent in the main checkout, so it is skipped by the fork and
# still reported missing: the check must say so and exit 2
if "$here/bin/aps-wt-check" "$inst" "$wt" >/dev/null 2>&1; then fail "wt-check should still report the absent .mcp.json"; fi
printf '{}\n' > "$repo/.mcp.json"
"$here/bin/aps-wt-fork" "$inst" "$repo" "$wt" >/dev/null || fail "second fork"
"$here/bin/aps-wt-check" "$inst" "$wt" || fail "wt-check after complete fork"
echo "smoke: ok"
