#!/usr/bin/env bash
# Acceptance criteria for plan node N14 — bin/_state-guard, the node-lifecycle FSM guard (the
# issues-as-home flip, N11). Storing status is licensed ONLY behind a REAL guard: this proves the
# guard both ALLOWS every legal transition AND DENIES the illegal ones (a guard that denies
# everything proves nothing — the dyad-rt.sh discipline), plus the close→done real-half gate (C3)
# and drift detection. The FSM policy is PURE, so it is proven with NO network. The guard is also
# shown WIRED into bin/gh (not cairn's asserted-but-unwired counterfeit).
here="$(cd "$(dirname "$0")" && pwd)"; repo="$(cd "$here/.." && pwd)"
source "$here/_lib.sh"
cd "$repo" || exit 1
G="$repo/bin/_state-guard"

assert "committed executable (git 100755): bin/_state-guard" \
  bash -c '[ "$(git ls-files -s bin/_state-guard | cut -d" " -f1)" = "100755" ]'

lt()  { "$G" legal-transition "$1" "$2"; }
nlt() { ! "$G" legal-transition "$1" "$2"; }

# --- ALLOW every legal edge ---
assert "allow clarify→dispose (Sense converges)"        lt clarify dispose
assert "allow dispose→execute (disposition)"            lt dispose execute
assert "allow execute→done (deliver)"                   lt execute "done"
assert "allow execute→clarify (reground)"               lt execute clarify
assert "allow blocked→execute (unblock)"                lt blocked execute
assert "allow any→blocked (dep flips): dispose→blocked" lt dispose blocked
assert "allow done→clarify (reopen/reground)"           lt "done" clarify
assert "allow idempotent re-label (execute→execute)"    lt execute execute

# --- DENY the illegal edges (the whole point) ---
assert "DENY clarify→execute (no Act without disposition)" nlt clarify execute
assert "DENY clarify→done (skips execution)"               nlt clarify "done"
assert "DENY dispose→done (must pass through execute)"      nlt dispose "done"
assert "DENY blocked→done (must unblock first)"             nlt blocked "done"
assert "DENY unknown target"                                nlt execute frobnicate

# --- close→done real-half gate (C3): only criteria-green ∧ PR-merged ---
assert "close allowed only when green AND merged"      "$G" close-allowed yes yes
assert "close DENIED when not green"                   bash -c '! "'"$G"'" close-allowed no yes'
assert "close DENIED when not merged"                  bash -c '! "'"$G"'" close-allowed yes no'

# --- drift: stored status vs derived ground (cache-with-tripwire) ---
dok() { "$G" drift "$@"; }                 # exit 0 = no drift
dno() { ! "$G" drift "$@"; }               # exit nonzero = drift found
assert "drift: execute + no open PR → flagged"         dno --status execute
assert "drift: execute + open PR → clean"              dok --status execute --open-pr
assert "drift: blocked + deps done → stale flagged"    dno --status blocked --deps-done
assert "drift: blocked + deps pending → clean"         dok --status blocked
assert "drift: dispose + dep pending → flagged"        dno --status dispose
assert "drift: dispose + deps done → clean"            dok --status dispose --deps-done
assert "drift: closed + not green → flagged"           dno --status "done" --closed
assert "drift: closed + green → clean"                 dok --status "done" --closed --criteria-green

# --- PURE paths are network-free (green with a failing gh shadowing PATH) ---
ngh="$(mktemp -d)"; printf '#!/bin/sh\nexit 99\n' >"$ngh/gh"; chmod +x "$ngh/gh"
assert "legal-transition needs no network" bash -c 'PATH="'"$ngh"':$PATH" "'"$G"'" legal-transition clarify dispose'
assert "drift needs no network"            bash -c 'PATH="'"$ngh"':$PATH" "'"$G"'" drift --status execute --open-pr'
rm -rf "$ngh"

# --- WIRED (not counterfeit): bin/gh delegates to the guard on every gh call ---
assert "bin/gh routes gh through the state-guard"      grep -qE '_state-guard"? check-gh-transition' bin/gh
assert "bin/gh committed executable (git 100755)"      bash -c '[ "$(git ls-files -s bin/gh | cut -d" " -f1)" = "100755" ]'

assert_done
