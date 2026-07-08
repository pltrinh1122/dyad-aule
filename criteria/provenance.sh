#!/usr/bin/env bash
# Acceptance criteria for plan node N8 — op-provenance: no Act without ingested intent.
# Proves the ENFORCER (bin/_dyad-rt check-provenance*) and the commit-msg FLOOR end-to-end in a
# throwaway fixture (file:// only), plus the wiring: CI authoritative gate, anchor entry landed
# WITH the mechanism, state kind-home registered. Deny AND allow are both asserted — a guard that
# denies everything proves nothing. Nothing here touches the real dyad-aule repo.
here="$(cd "$(dirname "$0")" && pwd)"; repo="$(cd "$here/.." && pwd)"
source "$here/_lib.sh"
cd "$repo" || exit 1
RT="$repo/bin/_dyad-rt"
HOOKS="$repo/.githooks"

# Fixture: work repo with a plan (node X), the REAL hooks wired, initial history made with
# --no-verify (setup is not the subject under test).
_mkfix() {
  local d; d="$(mktemp -d)"
  git init -q "$d/work"
  git -C "$d/work" config user.email t@t.local
  git -C "$d/work" config user.name test
  git -C "$d/work" config commit.gpgsign false
  mkdir -p "$d/work/plan" "$d/work/.dyad-state"
  printf '%s\n' 'NODE X deps=- done=x.sh lane=agent :: a ratified node' >"$d/work/plan/p.md"
  printf '%s\n' 'seed' >"$d/work/.dyad-state/seed.txt"
  # issues-as-home (N11/N16): a node id is a GitHub issue number, resolved against the plan-cache.
  mkdir -p "$d/work/.dyad-state/plan-cache"
  printf 'CACHE-NODE #42 status=clarify deps=- done=x.sh :: a cached node-issue\n' >"$d/work/.dyad-state/plan-cache/42.md"
  git -C "$d/work" add -A
  git -C "$d/work" commit -q --no-verify -m init
  git -C "$d/work" branch -M work
  git -C "$d/work" config core.hooksPath "$HOOKS"
  echo "$d"
}

# --- Enforcer unit level: check-provenance <commit> (class derived from paths) ---
scen_unit() {
  local d w ok=1; d="$(_mkfix)"; w="$d/work"
  # a) artifact commit WITH resolving trailer → ALLOW
  printf '%s\n' a >"$w/a.txt"; git -C "$w" add a.txt
  git -C "$w" commit -q --no-verify -m "$(printf 'work\n\nNode: X')"
  ( cd "$w" && "$RT" check-provenance HEAD ) >/dev/null 2>&1 || ok=0
  # b) artifact commit WITHOUT trailer → DENY
  printf '%s\n' b >"$w/b.txt"; git -C "$w" add b.txt
  git -C "$w" commit -q --no-verify -m "no trailer"
  ( cd "$w" && "$RT" check-provenance HEAD ) >/dev/null 2>&1 && ok=0
  # c) artifact commit with UNRESOLVABLE trailer → DENY
  printf '%s\n' c >"$w/c.txt"; git -C "$w" add c.txt
  git -C "$w" commit -q --no-verify -m "$(printf 'work\n\nNode: ZZ')"
  ( cd "$w" && "$RT" check-provenance HEAD ) >/dev/null 2>&1 && ok=0
  # d) commit touching ONLY .dyad-state/ → state capture, ALLOW without trailer
  printf '%s\n' s >"$w/.dyad-state/resume.txt"; git -C "$w" add .dyad-state/resume.txt
  git -C "$w" commit -q --no-verify -m "state capture"
  ( cd "$w" && "$RT" check-provenance HEAD ) >/dev/null 2>&1 || ok=0
  # e) merge commit without trailer → the Operator's act, ALLOW
  git -C "$w" switch -q -c side
  printf '%s\n' m >"$w/m.txt"; git -C "$w" add m.txt
  git -C "$w" commit -q --no-verify -m "$(printf 'side\n\nNode: X')"
  git -C "$w" switch -q work
  git -C "$w" merge -q --no-ff --no-verify -m "merge side" side >/dev/null 2>&1
  ( cd "$w" && "$RT" check-provenance HEAD ) >/dev/null 2>&1 || ok=0
  # f) issues-as-home: artifact commit with Node: #42 (in cache) → ALLOW
  printf '%s\n' f1 >"$w/f1.txt"; git -C "$w" add f1.txt
  git -C "$w" commit -q --no-verify -m "$(printf 'work\n\nNode: #42')"
  ( cd "$w" && "$RT" check-provenance HEAD ) >/dev/null 2>&1 || ok=0
  # g) Node: #77 (NOT in cache) → DENY
  printf '%s\n' f2 >"$w/f2.txt"; git -C "$w" add f2.txt
  git -C "$w" commit -q --no-verify -m "$(printf 'work\n\nNode: #77')"
  ( cd "$w" && "$RT" check-provenance HEAD ) >/dev/null 2>&1 && ok=0
  rm -rf "$d"
  [ "$ok" = 1 ]
}

# --- The commit-msg floor fires through REAL git commit ---
scen_floor_denies_untraced() {
  local d w rc before after; d="$(_mkfix)"; w="$d/work"
  printf '%s\n' x >"$w/x.txt"; git -C "$w" add x.txt
  before="$(git -C "$w" rev-parse HEAD)"
  ( cd "$w" && git commit -q -m "artifact work, no trailer" ) >/dev/null 2>&1; rc=$?
  after="$(git -C "$w" rev-parse HEAD)"
  rm -rf "$d"
  [ "$rc" != 0 ] && [ "$before" = "$after" ]
}
scen_floor_allows_traced() {
  local d w rc; d="$(_mkfix)"; w="$d/work"
  printf '%s\n' x >"$w/x.txt"; git -C "$w" add x.txt
  ( cd "$w" && git commit -q -m "$(printf 'traced work\n\nNode: X')" ) >/dev/null 2>&1; rc=$?
  rm -rf "$d"
  [ "$rc" = 0 ]
}
scen_floor_allows_state_capture() {
  local d w rc; d="$(_mkfix)"; w="$d/work"
  printf '%s\n' r >"$w/.dyad-state/resume.txt"; git -C "$w" add .dyad-state/resume.txt
  ( cd "$w" && git commit -q -m "resume snapshot, trailer-free" ) >/dev/null 2>&1; rc=$?
  rm -rf "$d"
  [ "$rc" = 0 ]
}

assert "unit: allow traced / deny untraced+unknown / exempt state+merge" scen_unit
assert "floor: real commit of artifact w/o trailer REFUSED"              scen_floor_denies_untraced
assert "floor: real commit with resolving Node: trailer ALLOWED"         scen_floor_allows_traced
assert "floor: only-.dyad-state/ commit ALLOWED trailer-free"            scen_floor_allows_state_capture

# --- Wiring: floor committed + delegating, CI authoritative gate, kind-home, anchor WITH mechanism ---
assert "committed executable (git 100755): .githooks/commit-msg" \
  bash -c '[ "$(git ls-files -s .githooks/commit-msg | cut -d" " -f1)" = "100755" ]'
assert "floor delegates to the enforcer (single policy home)"    grep -qE 'dyad-rt"? check-provenance-staged' .githooks/commit-msg
assert "CI carries the authoritative provenance gate"            grep -qF 'check-provenance' .github/workflows/check.yml
assert "CI judges the PR range only (no re-judging history)"     grep -qF 'base.ref' .github/workflows/check.yml
assert "state kind-home .dyad-state/ exists with its contract"   grep -qiE 'state capture' .dyad-state/README.md
assert "anchor names op-provenance (landed WITH the mechanism)"  grep -qF 'op-provenance' DYAD.md
assert "anchor: no Act without ingested intent"                  grep -qF 'no Act without ingested intent.' DYAD.md
assert "d-start surfaces untraced unpushed commits"              grep -qF 'check-provenance' bin/d-start

assert_done
