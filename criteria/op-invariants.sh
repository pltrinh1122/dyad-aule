#!/usr/bin/env bash
# Acceptance criteria for the Operator-introduced operational invariants (codified 2026-07-07):
# op-portability, op-substrate, op-queue, op-SoT, and the SPAOR kind-home naming rule.
# Two halves per invariant: the ANCHOR names it (DYAD.md) AND its ENFORCEMENT artifact is live in
# the engine — an invariant asserted without its mechanism is the anchor≠engine drift this dyad
# pins on peers (dialectic/). Ratification itself is the Operator's merge, not assertable here.
here="$(cd "$(dirname "$0")" && pwd)"; repo="$(cd "$here/.." && pwd)"
source "$here/_lib.sh"
cd "$repo" || exit 1
A="DYAD.md"

# --- op-portability: anchored + enforced (3-OS matrix, shellcheck gate) ---
assert "anchor names op-portability"                     grep -qF 'op-portability' "$A"
assert "enforced: CI matrix carries macOS + Windows"     bash -c "grep -q 'macos-latest' .github/workflows/check.yml && grep -q 'windows-latest' .github/workflows/check.yml"
assert "enforced: shellcheck gate in CI"                 grep -q 'shellcheck' .github/workflows/check.yml

# --- op-substrate: anchored + enforced (C4 denylist gate, stdlib-only hatch stated) ---
assert "anchor names op-substrate"                       grep -qF 'op-substrate' "$A"
assert "enforced: vendor-divergent denylist gate exists" grep -q 'DENY=' criteria/criteria-primitive.sh
assert "anchor pins the overflow to python3-stdlib"      grep -qF 'python3-stdlib' "$A"

# --- op-queue: anchored + enforced (plan/ home, contract, shape criteria) ---
assert "anchor names op-queue"                           grep -qF 'op-queue' "$A"
assert "anchor states turn is not the unit of execution" grep -qiE 'chat-turn is not the unit of execution' "$A"
assert "enforced: node home is the plan-cache (issues-as-home, N11)" test -d .dyad-state/plan-cache
assert "enforced: node schema + FSM guard criteria exist" bash -c "test -f criteria/issue-node-schema.sh && test -f criteria/state-guard.sh"
assert "anchor keeps WIP=1 (time, not workers)"          bash -c "grep -qF 'op-queue' '$A' && grep -qiE 'decouples.*time.*not.*workers' '$A'"

# --- op-SoT: anchored + the inbox rule in vocabulary ---
assert "anchor names op-SoT"                             grep -qF 'op-SoT' "$A"
assert "vocabulary carries 'inbox, never truth'"         grep -qF 'inbox, never truth' "$A"
assert "the plan-home decision record exists (issues-as-home)" test -f dialectic/2026-07-08-plan-home-local-vs-issues.md

# --- op-intent: anchored (survivor wording) + its record carries the falsification ---
assert "anchor names op-intent"                          grep -qF 'op-intent' "$A"
assert "anchor states the two intent states"             bash -c "grep -qF 'ratified' '$A' && grep -qiE 'novel normative ground' '$A'"
assert "anchor carries the Sense-turn framing (SPAOR)"   grep -qF 'Sense turns' "$A"
assert "anchor carries the one-way ratchet"              grep -qiE 'never loosens its own gate' "$A"
assert "record exists with survivor + falsification"     bash -c "grep -qF 'The survivor' dialectic/2026-07-07-learning-invariant-intent-first.md && grep -c 'falsification_target:' dialectic/2026-07-07-learning-invariant-intent-first.md | grep -qE '^[3-9]'"
assert "record dog-foods its own Interpretation block"   grep -qF 'Interpretation block (this record dog-foods' dialectic/2026-07-07-learning-invariant-intent-first.md

# --- SPAOR kind-home naming (ontology #7) ---
assert "ontology names the SPAOR kind-home rule"         bash -c "grep -qF 'SPAOR phase' '$A'"
assert "vocabulary defines plan-node / frontier"         grep -qF 'plan-node / frontier' "$A"

assert_done
