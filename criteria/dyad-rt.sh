#!/usr/bin/env bash
# Acceptance criteria for dyad-rt — the Dyad Runtime (bin/_dyad-rt enforcer + .githooks floor +
# bin/git·bin/gh wrappers + bin/claude launcher). This is the real-half of the runtime: a guard
# that is asserted but not wired is counterfeit (the failure aule's dialectic/ pins on peers). So
# this file DRIVES the enforcer and asserts it both REFUSES main-mutations AND ALLOWS a working-
# branch push — a guard that denies everything proves nothing, so the positive control is load-bearing.
here="$(cd "$(dirname "$0")" && pwd)"; repo="$(cd "$here/.." && pwd)"
source "$here/_lib.sh"
cd "$repo" || exit 1
rt="$repo/bin/_dyad-rt"

# --- The enforcer fires: DENIES the forbidden mutations (exit nonzero). ---
assert "deny: commit on main"        bash -c '! "'"$rt"'" check-branch main'
assert "deny: commit on refs/heads/main" bash -c '! "'"$rt"'" check-branch refs/heads/main'
assert "deny: push to main"          bash -c '! "'"$rt"'" check-push main'
assert "deny: push to refs/heads/main"   bash -c '! "'"$rt"'" check-push refs/heads/main'
assert "deny: gh pr merge"           bash -c '! "'"$rt"'" check-gh pr merge 123'

# --- Positive controls: the guard ALLOWS legitimate work (exit 0). A deny-all guard is worthless. ---
assert "allow: commit on a working branch"  "$rt" check-branch craft/dyad-rt
assert "allow: push a working branch"        "$rt" check-push craft/dyad-rt
assert "allow: gh pr create"                 "$rt" check-gh pr create
assert "allow: gh pr view"                   "$rt" check-gh pr view 123
assert "single source: protected == main"    bash -c '[ "$("'"$rt"'" protected)" = "main" ]'

# --- The floor and wrappers exist, are committed executable (git 100755 — the O5/PR#6 lesson:
#     a working-tree +x bit can mask a 100644 in git that then fails on a fresh CI checkout),
#     and route through the single-home enforcer (not a private copy of the policy). ---
for s in bin/_dyad-rt bin/git bin/gh bin/claude .githooks/pre-commit .githooks/pre-push; do
  assert "committed executable (git 100755): $s" \
    bash -c '[ "$(git ls-files -s "'"$s"'" | cut -d" " -f1)" = "100755" ]'
done
# (tolerate the shell quoting between `dyad-rt"` and the subcommand, e.g. `"$root/bin/_dyad-rt" check-branch`).
assert "floor delegates to enforcer: pre-commit" grep -qE 'dyad-rt"? check-branch' .githooks/pre-commit
assert "floor delegates to enforcer: pre-push"   grep -qE 'dyad-rt"? check-push'   .githooks/pre-push
assert "wrapper delegates to enforcer: bin/git"  grep -qE 'dyad-rt"? check-(branch|push)' bin/git
assert "wrapper delegates to enforcer: bin/gh"    grep -qE 'dyad-rt"? check-gh' bin/gh

# --- bin/claude tells the truth: it wires the floor and names the real authority, and no longer
#     carries the false ".githooks + Covalent" claim it had NO mechanism for (fidelity fix). ---
assert "launcher wires the floor (core.hooksPath)" grep -qF 'core.hooksPath .githooks' bin/claude
assert "launcher names dyad-rt as authority"        grep -qF 'dyad-rt' bin/claude

assert_done
