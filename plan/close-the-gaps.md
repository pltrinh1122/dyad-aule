# Plan — close the commission-readiness gaps (the contract / index)

> The dyad's first execution plan, and the dog-food of G0 itself: **the plan's own writing is node
> N0 of its own DAG** (`plan/n0.md`). Source of the node set: the readiness evaluation
> (`dialectic/2026-07-07-build-commission-readiness.md`, close-order §3, as amended by the
> Operator's G0 falsification). Shape constraints inherited from the ratified concurrency
> evaluation (`dialectic/2026-07-06-concurrency-fsm-evaluation.md` §4-5): DAG of orthogonal
> nodes · state **derived, never stored** · WIP=1 (the plan decouples *time*, not workers) ·
> grounded on the remote via the branch→PR→merge loop.
>
> **The plan is a collection of self-contained nodes, not this file.** Each node lives in its own
> `plan/<id>.md` (intent + edges + done-condition + design notes). This file is the plan-level
> **contract/index** — how to read node state, the pick-order, and the cross-cutting decision
> records. The grain itself was a decision — see `plan/n10.md`.

## How to read the plan (the queue's contract)

- **The nodes hold intent and edges only — never completion.** There is no status field, by
  invariant (C3: a stored status-pointer structurally drifts). Node state is DERIVED:
  - a `done=<file>.sh` node is **DONE ⟺ its named criteria file is tracked on `origin/main`**
    (CI runs `./check` on every merge, so presence-on-main carries check-green with it);
  - a `done=disposition` node is **DONE ⟺ its `DISPOSITION <id>:` line (in its own node file) is
    non-TODO on `origin/main`** (the Operator edits it; the merge is the ratification);
  - a node is **READY ⟺ all its `deps` are DONE**. The **frontier** is the set of READY nodes;
    WIP=1 means a session picks **one**.
- **The DAG/frontier is DERIVED, never stored as a table here.** Run `bin/_frontier --all` for the
  full node×state index, or `bin/_frontier` for just the ready frontier. Browsing `plan/` as a
  directory *is* the node list.
- Each node lives in `plan/<id>.md` with exactly one machine-parseable `NODE <id> …` line (one
  line, fixed fields) so the frontier stays derivable inside the criteria claim-shape (DR C2); if
  this format outgrows shell parsing, tripwire 5 of
  `dialectic/2026-07-07-criteria-primitive-sh-vs-py.md` governs (python3-stdlib hatch).
- Editing the plan = replanning; it goes through a PR like everything else. Completing a node
  requires **no edit** to any node file — that is the decoupling.

## Node format

`NODE <id> deps=<csv|-> done=<criteria-file|disposition> lane=<agent|operator|dyad> :: <title>`

One `NODE` line per `plan/<id>.md`; the file basename matches the id (`plan/n9.md` ⟺ `NODE N9`).
The grain is enforced by `criteria/plan-grain.sh`; the DAG shape (parse · deps resolve · acyclic ·
dispositions present · derived-not-stored) by `criteria/plan-dag.sh`.

## Recommended pick order (proposal — the frontier is the fact, this is the preference)

Once N0 merges, the frontier is {N1, N2, N3, N5, N6, N8}. Recommended: **N1 first** (the queue
becomes self-deriving — every later node benefits), then **N8** (the provenance floor — from it
onward every node's work is traced, closing the SPAOR bypass the Operator probed 2026-07-07),
then **N3**, then **N5/N6** (small, independent). **N2 runs on the Operator's clock**, not the
agent's WIP — disposing it any time unblocks N4 (conditionally) and, with N3, the commission
itself (N7).

## Why the nodes are not GitHub issues (Operator probe, 2026-07-07)

Probed: shouldn't nodes be gh-issues for off-device durability and single source of truth?
Decided: **no — the repo is the node home**, on grounds already ratified in our dialectic:

- **Durability is equal.** Pushed/merged, the node files live on GitHub — same off-device class as
  issues, plus full version history.
- **Single-SoT favors the repo.** Issues would add a *second writer* beside the repo — the exact
  split that gave dyad-wu-wei three coexisting "active" pointers (labels-as-SoT, local drift, sync
  discarding edits — `dialectic/2026-07-06-concurrency-fsm-evaluation.md` C2, `retro-1793`).
- **Issue state is stored and UI-mutable** — open/closed is a status flag a click can flip. Node
  state here is **derived** (criteria-on-main ∧ check-green); no click can fake it (C3).
- **The merge-gate holds.** Replanning is a PR the Ratifier seals; issue edits bypass the
  Operator's gate entirely.
- **`./check` can reach the files** — the DAG's shape is re-proven on every merge, on all three OS
  legs. Issues are API objects outside the criteria's ground.
- **Conceded (the probe's real find):** issues excel as an **async intent inbox** — filed from
  anywhere, no git client, exactly G0's "intent needs somewhere durable to land mid-execution."
  Sanctioned future option for N3's intake: *issue = proposed intent → d-commission → ratified
  node via PR.* **Inbox, never truth.**

**Addendum (Operator requirement, 2026-07-07):** the Operator's shared mental model needs the
*UI surface* of issues — browsable without burning Agent tokens. Landed as **N9**: every node
gains a gh-issue as a **CI-synced projection of derived state** — the view the Operator reads,
never a writer. The decision above stands unchanged: truth stays in the repo; the mirror is a
reconciled cache with drift surfaced (C2/C3), and the inbox role now has its concrete mechanism
(issue comments → N3 intake → replanning PR).

**Grain addendum (Operator probe, 2026-07-07):** the "not gh-issues" decision defends
repo-vs-external and is independent of monolith-vs-per-node. The plan is now **one self-contained
file per node** (`plan/<id>.md`) — the full rationale is the decision record in `plan/n10.md`. All
five arguments above hold identically for per-node files; truth stays repo-grounded.

## Deliberately absent

- **G3/G4/G6 nodes** (behavioral real-half, run-and-observe, dependency hygiene): stack-dependent;
  N7's intake creates them against the real commission. Pre-speccing them here would be form ahead
  of the spine — the readiness report's own confound.
- **G8 (concurrency ceiling):** stays deferred. This plan introduces zero concurrency: nodes are
  sequential, only *temporally non-adjacent*. (Per-node files make the eventual ceiling
  conflict-free — see `plan/n10.md`.)
