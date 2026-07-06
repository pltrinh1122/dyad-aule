#!/usr/bin/env bash
# Acceptance criteria for the "DIP outstanding tasks" pass (branch craft/dip-outstanding).
# Written once; re-runnable forever. This is the real-half check grounding its own change.
here="$(cd "$(dirname "$0")" && pwd)"; repo="$(cd "$here/.." && pwd)"
source "$here/_lib.sh"

dyad="$repo/DYAD.md"
yaml="$repo/commons/directory/dyad-aule.yaml"

# 1. The real-half check mechanism itself exists and is wired.
assert "check runner exists and is executable"   test -x "$repo/check"
assert "criteria bucket has a convention doc"     test -f "$here/README.md"

# 2. The craft_invariant TODO is discharged (no un-wired real-half TODO left).
absent "no un-wired real-half TODO in DYAD.md"    "$dyad" "TODO: wire the real-half check"

# 3. DYAD.md's remote precondition reflects the now-live remote.
absent "DYAD.md no longer claims the remote unwired"  "$dyad" "None is wired yet"
assert "DYAD.md records the live remote"          grep -qF "The remote is live" "$dyad"

# 4. The deferred DIP dimensions are annotated honestly (not silent).
assert "DYAD.md marks the deferred DIP dimensions" grep -qF "Deferred DIP dimensions" "$dyad"
assert "operator hats (#4) captured"              grep -qF "Commons steward" "$dyad"

# 5. The directory entry carries real summits, no placeholder.
absent "no placeholder summit remains"            "$yaml" "TODO: replace with your"

assert_done
