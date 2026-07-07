#!/usr/bin/env bash
# Acceptance criteria for the build-commission readiness self-evaluation
# (dialectic/2026-07-07-build-commission-readiness.md). Real-half of the REPORT'S SHAPE only:
# it exists, every gap is falsifiable (carries a falsification_target), the meta-gap and
# confounds are self-named, severity + close-order are present, and closure stays the
# Operator's (Builder-lane proposal, not agent self-grant). Whether the gaps are the RIGHT
# gaps — and when to close them — is the Operator's judgment, not computable here.
# NB: deliberately NOT asserted: the gaps' open/closed state. Gaps are meant to close; a
# criteria file that pins them open would fight the practice's own progress.
here="$(cd "$(dirname "$0")" && pwd)"; repo="$(cd "$here/.." && pwd)"
source "$here/_lib.sh"
cd "$repo" || exit 1
RPT="dialectic/2026-07-07-build-commission-readiness.md"

assert "readiness report exists in dialectic/ (claims home)"      test -f "$RPT"
assert "names the meta-gap (self-referential capability)"         grep -qiE 'self-referential' "$RPT"
assert "inventories what is NOT a gap (no false modesty)"         grep -qF 'not** a gap' "$RPT"
assert "carries >=8 falsifiable gaps (falsification_target each)" bash -c '[ "$(grep -c "falsification_target:" "'"$RPT"'")" -ge 8 ]'
assert "G0: names the turn/execution coupling as the root gap"    grep -qiE 'chat-turn and execution are coupled' "$RPT"
assert "G0: records the Operator's falsification of the frame"    grep -qiE 'Operator falsification of this report' "$RPT"
assert "G0: queue state must be DERIVED, never stored (C3 tie)"   grep -qiE 'DERIVED, never stored' "$RPT"
assert "G0: WIP=1 preserved (decouples time, not workers)"        grep -qiE 'decouples.*time.*not.*workers' "$RPT"
assert "close-order: queue itself becomes the first plan"         grep -qiE 'first enqueued plan' "$RPT"
assert "keeps the deferred ceiling honest (G8 defer + signal)"    grep -qiE 'defer' "$RPT"
assert "self-names confounds (incl. self-grading)"                grep -qF 'self-grading' "$RPT"
assert "carries a severity map"                                   grep -qiE 'severity map' "$RPT"
assert "proposes a close-order into the Builder lane"             grep -qiE 'close-order' "$RPT"
assert "closure stays the Operator's (proposes, not self-grants)" grep -qiE 'Operator disposes' "$RPT"

assert_done
