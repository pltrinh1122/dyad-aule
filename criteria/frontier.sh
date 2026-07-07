#!/usr/bin/env bash
# Acceptance criteria for plan node N1 — bin/_frontier (derive node state from ground) and the
# d-start Plan seam. Behavior is proven in a THROWAWAY fixture (bare origin + work clone, all
# file:// — no network) exercising every derivation rule of the queue's contract; the real repo
# is asserted only on facts stable for all time (N0 is DONE forever; the tool runs clean).
# Surfaced-never-executed is structural: _frontier only prints; nothing here mutates dyad-aule.
here="$(cd "$(dirname "$0")" && pwd)"; repo="$(cd "$here/.." && pwd)"
source "$here/_lib.sh"
cd "$repo" || exit 1
FRONTIER="$repo/bin/_frontier"

assert "committed executable (git 100755): bin/_frontier" \
  bash -c '[ "$(git ls-files -s bin/_frontier | cut -d" " -f1)" = "100755" ]'

# Fixture: five nodes covering every rule — criteria-DONE, READY, dep-BLOCKED,
# disposition-TODO (awaiting operator), disposition-decided (DONE).
_mkfix() {
  local d; d="$(mktemp -d)"
  git init -q --bare "$d/origin.git"
  git init -q "$d/work"
  git -C "$d/work" config user.email t@t.local
  git -C "$d/work" config user.name test
  git -C "$d/work" config commit.gpgsign false
  mkdir -p "$d/work/plan" "$d/work/criteria"
  cat >"$d/work/plan/p.md" <<'EOF'
NODE A deps=- done=a.sh lane=agent :: done by criteria on main
NODE B deps=A done=b.sh lane=agent :: ready (dep done, own criteria absent)
NODE C deps=B done=c.sh lane=agent :: blocked (dep not done)
NODE D deps=A done=disposition lane=operator :: awaiting the operator
NODE E deps=- done=disposition lane=operator :: decided

DISPOSITION D: TODO
DISPOSITION E: chosen-path
EOF
  printf '%s\n' 'true' >"$d/work/criteria/a.sh"
  git -C "$d/work" add -A
  git -C "$d/work" commit -q -m fixture
  git -C "$d/work" branch -M main
  git -C "$d/work" remote add origin "$d/origin.git"
  git -C "$d/work" push -q -u origin main
  echo "$d"
}

d="$(_mkfix)"; w="$d/work"
allout="$( cd "$w" && "$FRONTIER" --all )"
front="$(  cd "$w" && "$FRONTIER" )"
rm -rf "$d"
has_all()  { printf '%s\n' "$allout" | grep -qE "$1"; }
has_front(){ printf '%s\n' "$front"  | grep -qE "$1"; }
no_front() { ! printf '%s\n' "$front" | grep -qE "$1"; }

assert "derives DONE from criteria-on-main"            has_all '^A +DONE'
assert "derives READY when deps are DONE"              has_all '^B +READY'
assert "derives BLOCKED when a dep is not DONE"        has_all '^C +BLOCKED'
assert "derives AWAITING-OPERATOR from TODO"           has_all '^D +AWAITING-OPERATOR'
assert "derives DONE from a non-TODO disposition"      has_all '^E +DONE'
assert "frontier lists the ready node"                 has_front '^B '
assert "frontier lists the awaiting decision"          has_front '^D '
assert "frontier omits DONE nodes"                     no_front '^(A|E) '
assert "frontier omits BLOCKED nodes"                  no_front '^C '

# Real repo — stable-for-all-time facts only (never assert states that later nodes will change).
realout="$("$FRONTIER" --all 2>&1)"
has_real() { printf '%s\n' "$realout" | grep -qE "$1"; }
real_rows(){ [ "$(printf '%s\n' "$realout" | grep -cE '^N[0-9]+ ')" -ge 10 ]; }
assert "real plan: runs clean and derives N0 DONE"     has_real '^N0 +DONE'
assert "real plan: every node derived (>=10 rows)"     real_rows

# The d-start seam: surfaced in the session report (diagnose-only run — side-effect-free).
assert "d-start surfaces the Plan seam"                bash -c 'DYAD_DSTART_DIAGNOSE_ONLY=1 ./bin/d-start 2>&1 | grep -q "^Plan"'

assert_done
