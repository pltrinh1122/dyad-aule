#!/usr/bin/env bash
# Acceptance criteria for node N10 — the plan's GRAIN: the plan is a collection of self-contained
# per-node files (plan/<id>.md), not a monolith. This is the real-half of the decomposition
# decision recorded in plan/n10.md; it lands WITH the mechanism (the N8 no-asserted-but-unwired
# rule). DAG topology/acyclicity stays in plan-dag.sh; this file governs the file grain only.
here="$(cd "$(dirname "$0")" && pwd)"; repo="$(cd "$here/.." && pwd)"
source "$here/_lib.sh"
cd "$repo" || exit 1
CONTRACT="plan/close-the-gaps.md"

# The contract/index file is meta, not a node — it must hold ZERO NODE lines.
assert "contract file holds no NODE lines (it is meta, not a node)" \
  bash -c '! grep -qE "^NODE " "'"$CONTRACT"'"'

# Every OTHER plan/*.md is a self-contained node file: exactly one NODE line, basename == its id.
grain_ok() {
  local f base n id lid
  for f in plan/*.md; do
    [ "$f" = "$CONTRACT" ] && continue
    n="$(grep -cE '^NODE ' "$f")"
    [ "$n" = 1 ] || { echo "  ($f has $n NODE lines, want exactly 1)"; return 1; }
    id="$(grep -E '^NODE ' "$f" | awk '{print $2}')"
    base="$(basename "$f" .md)"
    # basename matches the node id, case-insensitive (plan/n9.md <-> NODE N9)
    lid="$(printf '%s' "$id" | tr '[:upper:]' '[:lower:]')"
    [ "$base" = "$lid" ] || { echo "  ($f basename '$base' != node id '$id')"; return 1; }
  done
  return 0
}
assert "each plan/<id>.md holds exactly one NODE, basename == id"  grain_ok

# At least the ten readiness nodes + the grain node exist as files.
assert "the node files are present (>=11 plan/<id>.md)" \
  bash -c '[ "$(ls plan/n*.md 2>/dev/null | wc -l)" -ge 11 ]'

# A disposition node's DISPOSITION line lives in ITS OWN file (self-containment).
disp_colocated() {
  local f id
  for f in plan/*.md; do
    [ "$f" = "$CONTRACT" ] && continue
    grep -qE '^NODE .* done=disposition ' "$f" || continue
    id="$(grep -E '^NODE ' "$f" | awk '{print $2}')"
    grep -qE "^DISPOSITION $id:" "$f" || { echo "  ($id: DISPOSITION line not in $f)"; return 1; }
  done
  return 0
}
assert "each disposition node carries its DISPOSITION line in-file" disp_colocated

# The decomposition decision is recorded (self-contained in the node that enacted it).
assert "grain decision recorded in plan/n10.md"                    grep -qF 'Why per-node files' plan/n10.md

# The derived DAG index is a tool, not a stored table (ethos: derive the view).
assert "derived DAG index tool present and executable"             test -x bin/_frontier

assert_done
