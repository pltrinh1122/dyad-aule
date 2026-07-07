#!/usr/bin/env bash
# Acceptance criteria for landing the DIP dimensions (#4/#7/#8 + #5 lived parts).
# Real half only — the *right* half (does the content match intent?) is the Operator's merge.
here="$(cd "$(dirname "$0")" && pwd)"; repo="$(cd "$here/.." && pwd)"
source "$here/_lib.sh"
dyad="$repo/DYAD.md"

# The four dimensions are landed as their own sections (not a single "Deferred" note).
assert "#4 Channel discipline landed"   grep -qF "### Channel discipline (#4)" "$dyad"
assert "#5 Operating-policy landed"      grep -qF "### Operating-policy (#5)"   "$dyad"
assert "#7 Ontology landed"              grep -qF "### Ontology (#7)"           "$dyad"
assert "#8 Vocabulary landed"            grep -qF "### Vocabulary (#8)"         "$dyad"

# #4 names all three hats as action-gates.
assert "#4 names Builder/Architect"      grep -qF "Builder/Architect"  "$dyad"
assert "#4 names Ratifier/Merge-gate"    grep -qF "Ratifier/Merge-gate" "$dyad"
assert "#4 names Commons steward"        grep -qF "Commons steward"    "$dyad"

# #5: concurrency-ceiling stays an honest defer; tooling-abstraction is now LANDED as dyad-rt
# (real friction set it — see op-runtime). The assert tracks reality, not a stale label.
assert "#5 keeps concurrency ceiling deferred"  grep -qE "concurrency ceiling.*Honest defer|deferred.*concurrency ceiling" "$dyad"
assert "#5 lands tooling-abstraction as dyad-rt" grep -qE "tooling-abstraction.*landed as dyad-rt" "$dyad"

# #8 canonicalizes the load-bearing terms.
assert "#8 defines real vs right"        grep -qF "the two grounds of fidelity" "$dyad"
assert "#8 defines spine"                grep -qF "elicit it before proposing form" "$dyad"

# The old placeholder framing is gone.
absent "no 'deliberately deferred' four-way note remains" "$dyad" "The rest are **deliberately deferred**"

assert_done
