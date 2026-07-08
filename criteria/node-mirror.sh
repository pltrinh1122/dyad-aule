#!/usr/bin/env bash
# Acceptance criteria for plan node N9 — bin/_board (the Activity Board mirror engine).
# The fidelity-bearing logic (column derivation + reconciliation incl. DRIFT) is PURE and proven
# here in a THROWAWAY fixture (bare origin + work clone, file:// — no network), exactly as N1's
# frontier is. Live GitHub I/O lives only in `_board sync` (CI glue) and is deliberately NOT
# exercised here — instead we PROVE the pure paths never need the network (they run green with a
# failing `gh` shadowing the PATH). A view-never-a-writer is thus structural, not asserted.
here="$(cd "$(dirname "$0")" && pwd)"; repo="$(cd "$here/.." && pwd)"
source "$here/_lib.sh"
cd "$repo" || exit 1
BOARD="$repo/bin/_board"

assert "committed executable (git 100755): bin/_board" \
  bash -c '[ "$(git ls-files -s bin/_board | cut -d" " -f1)" = "100755" ]'

# Fixture: five nodes covering every derived state (same shape as frontier's), + a failing `gh`
# stub on PATH to prove the pure engine is network-free.
_mkfix() {
  local d; d="$(mktemp -d)"
  git init -q --bare "$d/origin.git"
  git init -q "$d/work"
  git -C "$d/work" config user.email t@t.local
  git -C "$d/work" config user.name test
  git -C "$d/work" config commit.gpgsign false
  mkdir -p "$d/work/plan" "$d/work/criteria" "$d/nogh"
  cat >"$d/work/plan/p.md" <<'EOF'
NODE A deps=- done=a.sh lane=agent :: alpha done by criteria
NODE B deps=A done=b.sh lane=agent :: bravo ready
NODE C deps=B done=c.sh lane=agent :: charlie blocked
NODE D deps=A done=disposition lane=operator :: delta awaiting operator
NODE E deps=- done=disposition lane=operator :: echo decided

DISPOSITION D: TODO
DISPOSITION E: chosen-path
EOF
  printf '%s\n' 'true' >"$d/work/criteria/a.sh"
  git -C "$d/work" add -A
  git -C "$d/work" commit -q -m fixture
  git -C "$d/work" branch -M main
  git -C "$d/work" remote add origin "$d/origin.git"
  git -C "$d/work" push -q -u origin main
  # a `gh` that fails loudly if the pure paths ever call it
  printf '#!/bin/sh\necho "PURE-PATH-CALLED-GH" >&2; exit 99\n' >"$d/nogh/gh"
  chmod +x "$d/nogh/gh"
  echo "$d"
}

d="$(_mkfix)"; w="$d/work"
# manifest, run from the work clone with the failing gh shadowing PATH (proves network-free).
man="$( cd "$w" && PATH="$d/nogh:$PATH" "$BOARD" manifest --ref origin/main 2>/dev/null )"
manwip="$( cd "$w" && "$BOARD" manifest --ref origin/main --in-progress "B" 2>/dev/null )"
manseam="$( cd "$w" && "$BOARD" manifest --ref origin/main --in-progress "B,C" 2>/dev/null )"
hasm() { printf '%s\n' "$man" | grep -qE "$1"; }

assert "manifest: DONE node → done column, closed"          hasm '^MIRROR A col=done open=no'
assert "manifest: READY node → ready column, open"          hasm '^MIRROR B col=ready open=yes'
assert "manifest: BLOCKED node → blocked column, open"      hasm '^MIRROR C col=blocked open=yes'
assert "manifest: AWAITING-OPERATOR → awaiting-operator"    hasm '^MIRROR D col=awaiting-operator open=yes'
assert "manifest: decided disposition → done, closed"       hasm '^MIRROR E col=done open=no'
assert "pure manifest never called gh (network-free view)"  bash -c '! printf "%s" "'"$man"'" | grep -q PURE-PATH-CALLED-GH'
assert "manifest: in-progress override wins over ready"     bash -c 'printf "%s\n" "'"$manwip"'" | grep -qE "^MIRROR B col=in-progress"'
assert "manifest: >1 in-progress surfaces a WIP=1 SEAM"     bash -c 'printf "%s\n" "'"$manseam"'" | grep -q "^SEAM wip>1:"'

# plan-ops reconciliation: feed a current issue set exercising every op + a no-op.
cur="$d/cur.tsv"
printf 'A\t1\topen\tboard:done\n'      >"$cur"   # derived Done but OPEN  → CLOSE (label ok)
printf 'B\t2\topen\tboard:blocked\n'  >>"$cur"   # derived ready, wrong label → RELABEL
printf 'C\t3\tclosed\tboard:blocked\n'>>"$cur"   # hand-closed non-Done  → REOPEN + DRIFT
printf 'E\t5\tclosed\tboard:done\n'   >>"$cur"   # derived Done + closed → NO-OP
printf 'Z\t9\topen\tboard:ready\n'    >>"$cur"   # node not in plan     → ORPHAN
ops="$( cd "$w" && PATH="$d/nogh:$PATH" "$BOARD" plan-ops --ref origin/main --current "$cur" 2>/dev/null )"
haso() { printf '%s\n' "$ops" | grep -qE "$1"; }
noo()  { ! printf '%s\n' "$ops" | grep -qE "$1"; }

assert "plan-ops: absent node → CREATE"                     haso '^CREATE D '
assert "plan-ops: derived-Done-but-open → CLOSE"            haso '^CLOSE A #1'
assert "plan-ops: wrong column label → RELABEL"             haso '^RELABEL B #2 board:blocked→board:ready'
assert "plan-ops: hand-closed non-Done → REOPEN"            haso '^REOPEN C #3'
assert "plan-ops: hand-closed non-Done → DRIFT surfaced"    haso '^DRIFT C #3 '
assert "plan-ops: node dropped from plan → ORPHAN surfaced" haso '^ORPHAN Z #9 '
assert "plan-ops: correct issue (E) → no op emitted"        noo '(CREATE|CLOSE|RELABEL|REOPEN|DRIFT) E'
assert "pure plan-ops never called gh (network-free)"       noo 'PURE-PATH-CALLED-GH'
rm -rf "$d"

# --- Wiring: CI board workflow exists and runs the sync; sync stays a one-way view. ---
assert "CI board workflow present"                          bash -c 'ls "'"$repo"'/.github/workflows/board.yml" >/dev/null 2>&1'
assert "board workflow runs _board sync"                    grep -qE '_board sync' "$repo/.github/workflows/board.yml"
assert "board is one-way (no gh pr merge / plan writes)"    bash -c '! grep -qE "gh (pr merge|issue transfer)|>> ?plan/" "'"$repo"'/bin/_board"'
assert "sync documents the Operator PAT setup step"         grep -qF 'project' "$repo/bin/_board"

assert_done
