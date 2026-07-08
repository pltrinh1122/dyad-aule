#!/usr/bin/env bash
# Acceptance criteria for bin/_frontier — deriving the board from the plan-cache (post issues-as-home
# flip, N11/N16). Node state is the STORED status:* lane, read from .dyad-state/plan-cache/. Behavior
# is proven in a THROWAWAY fixture (bare origin + work clone, file:// — no network) exercising the
# actionable-vs-shown rule; the real repo is asserted only on side-effect-freeness (it only prints).
here="$(cd "$(dirname "$0")" && pwd)"; repo="$(cd "$here/.." && pwd)"
source "$here/_lib.sh"
cd "$repo" || exit 1
FRONTIER="$repo/bin/_frontier"

assert "committed executable (git 100755): bin/_frontier" \
  bash -c '[ "$(git ls-files -s bin/_frontier | cut -d" " -f1)" = "100755" ]'

# Fixture: a cache with one node in each lane.
_mkfix() {
  local d; d="$(mktemp -d)"
  git init -q --bare "$d/origin.git"
  git init -q "$d/work"
  git -C "$d/work" config user.email t@t.local
  git -C "$d/work" config user.name test
  git -C "$d/work" config commit.gpgsign false
  mkdir -p "$d/work/.dyad-state/plan-cache"
  printf 'CACHE-NODE #1 status=clarify deps=- done=a.sh :: needs sense\n'   >"$d/work/.dyad-state/plan-cache/1.md"
  printf 'CACHE-NODE #2 status=dispose deps=#1 done=b.sh :: needs land\n'   >"$d/work/.dyad-state/plan-cache/2.md"
  printf 'CACHE-NODE #3 status=blocked deps=#2 done=c.sh :: waiting\n'      >"$d/work/.dyad-state/plan-cache/3.md"
  printf 'CACHE-NODE #4 status=execute deps=- done=d.sh :: in flight\n'     >"$d/work/.dyad-state/plan-cache/4.md"
  git -C "$d/work" add -A
  git -C "$d/work" commit -q -m fixture
  git -C "$d/work" branch -M main
  git -C "$d/work" remote add origin "$d/origin.git"
  git -C "$d/work" push -q -u origin main
  echo "$d"
}

d="$(_mkfix)"; w="$d/work"
allout="$( cd "$w" && "$FRONTIER" --all --ref origin/main )"
front="$(  cd "$w" && "$FRONTIER" --ref origin/main )"
rm -rf "$d"
has_all()  { printf '%s\n' "$allout" | grep -qE "$1"; }
has_front(){ printf '%s\n' "$front"  | grep -qE "$1"; }
no_front() { ! printf '%s\n' "$front" | grep -qE "$1"; }

assert "--all shows every cached node (>=4 rows)" bash -c '[ "$(printf "%s\n" "'"$allout"'" | grep -cE "^#[0-9]+ ")" -ge 4 ]'
assert "--all shows the stored status lane"       has_all '^#1 +clarify'
assert "frontier lists clarify (needs d-sense)"   has_front '^#1 +clarify'
assert "frontier lists dispose (needs d-land)"    has_front '^#2 +dispose'
assert "frontier omits blocked"                   no_front '^#3 '
assert "frontier omits execute (in flight)"       no_front '^#4 '

# Real repo — side-effect-free: _frontier only prints (nothing here mutates dyad-aule); runs clean.
assert "real: _frontier runs clean (exit 0)"      bash -c '"'"$FRONTIER"'" --all >/dev/null 2>&1'

# The d-start seam: surfaced in the session report (diagnose-only run — side-effect-free).
assert "d-start surfaces the Plan seam"           bash -c 'DYAD_DSTART_DIAGNOSE_ONLY=1 ./bin/d-start 2>&1 | grep -q "^Plan"'

assert_done
