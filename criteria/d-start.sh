#!/usr/bin/env bash
# Acceptance criteria for bin/d-start — the Start Session Discipline (the `d-start` token's mechanism).
# Real-half only. Exercises d-start with DYAD_DSTART_DIAGNOSE_ONLY=1 so it is SIDE-EFFECT-FREE here:
# it dry-runs the reconcile (no fetch/push/switch/delete) and skips ./check (this file runs UNDER
# ./check — a live reconcile would switch branches mid-check, and calling ./check would recurse).
here="$(cd "$(dirname "$0")" && pwd)"; repo="$(cd "$here/.." && pwd)"
source "$here/_lib.sh"
cd "$repo"
ds="$repo/bin/d-start"

# Present + committed executable (git 100755 — the O5/PR#6 lesson: a working-tree +x can mask 100644).
assert "committed executable (git 100755): bin/d-start" \
  bash -c '[ "$(git ls-files -s bin/d-start | cut -d" " -f1)" = "100755" ]'

# It runs and emits each seam. (Exit code is intentionally NOT asserted — it reflects live seams
# like durability/sync that vary by environment; here we prove the STRUCTURE and the repair behave.)
out="$(DYAD_DSTART_DIAGNOSE_ONLY=1 "$ds" 2>&1 || true)"
has() { printf '%s\n' "$out" | grep -qE "$1"; }
assert "d-start emits Runtime seam"    has "Runtime *:"
assert "d-start emits Reconcile seam"  has "Reconcile *:"
assert "d-start emits Real-half seam"  has "Real *:"
assert "d-start emits Durable seam"    has "Durable *:"
assert "d-start certifies real, not right" has 'grounds \*real\*'

# The sanctioned auto-repair actually fires: unset core.hooksPath, run d-start, expect it restored.
saved="$(git config --get core.hooksPath 2>/dev/null || true)"
git config --unset core.hooksPath 2>/dev/null || true
DYAD_DSTART_DIAGNOSE_ONLY=1 "$ds" >/dev/null 2>&1 || true
assert "d-start auto-repairs core.hooksPath → .githooks" \
  bash -c '[ "$(git config --get core.hooksPath 2>/dev/null)" = ".githooks" ]'
# restore prior config (net state ends at .githooks either way; be a good citizen)
if [ -n "$saved" ]; then git config core.hooksPath "$saved"; fi

# The token is documented in the anchor so a fresh agent knows to run it.
assert "DYAD.md documents the d-start token" grep -qF "d-start" "$repo/DYAD.md"

assert_done
