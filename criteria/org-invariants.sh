#!/usr/bin/env bash
# Acceptance criteria for the repository's organizational invariants (README.md, O1-O7).
# The README codifies conventions; this is their real-half check, so the repo cannot drift
# from its own stated organization (the failure our peers exhibit — see dialectic/).
here="$(cd "$(dirname "$0")" && pwd)"; repo="$(cd "$here/.." && pwd)"
source "$here/_lib.sh"
cd "$repo" || exit 1

# O1 — front door.
assert "O1: root README.md exists"            test -f README.md

# O3 — minimal, predictable root: every tracked top-level entry is allowlisted.
ALLOW=" .gitignore .gitmodules CLAUDE.md DYAD.md README.md LICENSE check commons criteria dialectic dm retro .github bin .githooks "
stray=""
for e in $(git ls-files | sed 's#/.*##' | sort -u); do
  case "$ALLOW" in *" $e "*) : ;; *) stray="$stray $e" ;; esac
done
if [ -z "$stray" ]; then echo "  ok   O3: root minimal (no stray entries)"; else echo "  MISS O3: stray root entries:$stray"; _fails=$((_fails+1)); fi

# O3 — each declared artifact-kind has its home.
for d in criteria retro dialectic dm; do assert "O3: kind-home $d/ present" test -d "$d"; done

# O4 — hygiene: .gitignore present and no cruft tracked.
assert "O4: .gitignore present"               test -f .gitignore
cruft="$(git ls-files | grep -Ei '(\.pyc$|__pycache__|\.DS_Store|\.tmp$|(^|/)scratch/|\.falsify-seen\.json$)' || true)"
if [ -z "$cruft" ]; then echo "  ok   O4: no cruft tracked"; else echo "  MISS O4: cruft tracked: $cruft"; _fails=$((_fails+1)); fi

# O5 — criteria are executable AND wired into CI on every PR.
# NB: assert the COMMITTED git mode (100755), not `test -x` — the working-tree bit can be present
# while git stores 100644, which passes locally but fails on a fresh CI checkout (caught in CI, PR #6).
assert "O5: check runner committed executable (git 100755)" \
  bash -c '[ "$(git ls-files -s check | cut -d" " -f1)" = "100755" ]'
assert "O5: CI workflow present"               bash -c "ls .github/workflows/*.yml >/dev/null 2>&1"
assert "O5: CI runs the check"                 bash -c "grep -rqF './check' .github/workflows/"
# Same lesson, whole bucket: every criteria/*.sh (and the .githooks floor, and every bin/ script)
# must be COMMITTED 100755 — this filesystem's mode bits mask the drift locally (found 2026-07-07:
# three criteria files had slid to 100644 while ./check's `bash "$f"` hid it).
nonexec="$(git ls-files -s 'criteria/*.sh' '.githooks/*' 'bin/*' | grep -v '^100755 ' | awk '{print $4}' | paste -sd' ' -)"
if [ -z "$nonexec" ]; then echo "  ok   O5: criteria/.githooks/bin all committed executable"; else echo "  MISS O5: committed non-executable: $nonexec — git update-index --chmod=+x <file>"; _fails=$((_fails+1)); fi

# O7 — public repo declares a license.
assert "O7: LICENSE present"                    test -f LICENSE

# O8 — the `d-*` prefix is reserved for OPERATOR-INVOKED disciplines (the tokens the Operator types),
# never internal machinery (Operator convention, 2026-07-07). Any bin/d-* or criteria/d-*.sh must name
# a sanctioned discipline in the allowlist below; the list grows as disciplines land.
OPERATOR_DISCIPLINES=" d-start "
strayd=""
for f in $(git ls-files 'bin/d-*' 'criteria/d-*.sh'); do
  base="$(basename "$f" .sh)"
  case "$OPERATOR_DISCIPLINES" in *" $base "*) : ;; *) strayd="$strayd $f" ;; esac
done
if [ -z "$strayd" ]; then echo "  ok   O8: d-* prefix only on operator disciplines"; else echo "  MISS O8: d-* on non-operator (internal) file(s):$strayd — rename without the d- prefix"; _fails=$((_fails+1)); fi

# O9 — internal bin/ scripts (not Operator-invoked) carry the `_` prefix (Operator convention,
# 2026-07-07; industry `_private` idiom). Public bin/ entry points are allowlisted; every other tracked
# bin/ file must start with `_`. (git/gh keep their names to shadow the real tools; claude launches;
# d-start is the Operator's token.)
BIN_PUBLIC=" claude git gh d-start "
strayi=""
for f in $(git ls-files 'bin/*'); do
  b="$(basename "$f")"
  case "$b" in _*) continue ;; esac
  case "$BIN_PUBLIC" in *" $b "*) : ;; *) strayi="$strayi $f" ;; esac
done
if [ -z "$strayi" ]; then echo "  ok   O9: internal bin/ scripts carry the _ prefix"; else echo "  MISS O9: bin/ file(s) neither public nor _-prefixed:$strayi — prefix internal scripts with _"; _fails=$((_fails+1)); fi

assert_done
