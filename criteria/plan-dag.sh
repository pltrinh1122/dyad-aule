#!/usr/bin/env bash
# Acceptance criteria for node N0 of plan/close-the-gaps.md — the plan artifact itself.
# Real-half of the PLAN'S SHAPE: the file exists in a registered kind-home, every NODE line
# parses, every dep resolves to a defined node, the graph is ACYCLIC, node state is DERIVED
# (no status field may ever appear — C3), operator decision-nodes carry DISPOSITION lines,
# and the plan contains itself as N0 (the dog-food property). Which nodes are the RIGHT nodes
# is the Operator's judgment, sealed by merging the plan.
# NB: this file parses a line-oriented format in bash — deliberately at the edge of the DR's
# C2 claim-shape. If the plan format grows structure beyond one-line fields, tripwire 5 fires
# (python3-stdlib hatch) — do not grow this parser instead.
here="$(cd "$(dirname "$0")" && pwd)"; repo="$(cd "$here/.." && pwd)"
source "$here/_lib.sh"
cd "$repo" || exit 1
PLAN="plan/close-the-gaps.md"

assert "plan exists in plan/ (the queue kind-home)"               test -f "$PLAN"
assert "kind-home plan/ registered in the README map"             grep -qF '| `plan/` |' README.md
assert "states the derivation rule (DONE from ground)"            grep -qF 'DONE ⟺' "$PLAN"
assert "derived-not-stored enforced: NO status field anywhere"    bash -c '! grep -qE "status=" "'"$PLAN"'"'
assert "contains itself: N0 is the plan-writing node"             bash -c 'grep -E "^NODE N0 " "'"$PLAN"'" | grep -qi "this plan"'
assert "N0 names THIS criteria file as its done-condition"        grep -qE '^NODE N0 deps=- done=plan-dag.sh' "$PLAN"
assert "WIP=1 stated (decouples time, not workers)"               grep -qiE 'WIP=1' "$PLAN"

# --- Every NODE line parses against the declared format. ---
fmt_ok() {
  ! grep -E '^NODE ' "$PLAN" | grep -vE '^NODE N[0-9]+ deps=(-|N[0-9]+(,N[0-9]+)*) done=[a-z0-9-]+(\.sh)? lane=(agent|operator|dyad) :: .+' | grep -q .
}
assert "every NODE line parses (id, deps, done, lane, title)"     fmt_ok

# --- Every dep resolves to a defined node id. ---
deps_resolve() {
  local ids id d
  ids=" $(grep -E '^NODE ' "$PLAN" | awk '{print $2}' | tr '\n' ' ') "
  while read -r d; do
    for id in $(printf '%s' "$d" | tr ',' ' '); do
      case "$ids" in *" $id "*) : ;; *) return 1 ;; esac
    done
  done < <(grep -E '^NODE ' "$PLAN" | awk '{sub(/^deps=/,"",$3); if ($3 != "-") print $3}')
  return 0
}
assert "every dep references a defined node"                      deps_resolve

# --- Acyclic: Kahn-style elimination — repeatedly remove nodes whose deps are all removed;
#     stuck before empty = a cycle. (Tiny DAG; stays in the shell claim-shape.) ---
acyclic() {
  local remaining id deps d blocked progress
  remaining=" $(grep -E '^NODE ' "$PLAN" | awk '{print $2}' | tr '\n' ' ') "
  progress=1
  while [ -n "${remaining// /}" ] && [ "$progress" = 1 ]; do
    progress=0
    for id in $remaining; do
      deps="$(grep -E "^NODE $id " "$PLAN" | awk '{sub(/^deps=/,"",$3); print $3}')"
      blocked=0
      if [ "$deps" != "-" ]; then
        for d in $(printf '%s' "$deps" | tr ',' ' '); do
          case "$remaining" in *" $d "*) blocked=1 ;; esac
        done
      fi
      if [ "$blocked" = 0 ]; then
        remaining="${remaining/ $id / }"
        progress=1
      fi
    done
  done
  [ -z "${remaining// /}" ]
}
assert "the DAG is acyclic (elimination reaches empty)"           acyclic

# --- Operator decision-nodes carry a DISPOSITION line to derive from. ---
dispositions_present() {
  local id
  while read -r id; do
    grep -qE "^DISPOSITION $id:" "$PLAN" || return 1
  done < <(grep -E '^NODE ' "$PLAN" | grep 'done=disposition' | awk '{print $2}')
  return 0
}
assert "every disposition-node has its DISPOSITION line"          dispositions_present

assert_done
