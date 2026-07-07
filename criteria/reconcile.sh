#!/usr/bin/env bash
# Acceptance criteria for bin/reconcile — the safe start-of-session reconcile.
# This routine SWITCHES HEAD and DELETES branches, so asserting it in prose is not enough (fidelity):
# each scenario builds a THROWAWAY git repo (bare origin + work clone, all file:// — no network) and
# drives the REAL bin/reconcile against it, asserting the safety envelope holds. Nothing here touches
# the actual dyad-aule repo — every scenario runs inside its own mktemp fixture with cwd set to it.
here="$(cd "$(dirname "$0")" && pwd)"; repo="$(cd "$here/.." && pwd)"
source "$here/_lib.sh"
RECON="$repo/bin/reconcile"

# Build a fresh work repo on 'main', pushed to a bare origin. Echoes the temp root.
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
  echo "$d"
}

# 1. Dirty tree → STOP: never switch away, never delete, exit nonzero, changes intact.
scen_dirty() {
  local d w rc br has; d="$(_mkfix)"; w="$d/work"
  git -C "$w" switch -q -c wip
  echo change >"$w/dirty.txt"
  ( cd "$w" && "$RECON" ) >/dev/null 2>&1; rc=$?
  br="$(git -C "$w" rev-parse --abbrev-ref HEAD)"
  [ -f "$w/dirty.txt" ] && has=1 || has=0
  rm -rf "$d"
  [ "$rc" != 0 ] && [ "$br" = wip ] && [ "$has" = 1 ]
}

# 2. Merged branch → get to fresh main, delete the merged branch (the hand-run cleanup, mechanized).
scen_merged_cleanup() {
  local d w br gone; d="$(_mkfix)"; w="$d/work"
  git -C "$w" switch -q -c feat
  git -C "$w" commit -q --allow-empty -m feat-work
  git -C "$w" switch -q main
  git -C "$w" merge -q --no-ff feat -m merge
  git -C "$w" push -q origin main
  git -C "$w" switch -q feat            # restart sitting on the already-merged branch
  ( cd "$w" && "$RECON" ) >/dev/null 2>&1
  br="$(git -C "$w" rev-parse --abbrev-ref HEAD)"
  git -C "$w" show-ref --verify -q refs/heads/feat && gone=0 || gone=1
  rm -rf "$d"
  [ "$br" = main ] && [ "$gone" = 1 ]
}

# 3. Unmerged but backed-up WIP → land on main, but PRESERVE the branch (git -d refuses unmerged).
scen_unmerged_preserved() {
  local d w br kept; d="$(_mkfix)"; w="$d/work"
  git -C "$w" switch -q -c wip
  git -C "$w" commit -q --allow-empty -m wip1
  git -C "$w" push -q -u origin wip     # backed up, NOT merged to main
  ( cd "$w" && "$RECON" ) >/dev/null 2>&1
  br="$(git -C "$w" rev-parse --abbrev-ref HEAD)"
  git -C "$w" show-ref --verify -q refs/heads/wip && kept=1 || kept=0
  rm -rf "$d"
  [ "$br" = main ] && [ "$kept" = 1 ]
}

# 4. Unpushed commits → auto-push (ground them) before reconciling; origin ends with the work.
scen_autopush_unbacked() {
  local d w onorigin; d="$(_mkfix)"; w="$d/work"
  git -C "$w" switch -q -c wip
  git -C "$w" commit -q --allow-empty -m wip-unpushed   # committed, never pushed
  ( cd "$w" && "$RECON" ) >/dev/null 2>&1
  git -C "$w" ls-remote --heads origin wip 2>/dev/null | grep -q wip && onorigin=1 || onorigin=0
  rm -rf "$d"
  [ "$onorigin" = 1 ]
}

# 5. Local main behind origin → fast-forward it.
scen_behind_ffpull() {
  local d w lc rc; d="$(_mkfix)"; w="$d/work"
  git clone -q "$d/origin.git" "$d/other"
  git -C "$d/other" config user.email o@o.local
  git -C "$d/other" config user.name other
  git -C "$d/other" config commit.gpgsign false
  git -C "$d/other" commit -q --allow-empty -m remote-advance
  git -C "$d/other" push -q origin HEAD:main
  ( cd "$w" && "$RECON" ) >/dev/null 2>&1          # local main now behind origin
  lc="$(git -C "$w" rev-parse main)"; rc="$(git -C "$w" rev-parse origin/main)"
  rm -rf "$d"
  [ "$lc" = "$rc" ]
}

assert "committed executable (git 100755): bin/reconcile" \
  bash -c '[ "$(cd "'"$repo"'" && git ls-files -s bin/reconcile | cut -d" " -f1)" = "100755" ]'
assert "dirty tree → STOP (no switch/delete, changes intact)" scen_dirty
assert "merged branch → fresh main + branch deleted"          scen_merged_cleanup
assert "unmerged backed-up WIP → on main, branch PRESERVED"   scen_unmerged_preserved
assert "unpushed commits → auto-pushed (grounded) to origin"  scen_autopush_unbacked
assert "local main behind origin → fast-forwarded"            scen_behind_ffpull

assert_done
