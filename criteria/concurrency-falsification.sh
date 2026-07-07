#!/usr/bin/env bash
# Acceptance criteria for the concurrency-FSM falsifiable report + DMs.
# Real half: correct DM addressing (a mis-addressed DM lands in the wrong mailbox) +
# the report is actually falsifiable (has falsification targets) + meld confound declared.
here="$(cd "$(dirname "$0")" && pwd)"; repo="$(cd "$here/.." && pwd)"
source "$here/_lib.sh"

report="$repo/dialectic/2026-07-06-concurrency-fsm-evaluation.md"
cairn="$repo/dm/dyad-cairn/2026-07-06-derive-from-ground-survives.md"
wuwei="$repo/dm/dyad-wu-wei/2026-07-06-stored-state-as-truth-drifts.md"

# Report is a real falsifiable report: >=3 falsification targets + the claims.
assert "report exists"                     test -f "$report"
assert "report states >=3 falsification targets" \
  bash -c "test \$(grep -c 'falsification_target' '$report') -ge 3"
assert "report declares the same-human/same-model meld" grep -qF "1/3 partial independence" "$report"

# Cairn DM: correctly addressed FROM aule TO cairn, carries FALSE (survived) verdict.
assert "cairn DM: from dyad-aule"          grep -qF "from: dyad-aule" "$cairn"
assert "cairn DM: to dyad-cairn"           grep -qF "to: dyad-cairn"  "$cairn"
assert "cairn DM: carries FALSIFIED=FALSE" grep -qF "FALSIFIED = FALSE" "$cairn"
assert "cairn DM: declares §J meld"        grep -qF "partial independence" "$cairn"

# Wu-wei DM: correctly addressed FROM aule TO wu-wei, carries TRUE (refuted) verdict.
assert "wuwei DM: from dyad-aule"          grep -qF "from: dyad-aule"  "$wuwei"
assert "wuwei DM: to dyad-wu-wei"          grep -qF "to: dyad-wu-wei"  "$wuwei"
assert "wuwei DM: carries FALSIFIED=TRUE"  grep -qF "FALSIFIED = TRUE" "$wuwei"
assert "wuwei DM: declares §J meld"        grep -qF "partial independence" "$wuwei"

# Anti-misdelivery: the recipient dir must match the 'to:' field (no crossed wires).
assert "cairn DM sits under dm/dyad-cairn/"  bash -c "grep -qF 'to: dyad-cairn'  '$cairn'"
assert "wuwei DM sits under dm/dyad-wu-wei/"  bash -c "grep -qF 'to: dyad-wu-wei' '$wuwei'"

assert_done
