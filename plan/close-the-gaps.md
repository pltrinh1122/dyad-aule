# Plan — close the commission-readiness gaps

> The dyad's first execution plan, and the dog-food of G0 itself: **this plan's writing is node
> N0 of its own DAG.** Source of the node set: the readiness evaluation
> (`dialectic/2026-07-07-build-commission-readiness.md`, close-order §3, as amended by the
> Operator's G0 falsification). Shape constraints inherited from the ratified concurrency
> evaluation (`dialectic/2026-07-06-concurrency-fsm-evaluation.md` §4-5): DAG of orthogonal
> nodes · state **derived, never stored** · WIP=1 (the plan decouples *time*, not workers) ·
> grounded on the remote via the branch→PR→merge loop.

## How to read this file (the queue's contract)

- **This file holds intent and edges only — never completion.** There is no status field, by
  invariant (C3: a stored status-pointer structurally drifts). Node state is DERIVED:
  - a `done=<file>.sh` node is **DONE ⟺ its named criteria file is tracked on `origin/main`**
    (CI runs `./check` on every merge, so presence-on-main carries check-green with it);
  - a `done=disposition` node is **DONE ⟺ its `DISPOSITION <id>:` line below is non-TODO on
    `origin/main`** (the Operator edits it; the merge is the ratification);
  - a node is **READY ⟺ all its `deps` are DONE**. The **frontier** is the set of READY nodes;
    WIP=1 means a session picks **one**.
- Node lines are machine-parseable on purpose (one line, fixed fields) so the frontier stays
  derivable inside the criteria claim-shape (DR C2); if this format outgrows shell parsing,
  tripwire 5 of `dialectic/2026-07-07-criteria-primitive-sh-vs-py.md` governs (python3-stdlib
  hatch, then revisit).
- Editing this file = replanning; it goes through a PR like everything else. Completing a node
  requires **no edit here** — that is the decoupling.

## The DAG

Format: `NODE <id> deps=<csv|-> done=<criteria-file|disposition> lane=<agent|operator|dyad> :: <title>`

NODE N0 deps=- done=plan-dag.sh lane=agent :: Write this plan — the DAG map itself, the plan/ kind-home, and the DAG-shape criteria (the G0 dog-food node)
NODE N1 deps=N0 done=frontier.sh lane=agent :: Frontier deriver — mechanize node-state derivation (criteria-on-main; dispositions) and surface the ready frontier as a d-start seam (surfaced, never auto-executed)
NODE N2 deps=N0 done=disposition lane=operator :: DECIDE the product home — in-repo product kind vs commission-per-repo (G2; everything product-shaped waits on this)
NODE N3 deps=N0 done=d-commission.sh lane=agent :: d-commission intake discipline — brief → spine → executable acceptance criteria → regime check → freeze → decompose into enqueued nodes (G1; the queue's producer)
NODE N4 deps=N2 done=rt-bootstrap.sh lane=agent :: dyad-rt bootstrap — propagate floor/wrappers/enforcer/check/CI into a fresh commission repo (contingent: executes only if N2 disposes commission-per-repo; else struck by replan)
NODE N5 deps=N0 done=pr-experience.sh lane=agent :: Right-half experience path — commission PRs must carry "how to see it working" (G5)
NODE N6 deps=N0 done=telos-metering.sh lane=agent :: Telos metering — reflect/ ledger convention: turns-to-spine / turns-to-criteria / rework, per node (G7)
NODE N7 deps=N2,N3 done=commission-1-intake.sh lane=dyad :: First commission intake — Operator supplies a real brief; d-commission runs; G3/G4/G6 decompose into NEW nodes against the real stack (not pre-specced here — form waits for the spine)
NODE N8 deps=N0 done=provenance.sh lane=agent :: op-provenance enforcement — no Act without ingested intent; binds ARTIFACT mutations only (durability carved out as state capture); path-derived commit classes + CI-level authority; full design in "N8 design notes" below

DISPOSITION N2: TODO

### N8 design notes (Operator inputs, 2026-07-07 — intent detail, not status)

- **Carve-out (Operator strike on the first draft):** "mutate" = *actual artifacts* (plans,
  criteria, anchor, records, code), not *state artifacts*. State capture for resume is
  Observe-phase capture, not an Act — exempt as a class, no Sense lineage required.
- **Enforcement design (Operator-recommended):** consolidate state files in a **single
  kind-home** (`.dyad-state/`, Operator-named 2026-07-07; registered at N8 execution — not before; no empty form). A commit's
  class is then **derived from its paths, never self-declared**: touches only `.dyad-state/` →
  state-capture (exempt); touches anything else → artifact mutation → must resolve to a
  `Node:<id>` in this plan (`intake=#issue` upstream refs per *inbox, never truth*).
- **Authority at GitHub CI (Operator-recommended):** the PR gate is the authoritative enforcer —
  remote ground, immune to local `--no-verify`; the pre-commit floor remains the friendly early
  steering vector. Operator merges exempt.
- **WIP checkpoints** of in-flight node work touch artifact paths and simply carry their node's
  trailer — op-durability and op-provenance partition commit-space cleanly instead of colliding.
- The **op-provenance anchor entry lands WITH the mechanism**, never before it (no
  asserted-but-unwired invariant).

## Recommended pick order (proposal — the frontier is the fact, this is the preference)

Once N0 merges, the frontier is {N1, N2, N3, N5, N6, N8}. Recommended: **N1 first** (the queue
becomes self-deriving — every later node benefits), then **N8** (the provenance floor — from it
onward every node's work is traced, closing the SPAOR bypass the Operator probed 2026-07-07),
then **N3**, then **N5/N6** (small, independent). **N2 runs on the Operator's clock**, not the
agent's WIP — disposing it any time unblocks N4 (conditionally) and, with N3, the commission
itself (N7).

## Why the nodes are not GitHub issues (Operator probe, 2026-07-07)

Probed: shouldn't nodes be gh-issues for off-device durability and single source of truth?
Decided: **no — the plan file is the node home**, on grounds already ratified in our dialectic:

- **Durability is equal.** Pushed/merged, this file lives on GitHub — same off-device class as
  issues, plus full version history.
- **Single-SoT favors the file.** Issues would add a *second writer* beside the repo — the exact
  split that gave dyad-wu-wei three coexisting "active" pointers (labels-as-SoT, local drift, sync
  discarding edits — `dialectic/2026-07-06-concurrency-fsm-evaluation.md` C2, `retro-1793`).
- **Issue state is stored and UI-mutable** — open/closed is a status flag a click can flip. Node
  state here is **derived** (criteria-on-main ∧ check-green); no click can fake it (C3).
- **The merge-gate holds.** Replanning is a PR the Ratifier seals; issue edits bypass the
  Operator's gate entirely.
- **`./check` can reach the file** — the DAG's shape is re-proven on every merge, on all three OS
  legs. Issues are API objects outside the criteria's ground.
- **Conceded (the probe's real find):** issues excel as an **async intent inbox** — filed from
  anywhere, no git client, exactly G0's "intent needs somewhere durable to land mid-execution."
  Sanctioned future option for N3's intake: *issue = proposed intent → d-commission → ratified
  node via PR.* **Inbox, never truth.**

## Deliberately absent

- **G3/G4/G6 nodes** (behavioral real-half, run-and-observe, dependency hygiene): stack-dependent;
  N7's intake creates them against the real commission. Pre-speccing them here would be form ahead
  of the spine — the readiness report's own confound.
- **G8 (concurrency ceiling):** stays deferred. This plan introduces zero concurrency: nodes are
  sequential, only *temporally non-adjacent*.
