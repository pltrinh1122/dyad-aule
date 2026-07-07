#!/usr/bin/env bash
# Acceptance criteria for the *.sh-vs-*.py decision record (dialectic/2026-07-07-criteria-primitive-sh-vs-py.md).
# Real-half only: the record exists, is falsifiable-SHAPED (claims carry falsification_targets, confounds
# are self-named, the nearest-neighbor counter-signal is named not hidden, revisit tripwires exist), and
# the TREE MATCHES THE DECISION (criteria are *.sh; no *.py criteria tracked). Whether the decision itself
# survives falsification is the *right*-half — the Operator's, not computable here.
here="$(cd "$(dirname "$0")" && pwd)"; repo="$(cd "$here/.." && pwd)"
source "$here/_lib.sh"
cd "$repo" || exit 1
DR="dialectic/2026-07-07-criteria-primitive-sh-vs-py.md"

assert "decision record exists in dialectic/ (the claims home)"  test -f "$DR"
assert "states the decision: criteria files are *.sh"            grep -qF 'Criteria files are `*.sh`' "$DR"
assert "carries >=3 falsification targets"                       bash -c '[ "$(grep -c "falsification_target:" "'"$DR"'")" -ge 3 ]'
assert "self-names its confounds"                                grep -qF 'self_named_confounds' "$DR"
assert "names incumbency/post-hoc (retroactive codification)"    grep -qiE 'incumbency' "$DR"
assert "names the Commons py counter-signal, not hides it"       grep -qiE 'commons.*(falsif|py)|counter-signal' "$DR"
assert "attacks BOTH options (sh and py each get a verdict)"     bash -c '[ "$(grep -c "^  \*\*Verdict" "'"$DR"'")" -ge 2 ] || [ "$(grep -c "Verdict" "'"$DR"'")" -ge 2 ]'
assert "carries checkable revisit tripwires"                     grep -qiE 'revisit trigger' "$DR"
assert "keeps right-half with the Operator (merge seals it)"     grep -qiE 'right.*-half.*Operator|Operator.*right' "$DR"

# --- §7 falsification event (Operator attestation 2026-07-07): registered AND enforced, not prose ---
assert "records C3 FALSIFIED-as-scoped by Operator attestation"  grep -qF 'FALSIFIED-as-scoped' "$DR"
assert "carries the superseding claim C3'"                       grep -q "C3′" "$DR"
assert "CI matrix proves macOS leg (portability in-regime)"      grep -q 'macos-latest' .github/workflows/check.yml
assert "CI matrix proves Windows leg (portability in-regime)"    grep -q 'windows-latest' .github/workflows/check.yml
assert "windows leg rides git's own bash (shell: bash)"          grep -q 'shell: bash' .github/workflows/check.yml
assert "portable-subset gate wired (shellcheck over the corpus)" grep -q 'shellcheck' .github/workflows/check.yml
assert "corpus is shellcheck-clean at warning severity (skips if no shellcheck; CI gate still fires)" \
  bash -c 'if command -v shellcheck >/dev/null 2>&1; then shellcheck -S warning check criteria/*.sh bin/git bin/gh bin/d-start bin/_dyad-rt bin/_reconcile .githooks/pre-commit .githooks/pre-push; fi'

# --- §8 substrate provenance & agent-maintainability: the glue is GATED, not trusted (C4) ---
# The corpus cannot pin its utility substrate (GNU/BSD/MSYS), so it holds the POSIX intersection:
# no vendor-divergent construct may appear. This gate runs under ./check on all three vendor legs.
DENY='sed -i|grep -P|date -d|stat -[cf]|readlink -f|sort -V|echo -n|echo -e|xargs -d|realpath'
CORPUS="check criteria/*.sh bin/git bin/gh bin/d-start bin/_dyad-rt bin/_reconcile .githooks/pre-commit .githooks/pre-push"
glue_gate() {
  # shellcheck disable=SC2086  # CORPUS is a deliberate word-split file list
  ! grep -nE "$DENY" $CORPUS | grep -v "DENY="   # the DENY= line itself is the one sanctioned hit
}
assert "C4: no vendor-divergent construct in the shell corpus"   glue_gate
assert "records the provenance objection (disparate sources)"    grep -qiE 'substrate provenance' "$DR"
assert "records the agent-maintainability objection"             grep -qiE 'agent-maintainab' "$DR"
assert "carries C4 with the ground/glue decomposition"           grep -qF 'C4 — glue containment' "$DR"
assert "escape hatch sharpened to python3-stdlib"                grep -qF 'stdlib only' "$DR"

# --- The tree matches the decision (the record's claim made real, O2: record points, tree proves) ---
assert "every criteria file is *.sh (frame holds)" \
  bash -c '[ -z "$(git ls-files "criteria/*" | grep -v "\.sh$" | grep -v README)" ]'
assert "no *.py tracked at repo level (C3 evidence stays true)" \
  bash -c '[ -z "$(git ls-files "*.py")" ]'
assert "runner wires the primitive (bash \$f)"                   grep -qF 'bash "$f"' check

assert_done
