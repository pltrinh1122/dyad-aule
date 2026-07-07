#!/usr/bin/env bash
# Acceptance criteria for the repository's organizational invariants (README.md, O1-O7).
# The README codifies conventions; this is their real-half check, so the repo cannot drift
# from its own stated organization (the failure our peers exhibit — see dialectic/).
here="$(cd "$(dirname "$0")" && pwd)"; repo="$(cd "$here/.." && pwd)"
source "$here/_lib.sh"
cd "$repo"

# O1 — front door.
assert "O1: root README.md exists"            test -f README.md

# O3 — minimal, predictable root: every tracked top-level entry is allowlisted.
ALLOW=" .gitignore .gitmodules CLAUDE.md DYAD.md README.md LICENSE check commons criteria dialectic dm retro .github "
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

# O7 — public repo declares a license.
assert "O7: LICENSE present"                    test -f LICENSE

assert_done
