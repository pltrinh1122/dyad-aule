# Falsifiable report — the plan-node home: local repo-files vs. GitHub issues

> **Self-audit** (dyad-aule auditing its own foundational decision).
> `submitter_dyad_id: dyad-aule · submitter_model: claude-opus-4-8[1m] · submitter_human: pltrinh1122`
> Provenance: Operator probe, 2026-07-08 — *"I may have glossed over the essential reason why we
> need a local plan. Was there a decision record we can review and falsify?"* There was not: the
> reasoning lived only in `plan/close-the-gaps.md` (a contract file, no `falsification_target`),
> and the readiness DR §0.5 borrowed the concurrency eval's *derive-vs-store* ratification to
> license a *different* axis. This FR supplies the missing record. Verdict is the Operator's
> (plan node **N11**); falsifications welcome inline (§7) or as DMs.

## 0. Method & fidelity caveat (read first)

**The decision under audit was never independently argued.** Two orthogonal axes were fused:

- **Axis A — node *state*: derived vs. stored.** Settled and falsifiable:
  `dialectic/2026-07-06-concurrency-fsm-evaluation.md`, claims **C2** (derive-from-ground dominates
  store-as-truth) and **C3** (`DONE ⟺ criteria-green ∧ PR-merged`, never a stored flag), each with
  a `falsification_target`. aule chose **derived**. Not re-litigated here.
- **Axis B — node *home*: local repo-file vs. GitHub issue.** *This FR.* Never adjudicated. The
  readiness DR §0.5 asserts *"the queue lives in the repo"* as *"already ratified"* — citing the
  concurrency eval, which adjudicated **A, not B**. The ratification was inherited, not granted.

**Load-bearing separation:** a GitHub issue can hold a node and still have its *state derived*
(intent in the issue body, `DONE` computed from `criteria-green ∧ PR-merged`, status never stored).
So **C2/C3 do not decide B.** Anyone who says "issues drift, therefore local files" is running the
conflation. Issues *as a status store* drift; issues *as a node-body home with derived state* do
not — that is precisely chiron's design.

**Bias caveat (this cuts both ways — weight both down):**
- **same-human** (`pltrinh1122`) and **same-model** (`claude-opus-4-8[1m]`) as dyad-chiron → double
  flatter-tell. "Local files = our repo, our control, our fidelity" flatters *aule's* self-image;
  "issues already work next door, less code" flatters *chiron's*. Neither is evidence.
- **Sunk cost:** aule already shipped N9 (the issue *mirror*) and N10 (per-file grain) on the
  local-files premise → status-quo bias toward confirming it. Named, discounted.
- **Occam pressure the other way:** issues-as-home *deletes the entire N9 mirror* (no projection,
  no reconciliation, no drift machinery) — a large simplification. Simpler is not automatically
  righter, but the burden is on local-files to justify the extra machinery.
- Method: chiron read as **as-built** (`reflect/interaction-model.md`), not its anchor.

## 1. Comparison criteria (industry-anchored)

The axes that actually separate the two homes — each tied to a mainstream source. State-derivation
(Axis A) is held fixed at *derived* for both columns, so it does not appear.

| # | Criterion | Industry anchor | local repo-files | GitHub issues |
|---|---|---|---|---|
| K1 | **Executable-check reachability** — can `./check` reach the node home and re-prove its shape on every merge, on every OS leg? | CI gates on versioned artifacts | **yes** — `plan/*.md` is in the tree; `plan-dag.sh`/`plan-grain.sh` run in CI | **no** — issues are API objects outside the checkout; a check would need a live authenticated API call, not a file read |
| K2 | **Offline / substrate portability** — works with only `git`, no network, no GitHub? | git's distributed design; `op-portability`/`op-substrate` | **yes** — clone and work on a plane; commission may live off-GitHub | **no** — the node home *is* GitHub; no network → no nodes |
| K3 | **Version history / provenance** — full diff history of intent changes; path-derived commit class | VCS blame/history; `op-provenance` | **strong** — `git log plan/<id>.md`; `Node:` trailer path-derives | moderate — issue edit history exists but is not in the git graph; not path-derivable |
| K4 | **Async intent capture (inbox)** — intent lands mid-execution from anywhere, no git client | ticketing / inbox pattern | **weak** — needs a clone + commit + PR to add a node | **strong** — file/comment from mobile, zero client (G0's "intent needs somewhere durable to land") |
| K5 | **Native observation UI** — lists, threading, notifications, search, mobile, at zero agent-token cost | issue trackers / kanban | **weak** — a directory of files; aule *built N9* to recover this | **strong** — the whole point of issues |
| K6 | **Single-writer / merge-gate integrity** — one authoritative writer; truth sealed by the Operator's merge | SoT / DRY; protected-main | **strong** — the merge-gate *is* the write path | **conditional** — strong *iff* status is derived (not a UI-flippable label); a hand-edit bypasses the gate unless reconciled |
| K7 | **Cross-repo / above-a-single-repo scope** — a home that spans repos (commission-per-repo, N2) | org-level project boards | **weak** — a file lives in one repo | **strong** — issues/projects span repos natively |
| K8 | **Machinery cost / simplicity** — lines of bespoke code to maintain the home | Occam / YAGNI | moderate — parse `plan/*.md` | **cheaper for the board** — deletes the N9 mirror; but adds API glue for every read |

## 2. Steelman — LOCAL repo-files (aule today)

The strongest case, stated to win:

- **K1 is the load-bearing win.** aule's founding move is *the real-half check*: acceptance
  criteria made executable, run on every merge across three OS legs. A plan-node home that `./check`
  **cannot reach** is a home outside the fidelity ground — the DAG shape, the per-file grain, the
  derivation rules would all become un-provable prose again (the exact anchor≠engine drift aule
  pins on its peers). Local files keep the node *inside* the check's reach. Issues cannot be.
- **K2 makes the practice portable by construction.** `op-portability` commits aule to run
  "wherever dyad operators are" and `op-substrate` to a minimal, single-upstream dependency surface.
  A git-only node home honors both: no GitHub dependency for the *truth*, only for the *view*. If a
  future commission runs on GitLab, a private Forgejo, or air-gapped, the plan survives; an
  issues-home does not.
- **K6 without a caveat.** With local files the merge-gate *is* the only write path — there is no
  second surface to hand-edit, so no reconciliation and no drift class exists at all. Issues need a
  reconciler (aule built one — N9) precisely because they can be hand-mutated.
- **K3 provenance is native.** `op-provenance`'s `Node: N9` trailer path-derives to `plan/n9.md`;
  every intent change is a diff in the git graph, not an out-of-band issue edit.
- **Post-N10 the K5 gap shrinks.** Self-contained per-node files make `plan/` a browsable directory
  — a rudimentary board already — and the N9 mirror projects the *rest* of the UI onto issues **as
  a view**, capturing K4/K5 without moving truth. So local-files can *borrow* the issue UI without
  paying the issue-home costs (K1/K2/K6-caveat).

**Local-files' honest weakness:** it loses K4/K5/K7 *natively* and must reconstruct them (N9). That
reconstruction is real machinery (the mirror) — cost it honestly.

## 3. Steelman — GitHub ISSUES as the node home (chiron)

The strongest case, stated to win:

- **K4/K5 are free and native — and aule already conceded issues win them.** `plan/close-the-gaps.md`
  itself admits issues "excel as an async intent inbox … exactly G0's 'intent needs somewhere
  durable to land mid-execution.'" aule then spent a whole node (N9) building a *mirror* to
  claw back the UI it gave up by choosing files. **That mirror is pure deadweight in the
  issues-home world** — the nodes already *are* the issues; there is nothing to project,
  reconcile, or drift-check. Occam (K8): the design with fewer moving parts that delivers the same
  observation surface is issues-home.
- **Derived state is still available — chiron proves coexistence.** chiron holds node intent in the
  issue body and renders its DAG as a *derived* view (`bin/ws`), no committed `WORKSTREAMS.md` to
  drift. So issues-home does **not** force store-as-truth; C2/C3 are satisfiable here (§0). The
  "issues drift" objection applies only to the naive status-label design, not to issues-as-body +
  derived-state.
- **Proven next door at lower execution risk (K5/K8).** Same operator, same model shipped and runs
  the issues-home model. aule's local-files + mirror is bespoke and younger. All else near-equal, the
  running implementation is the safer bet.
- **K7 fits the commission-per-repo future.** If N2 disposes commission-per-repo, work spans many
  repos; issues/projects natively live above a repo, where a per-repo file plan does not.
- **The async loop closes without a mirror.** `d-sense`/`d-land` playback and Operator rulings can
  live *on the node* (comments), asynchronously, over the observation channel — no chat-turn spend,
  no file round-trip. The node is the conversation.

**Issues-home's honest weakness:** it fails K1 and K2 flatly. The node home leaves the git tree —
`./check` cannot re-prove the plan's shape from a local checkout, and nothing works offline or
off-GitHub. Everything rests on GitHub being a permanent substrate assumption.

## 4. The crux claims (falsifiable)

**P1 — the inherited ratification.** *The concurrency eval ratified derive-vs-store (Axis A), never
local-vs-issues (Axis B); the readiness DR §0.5's "queue lives in the repo, already ratified"
inherited authority it was never granted.*
`falsification_target:` a passage in `2026-07-06-concurrency-fsm-evaluation.md` that adjudicates the
node *home* (file vs. issue) independent of state-derivation. If it exists, P1 dies and the decision
was grounded all along.

**P2 — SoT is neutral once state is derived.** *The single-writer / no-second-writer argument does
NOT separate the two homes: both are single-writer if state is derived (files via the merge-gate;
issues via issue-body-single-home + derived status + issue→PR intake). The "issues drift" objection
is an artifact of the status-label design, not of issues-as-home.*
`falsification_target:` an aule invariant that issues-as-body-with-derived-state structurally
violates but local-files satisfies, *other than* K1/K2. (If none exists, SoT drops out of the
decision.)

**P3 — the real differentiator is K1 + K2, and nothing else.** *Strip out the conflated/neutral
axes and the decision reduces to two questions: (a) must executable criteria reach the node home
(K1)? and (b) must the practice run offline / off-GitHub (K2)? Every other axis (K4/K5/K7) favors
issues; K3/K6 are conditional or native-either-way once state is derived.*
`falsification_target:` a third axis, independent of state-derivation, that separates the homes and
is load-bearing for aule's telos — showing the decision is NOT reducible to K1+K2.

**P4 — chiron is not a clean issues-home exemplar.** *chiron stores lifecycle status as `status:*`
labels (a C2 store-as-truth it mitigates with lint + staleness gates), so it is a mixed design, not
a pure issues-body-with-derived-state. Citing chiron as "issues-home works" imports its residual C2
debt.*
`falsification_target:` chiron deriving lifecycle status from ground rather than storing it as a
label that a board click can flip.

## 5. What the decision actually turns on

After P1–P4, the abstract "which is better" dissolves into **one conditional the Operator owns:**

> **Is `./check`-reachability of the node home (K1) and/or offline/off-GitHub portability (K2) a
> load-bearing requirement for aule's telos — or an aspirational nicety?**

- **If K1/K2 are real** (the fidelity ground must reach the plan; commissions may run off-GitHub;
  `op-portability`/`op-substrate` are commitments, not slogans) → **local-files win, for real**, and
  this FR upgrades the decision from *asserted* to *grounded*. The N9 mirror is then justified
  machinery, not deadweight — it is the *price* of keeping truth check-reachable while still getting
  the issue UI.
- **If K1/K2 are aspirational** (GitHub is a permanent substrate; the plan never needs to be
  re-proven by a local `./check`; portability is a someday) → **issues-home wins**, N9 collapses
  from *mirror* to *the nodes themselves* (a large simplification), and N10's per-file grain is
  superseded by one-issue-per-node.

**This is not the agent's call.** It is a scope/regime election (which invariants are load-bearing)
— an Operator disposition (channel #4, Builder/Architect hat).

## 6. Recommendation (falsifiable proposal, not a verdict)

My honest read, stated so it can be attacked: **K1 is load-bearing and decides it for local-files —
conditionally.**

aule's entire identity is the *real-half check made computational* (`craft_invariants`, the whole
`criteria/` + `./check` apparatus, the 3-OS CI matrix). A node home that `./check` cannot reach
would put the plan's own shape — the DAG, the grain, the derivation contract — back outside the
fidelity ground, which is the specific failure aule was built to not have. That is a stronger pull
than every K4/K5/K7 convenience issues offer, *because those are recoverable as a view (N9) while
K1 is not recoverable at all once truth leaves the tree.* K2 reinforces it but is secondary.

So I propose: **local-files remains the node home — now grounded on K1 (check-reachability), with K2
support — and issues keep their conceded role as inbox + observation view (`op-SoT`'s "inbox, never
truth").** Net effect: the FR largely *confirms the current architecture but for a reason it did not
previously have on record* — and, critically, it **retires the wrong reason** (the borrowed C2/C3
SoT argument, P1/P2) and names the right one (K1).

**But I hold this loosely, and here is what would flip me:** if the Operator rules that GitHub is a
permanent substrate assumption and that `./check` never needs to re-prove the plan from a local
checkout, then K1 is moot, issues-home wins on Occam, and I would recommend collapsing N9. The FR's
job is to expose that this is the pivot — not to pretend the pivot is settled.

## 7. Falsification form

Kill any claim with one artifact:
- **P1:** cite the node-home adjudication in the concurrency eval (file:line).
- **P2:** name the invariant issues-as-body-with-derived-state violates but files satisfy, ≠ K1/K2.
- **P3:** name the load-bearing third axis independent of state-derivation.
- **P4:** show chiron deriving status rather than storing labels.
- **The conditional (§5):** the Operator rules K1/K2 load-bearing or aspirational — that *is* the
  disposition (`DISPOSITION N11:`), and it settles the report.

Responses inline (edit this file in a replanning PR) or as a DM (`dm/dyad-aule/<id>.md`).
