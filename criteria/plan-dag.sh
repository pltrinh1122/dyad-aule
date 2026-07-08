#!/usr/bin/env bash
# Acceptance criteria for node N0 — the plan artifact's SHAPE, now spread across self-contained
# per-node files (plan/<id>.md; the grain decision is N10, enforced by plan-grain.sh). Real-half:
# every NODE line parses, every dep resolves to a defined node, the graph is ACYCLIC, node state is
# DERIVED (no status field may ever appear — C3), operator decision-nodes carry DISPOSITION lines,
# and the plan contains itself as N0 (the dog-food property). Which nodes are the RIGHT nodes is the
# Operator's judgment, sealed by merging the plan. The plan-level contract lives in close-the-gaps.md.
# NB: this file parses a line-oriented format in bash — deliberately at the edge of the DR's C2
# claim-shape. If the plan format grows structure beyond one-line fields, tripwire 5 fires
# (python3-stdlib hatch) — do not grow this parser instead.
here="$(cd "$(dirname "$0")" && pwd)"; repo="$(cd "$here/.." && pwd)"
source "$here/_lib.sh"
cd "$repo" || exit 1
CONTRACT="plan/close-the-gaps.md"

# Union of NODE / DISPOSITION lines across every per-node file (-h drops filenames).
NODES="$(grep -hE '^NODE ' plan/*.md 2>/dev/null || true)"
DISPS="$(grep -hE '^DISPOSITION ' plan/*.md 2>/dev/null || true)"
node_lines() { printf '%s\n' "$NODES"; }

assert "plan node-home populated (plan/n0.md exists)"             test -f plan/n0.md
assert "plan-level contract exists (close-the-gaps.md)"          test -f "$CONTRACT"
assert "kind-home plan/ registered in the README map"            grep -qF '| `plan/` |' README.md
assert "contract states the derivation rule (DONE from ground)"  grep -qF 'DONE ⟺' "$CONTRACT"
assert "derived-not-stored enforced: NO status field anywhere"   bash -c '! grep -qE "status=" plan/*.md'
assert "contains itself: N0 is the plan-writing node"            bash -c 'grep -E "^NODE N0 " plan/n0.md | grep -qi "this plan"'
assert "N0 names THIS criteria file as its done-condition"       grep -qE '^NODE N0 deps=- done=plan-dag.sh' plan/n0.md
assert "WIP=1 stated (decouples time, not workers)"              grep -qiE 'WIP=1' "$CONTRACT"

# --- Every NODE line parses against the declared format. ---
fmt_ok() {
  ! node_lines | grep -E '^NODE ' | grep -vE '^NODE N[0-9]+ deps=(-|N[0-9]+(,N[0-9]+)*) done=[a-z0-9-]+(\.sh)? lane=(agent|operator|dyad) :: .+' | grep -q .
}
assert "every NODE line parses (id, deps, done, lane, title)"     fmt_ok

# --- Every dep resolves to a defined node id. ---
deps_resolve() {
  local ids id d
  ids=" $(node_lines | awk '{print $2}' | tr '\n' ' ') "
  while read -r d; do
    [ -z "$d" ] && continue
    for id in $(printf '%s' "$d" | tr ',' ' '); do
      case "$ids" in *" $id "*) : ;; *) return 1 ;; esac
    done
  done < <(node_lines | awk '{sub(/^deps=/,"",$3); if ($3 != "-") print $3}')
  return 0
}
assert "every dep references a defined node"                      deps_resolve

# --- Acyclic: Kahn-style elimination — repeatedly remove nodes whose deps are all removed;
#     stuck before empty = a cycle. (Tiny DAG; stays in the shell claim-shape.) ---
acyclic() {
  local remaining id deps d blocked progress
  remaining=" $(node_lines | awk '{print $2}' | tr '\n' ' ') "
  progress=1
  while [ -n "${remaining// /}" ] && [ "$progress" = 1 ]; do
    progress=0
    for id in $remaining; do
      deps="$(node_lines | awk -v i="$id" '$2==i{sub(/^deps=/,"",$3); print $3; exit}')"
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
    [ -z "$id" ] && continue
    printf '%s\n' "$DISPS" | grep -qE "^DISPOSITION $id:" || return 1
  done < <(node_lines | grep 'done=disposition' | awk '{print $2}')
  return 0
}
assert "every disposition-node has its DISPOSITION line"          dispositions_present
assert "contract records the issues-as-nodes decision (inbox)"    grep -qF 'Inbox, never truth' "$CONTRACT"

assert_done
