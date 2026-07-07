#!/usr/bin/env bash
# Acceptance criteria for the dyad-rt FLOOR, fired END-TO-END through real git.
# criteria/dyad-rt.sh drives bin/_dyad-rt directly (unit level) and greps that the hooks
# delegate — but a grep never proves the floor FIRES. This file closes that seam: each
# scenario builds a throwaway repo (bare origin + work clone, all file:// — no network),
# points its core.hooksPath at THIS repo's real .githooks (absolute path — so the hooks'
# own root-resolution finds the real bin/_dyad-rt, no copies), and drives real `git
# commit`/`git push` against it. Deny AND allow are both asserted — a guard that denies
# everything proves nothing — plus the documented --no-verify escape (a floor whose escape
# hatch is painted shut is a different guard than the one DYAD.md documents).
# Nothing here touches the actual dyad-aule repo — every scenario runs inside its own
# mktemp fixture with cwd set to it.
here="$(cd "$(dirname "$0")" && pwd)"; repo="$(cd "$here/.." && pwd)"
source "$here/_lib.sh"
HOOKS="$repo/.githooks"
GITW="$repo/bin/git"
GHW="$repo/bin/gh"

# Build a work repo on 'main' (pushed to a bare origin) with the REAL floor wired.
_mkfix() {
  local d; d="$(mktemp -d)"
  git init -q --bare "$d/origin.git"
  git init -q "$d/work"
  git -C "$d/work" config user.email t@t.local
  git -C "$d/work" config user.name test
  git -C "$d/work" config commit.gpgsign false
  git -C "$d/work" commit -q --allow-empty -m init
  git -C "$d/work" branch -M main
  git -C "$d/work" remote add origin "$d/origin.git"
  git -C "$d/work" push -q -u origin main
  git -C "$d/work" config core.hooksPath "$HOOKS"   # the real floor, not a copy
  echo "$d"
}

# 1. Raw `git commit` on main → the pre-commit floor refuses; no commit lands.
scen_commit_main_denied() {
  local d w before after rc; d="$(_mkfix)"; w="$d/work"
  before="$(git -C "$w" rev-parse HEAD)"
  ( cd "$w" && git commit --allow-empty -m nope ) >/dev/null 2>&1; rc=$?
  after="$(git -C "$w" rev-parse HEAD)"
  rm -rf "$d"
  [ "$rc" != 0 ] && [ "$before" = "$after" ]
}

# 2. Raw `git commit` on a working branch → allowed (positive control).
scen_commit_branch_allowed() {
  local d w rc; d="$(_mkfix)"; w="$d/work"
  git -C "$w" switch -q -c craft/work
  ( cd "$w" && git commit --allow-empty -m ok ) >/dev/null 2>&1; rc=$?
  rm -rf "$d"
  [ "$rc" = 0 ]
}

# 3. Raw `git push` of a working branch → allowed; origin receives it (positive control).
scen_push_branch_allowed() {
  local d w on; d="$(_mkfix)"; w="$d/work"
  git -C "$w" switch -q -c craft/work
  ( cd "$w" && git commit --allow-empty --no-verify -m ok && git push -q -u origin craft/work ) >/dev/null 2>&1
  git -C "$w" ls-remote --heads origin craft/work 2>/dev/null | grep -q craft/work && on=1 || on=0
  rm -rf "$d"
  [ "$on" = 1 ]
}

# 4. Refspec push HEAD:main from a working branch → pre-push floor refuses (this is the
#    exact case bin/git's early check cannot see; the floor is the backstop).
scen_refspec_push_main_denied() {
  local d w rc lc rc2; d="$(_mkfix)"; w="$d/work"
  git -C "$w" switch -q -c craft/work
  git -C "$w" commit -q --allow-empty --no-verify -m sneak
  ( cd "$w" && git push origin HEAD:main ) >/dev/null 2>&1; rc=$?
  lc="$(git -C "$w" rev-parse origin/main 2>/dev/null)"; rc2="$(git -C "$w" rev-parse main)"
  rm -rf "$d"
  [ "$rc" != 0 ] && [ "$lc" = "$rc2" ]   # origin/main did not move
}

# 5. The documented escape is real (`--no-verify` commits on main in the fixture), and the
#    push of that advanced main → pre-push floor refuses; origin/main does not move.
scen_push_main_denied_escape_real() {
  local d w esc rc moved; d="$(_mkfix)"; w="$d/work"
  ( cd "$w" && git commit --allow-empty --no-verify -m escape ) >/dev/null 2>&1 && esc=1 || esc=0
  ( cd "$w" && git push origin main ) >/dev/null 2>&1; rc=$?
  [ "$(git -C "$w" rev-parse origin/main)" = "$(git -C "$w" rev-parse main)" ] && moved=1 || moved=0
  rm -rf "$d"
  [ "$esc" = 1 ] && [ "$rc" != 0 ] && [ "$moved" = 0 ]
}

# 6. `git push origin --delete main` → pre-push floor refuses (delete sends a zero oid to
#    the same destination ref); main survives on origin.
scen_delete_main_denied() {
  local d w rc alive; d="$(_mkfix)"; w="$d/work"
  ( cd "$w" && git push origin --delete main ) >/dev/null 2>&1; rc=$?
  git -C "$w" ls-remote --heads origin main 2>/dev/null | grep -q main && alive=1 || alive=0
  rm -rf "$d"
  [ "$rc" != 0 ] && [ "$alive" = 1 ]
}

# 7. The bin/git wrapper refuses a commit on main EARLY (steering vector), same verdict as
#    the floor — one policy home, two call sites.
scen_wrapper_commit_main_denied() {
  local d w rc; d="$(_mkfix)"; w="$d/work"
  ( cd "$w" && "$GITW" commit --allow-empty -m nope ) >/dev/null 2>&1; rc=$?
  rm -rf "$d"
  [ "$rc" != 0 ]
}

# 8. The bin/gh wrapper refuses `pr merge` before real gh ever runs (no network, no PR
#    needed — the denial must come from the enforcer, not from gh failing).
scen_wrapper_gh_merge_denied() {
  local d w out rc; d="$(_mkfix)"; w="$d/work"
  out="$( cd "$w" && "$GHW" pr merge 1 2>&1 )"; rc=$?
  rm -rf "$d"
  [ "$rc" != 0 ] && printf '%s' "$out" | grep -q "dyad-rt"
}

assert "floor: raw commit on main DENIED, no commit lands"        scen_commit_main_denied
assert "floor: raw commit on working branch ALLOWED"              scen_commit_branch_allowed
assert "floor: raw push of working branch ALLOWED to origin"      scen_push_branch_allowed
assert "floor: refspec push HEAD:main DENIED, origin unmoved"     scen_refspec_push_main_denied
assert "floor: push to main DENIED + --no-verify escape is real"  scen_push_main_denied_escape_real
assert "floor: delete of origin/main DENIED, branch survives"     scen_delete_main_denied
assert "wrapper: bin/git commit on main DENIED early"             scen_wrapper_commit_main_denied
assert "wrapper: bin/gh pr merge DENIED by enforcer, not gh"      scen_wrapper_gh_merge_denied

assert_done
