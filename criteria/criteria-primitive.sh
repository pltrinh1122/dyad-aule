#!/usr/bin/env bash
# Acceptance criteria for the *.sh-vs-*.py decision record (dialectic/2026-07-07-criteria-primitive-sh-vs-py.md).
# Real-half only: the record exists, is falsifiable-SHAPED (claims carry falsification_targets, confounds
# are self-named, the nearest-neighbor counter-signal is named not hidden, revisit tripwires exist), and
# the TREE MATCHES THE DECISION (criteria are *.sh; no *.py criteria tracked). Whether the decision itself
# survives falsification is the *right*-half — the Operator's, not computable here.
here="$(cd "$(dirname "$0")" && pwd)"; repo="$(cd "$here/.." && pwd)"
source "$here/_lib.sh"
cd "$repo"
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

# --- The tree matches the decision (the record's claim made real, O2: record points, tree proves) ---
assert "every criteria file is *.sh (frame holds)" \
  bash -c '[ -z "$(git ls-files "criteria/*" | grep -v "\.sh$" | grep -v README)" ]'
assert "no *.py tracked at repo level (C3 evidence stays true)" \
  bash -c '[ -z "$(git ls-files "*.py")" ]'
assert "runner wires the primitive (bash \$f)"                   grep -qF 'bash "$f"' check

assert_done
