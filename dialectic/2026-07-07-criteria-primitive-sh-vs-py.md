# Decision record — criteria-file primitive: `*.sh` over `*.py`

> **Status:** accepted 2026-07-07 — a *retroactive codification*: the choice was made implicitly at
> `criteria/`'s inception and has 8 files of lived practice behind it, which is both its evidence
> and its chief confound (§confounds: incumbency).
> **Amended same day (§7):** C3-as-scoped **FALSIFIED by Operator attestation** — portability
> (macOS, Windows dyad operators) is in-regime. The decision was re-derived under the widened
> regime and **held**, on a rewritten ground with new enforcement (3-OS CI matrix + shellcheck
> gate). The record survives *changed*, which is what surviving falsification means.
> `submitter_dyad_id: dyad-aule · submitter_human: pltrinh1122`
> **Built for falsification** — every claim carries a `falsification_target`; verdicts against this
> record are welcome; the Operator's merge (or refusal) of the PR carrying it is the *right*-half
> judgment. Its own real-half check is `criteria/criteria-primitive.sh`.

## 0. The question

Each task deposits its acceptance criteria as an executable file in `criteria/`; `./check` runs them
all (the real-half of `craft_invariants`, DYAD.md). What language primitive should those files be —
bash (`*.sh`) or python (`*.py`)?

This is not hypothetical-free: the Commons submodule — same Operator, nearest neighbor — answered it
the **other way** (17 `*.py` under `commons/scripts/`, zero `*.sh`, including its own falsification
machinery: `falsify.py`, `validate_falsification.py`). The decision must beat that counter-signal,
not ignore it.

## 1. Context — the forces

- **What a criterion asserts.** Today, 8/8 criteria files assert *shell-facts*: a file exists, a git
  mode is `100755`, a process exits nonzero, a string is present/absent, a fixture repo ends in a
  given state. The subjects under test are themselves bash — the entire runtime layer
  (`bin/_dyad-rt`, `bin/_reconcile`, `bin/d-start`, wrappers, `.githooks/*`) is ~724 LOC of shell.
- **The runner.** `check:24` invokes each file as `bash "$f"` — the primitive is wired into the
  runner, and CI (`.github/workflows/check.yml`) rides the same path.
- **The harness cost.** `criteria/_lib.sh` is 29 lines; a per-task criteria file is a header plus
  one `assert` line per claim (corpus: 28–101 LOC, median ≈ 35).
- **The substrate.** bash + git + coreutils are the floor this repo already cannot run without
  (hooks, wrappers, launcher). This repo tracks **zero** `.py` files; python would be a new
  interpreter axis (version, venv, the standing temptation of pip) for the repo itself.

## 2. Decision

**Criteria files are `*.sh`**: one file per task, sourcing `_lib.sh`, claims as `assert` one-liners,
run by `./check` via `bash "$f"`. The decision is **per-file, not total** — see the §5 escape hatch
before reading this as "never python."

Driver ranking is the dyad's own axes, in order: **fidelity** (the check itself must be transparent
and hard to fool) → **turns** (cost to stand up criteria per task) → **dependency surface**.

## 3. Dialectical attack (attack both; keep what survives)

- **Attack `*.sh` — the quoting/semantics hazard.** The idiom at `criteria/dyad-rt.sh:13`
  (`assert "deny: …" bash -c '! "'"$rt"'" check-branch main'`) is exactly the fragile
  nested-quoting pattern; a slip can yield a **false PASS** — the worst failure class for a
  fidelity instrument, a check that lies green. Compounding it: `_lib.sh` swallows stderr
  (`>/dev/null 2>&1`), so a MISS names *what* broke, never *why* (accepted debt, §6). Bash has no
  real data structures — the space-delimited `case` allowlists (`criteria/org-invariants.sh:13-18`)
  break on paths with spaces (latent, unexercised). And fixture-bash has a complexity ceiling:
  `reconcile.sh` at 101 LOC sits near the legibility edge.
  **Verdict: survives, conditionally** — sound while every claim stays shell-fact-shaped and files
  stay small; *load-bearing on a claim-shape it does not enforce* (tripwires in §5 are the
  enforcement).
- **Attack `*.py` — the machinery-between tax.** Python buys real data structures, tracebacks
  (*why*, not just *what*), and pytest — and the Commons proves it works for this Operator. But
  every shell-fact must then round-trip through `subprocess.run` (string→argv translation,
  return-code interpretation, a helper lib that re-implements `_lib.sh` before the first claim is
  stated) — the impedance cost lands on **100% of the current corpus** to buy generality **0% of it
  needs**. Worse, on the fidelity axis: an `assert` line today *is* the command the Operator would
  run by hand to verify the claim — verbatim. Each layer of machinery between the assertion and the
  ground is a place the check itself can be wrong, and a python harness is such a layer wholesale.
  **Verdict: python wins the moment claims stop being shell-facts; it loses while they all are.**

**Survivor:** `*.sh` as the *frame*, with the claim-shape boundary made explicit and tripwired —
not "bash is better," but *"bash, while the ground being checked is itself made of shell-facts."*

## 4. Claims (FR-shaped — the falsifiable core)

**C1 — fidelity (the load-bearing claim).** *For shell-fact claims, a bash `assert` one-liner
dominates a python harness on the fidelity axis: it is the Operator's manual verification command,
verbatim, with ~4 lines of machinery total between assertion and ground.*
- evidence: `criteria/_lib.sh:10-17` (the whole assert mechanism); `check:24` (`bash "$f"` — no
  translation layer); `criteria/dyad-rt.sh:13` (assertion ≡ the hand-check).
- falsification_target: **one false PASS traced to bash semantics** (quoting, word-splitting,
  exit-status masking, `set -e` subtlety) — a criterion green while its subject was broken. A single
  occurrence inverts this claim: the transparency bought the lie, and the record must be revisited.

**C2 — claim-shape boundary.** *The decision is load-bearing on the corpus staying shell-fact-shaped;
it is a bet about the criteria we will write, not only the ones we have.*
- evidence: 8/8 current files are shell-facts (existence, git modes, exit codes, grep); zero
  criteria today parse structure semantically (YAML/JSON) or assert numerically.
- falsification_target: a task whose acceptance criteria **require semantic parsing of structured
  data** (e.g., validating `commons/directory/dyad-aule.yaml` beyond grep) or statistical/numeric
  assertion, *forced into a grep-shaped approximation to stay in bash*. The first approximated
  criterion is the boundary breach — the check weakened to preserve the primitive is fidelity
  inverted.

**C3 — dependency surface.** *bash+git is the empty-marginal-dependency choice for THIS repo: the
runtime already cannot exist without them, so criteria add zero new trust roots; python3 —
however ubiquitous — is a genuinely new axis here.*
- evidence: `bin/*` + `.githooks/*` all bash; `git ls-files '*.py'` returns empty at repo level
  (the 17 Commons `.py` live in the submodule, a different writer).
- falsification_target: a real portability casualty — CI or a fresh Operator machine where criteria
  fail for **bash-version reasons** (macOS `bash 3.2` vs arrays/`mapfile`, BSD vs GNU coreutils).
  python3's ubiquity is at least bash's; the first version-skew failure kills the "zero marginal
  dependency" advantage in practice.
- **status: FALSIFIED-as-scoped (2026-07-07, Operator attestation — see §7).** Not by a casualty
  but by the Operator widening the regime: portability is a *requirement*, not a hypothetical.
  Superseded by **C3′** in §7; the enforcement moved from "wait for the casualty" to "prove the
  claim per-push."

**self_named_confounds (apply to all claims):**
- **incumbency / post-hoc:** 8 files already exist in `*.sh`; this record rationalizes a decision
  made implicitly. Sunk cost may be wearing fidelity's clothes — weight the "impedance" arguments
  down accordingly.
- **author-fluency meld:** the agent authored all 8 criteria files *and* this record; "legible" and
  "one-liner" are agent-judged. The Operator's own read of `reconcile.sh:101` LOC of fixture-bash is
  the unverified *right*-half of every legibility claim here.
- **flatter-tell:** C1 flatters dyad-aule's own fidelity value — the same tell §4 of the concurrency
  report weighted down. Weight down here too.
- **nearest-neighbor counter-signal:** the Commons — same human, same ecosystem — chose python for
  *its* falsification machinery. Its scripts' claim-shape differs (registry parsing, YAML
  validation: structured-fact, not shell-fact — which is C2 *corroborated*, not refuted), but the
  counter-example is live and must stay named.
- **small-n:** ~370 LOC of criteria across 8 files; the complexity ceiling (§3) is argued, not yet
  hit.

## 5. Boundary discipline — the escape hatch and the tripwires

The cheapest correct response to a structured-fact criterion is **not** migrating the primitive:
a `criteria/<task>.sh` file may shell out to `python3` (or the Commons' own validators) for the
structured sub-check, keeping the `.sh` file as the assertion frame. The *frame* migrates only if
the assert-line shape itself stops fitting the corpus.

Revisit triggers — each is checkable, and hitting one obliges a revisit of this record, not a quiet
workaround:

1. **False PASS from shell semantics** (C1 target) → immediate revisit; this is the fidelity claim
   dying.
2. **Second structured-fact criterion** (C2 target): first one uses the escape hatch above; a second
   means the corpus' claim-shape has moved — revisit the primitive.
3. **A criteria file exceeding ~120 LOC** or out-nesting `reconcile.sh`'s fixtures → the legibility
   verdict in §3 no longer holds for that file.
4. ~~**bash-version portability failure** (C3 target) → the dependency advantage was illusory.~~
   **Fired 2026-07-07** — not by casualty but by Operator attestation (§7). Rewritten: portability
   is now *proven continuously* (3-OS CI matrix + shellcheck gate); the new tripwire is **a matrix
   leg that cannot be made green without weakening a criterion** — that would mean the portable
   subset can't carry the claim-shape, and the primitive must be revisited.

## 6. Consequences (accepted, eyes open)

- Quoting discipline lands on review — no linter enforces it (a `shellcheck` gate is the obvious
  hardening if C1's target ever fires a near-miss).
- A MISS names *what*, not *why* (`_lib.sh` swallows stderr); the debug path is "run the file by
  hand." Accepted as debt, priced against keeping the assert mechanism 4 lines.
- No structured test report (JUnit-XML etc.) for CI — `./check`'s loud plain text is the interface
  until something real consumes more.
- The real-half of *this record* is `criteria/criteria-primitive.sh`: the record exists, states the
  decision, carries its falsification targets and confounds, and the tree matches the decision
  (no `*.py` criteria tracked). The *right*-half — whether this survives your falsification — is
  the Operator's, sealed by the merge.

## 7. Falsification event — Operator attestation, 2026-07-07 (C3 → C3′)

**The event.** The Operator attested: *portability is a real necessity — there are other dyad
operators on different platforms, e.g. macOS and Windows.* This falsifies C3 **as scoped**: C3
argued from "THIS repo, this machine," and priced portability as a hypothetical to be paid on first
casualty (tripwire 4). The regime is wider than the claim's scope; a Ratifier attestation of the
regime beats the record's assumption about it. Registered, not argued with.

**The re-derivation under the widened regime** (the dialectic of §3, re-run):

- **Windows inverts the naive python case.** Stock Windows guarantees *neither* primitive — the
  built-in `python` is a Microsoft-Store stub, not an interpreter. But a dyad *by construction*
  runs CLI git (the `.githooks` floor and `bin/` wrappers presuppose it), and **Git for Windows
  ships bash**. So for the population the Operator named — *dyad* operators — the shell arrives
  with the tool the practice already cannot exist without; python3 is the extra install.
- **macOS bounds the subset.** `/bin/bash` is frozen at 3.2 (licensing) and coreutils are BSD: the
  corpus must stay inside bash-3.2 + POSIX-utility idioms — a *discipline*, which prose cannot hold
  (the exact drift-failure this repo's O-invariants exist to prevent).
- **The runtime layer was always implicated.** Criteria are the smallest part: `bin/_dyad-rt`,
  `_reconcile`, `d-start`, the wrappers and hooks are all shell. Migrating criteria to python would
  leave the guard layer's portability question untouched — the attestation is really about the
  whole shell corpus, and the enforcement below covers all of it.

**C3′ (supersedes C3).** *bash rides git's own distribution on all three platforms, so for
git-based dyads the marginal dependency is still zero — and this is proven per-push, not asserted:
the real-half check runs on a ubuntu/macos/windows CI matrix, and the whole shell corpus passes a
`shellcheck` portable-subset gate.*
- evidence: `.github/workflows/check.yml` (3-OS matrix, `shell: bash` on the windows leg; the
  `shellcheck` job over `check`, `criteria/*.sh`, `bin/*`, `.githooks/*`); the corpus made
  shellcheck-clean at warning severity in the same commit (6 findings fixed: 5× `cd || exit`,
  1 shell directive).
- falsification_target: **a matrix leg that cannot be made green without weakening a criterion** —
  a check diluted to stay portable is fidelity inverted (C2's logic applied to platforms); OR a
  real dyad-operator platform where git's distribution does not carry a usable bash. Either ends
  C3′ and reopens the primitive decision, with python3 the leading successor *for that regime*.

**Confound, self-named:** the matrix proves the *runners'* macOS/Windows (GitHub's images, where
`env bash` may resolve to a newer brew bash on macOS), not every operator's laptop. It is the best
continuously-payable proxy; a lived report from an actual macOS/Windows dyad operator outranks it
and is invited — as a DM or an issue.
