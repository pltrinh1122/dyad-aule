# Falsifiable self-evaluation — capability gaps before the first build-commission

> **Status:** assessment, 2026-07-07 — Operator-requested (Builder hat: sets direction). Each gap
> is a falsifiable claim: *refute it by pointing at a mechanism that exists.* Closing gaps is NOT
> started here — the close-order (§3) is a proposal into the Builder lane; the Operator disposes.
> `submitter_dyad_id: dyad-aule · submitter_human: pltrinh1122`
> Real-half: `criteria/commission-readiness.sh` (report shape, not gap closure).

## 0. The meta-gap (the frame every gap below instantiates)

**Everything this dyad has proven is self-referential.** The runtime (dyad-rt), the disciplines
(d-start), the check (`criteria/` + 3-OS CI), the dialectic method — all were built *on the
practice, for the practice*. Every criterion ever written asserts repo-shape or guard-behavior;
the ledger's turn-counts measure identity-slot convergence, not build work. The first commission
is the first time *real* (does what it says) means **runtime behavior of a product**, and *right*
(what the Operator meant) means **experienced behavior**, not a readable diff. The practice's
mechanisms do not yet extend past the practice itself — that is the single sentence under all
seven gaps.

What is **not** a gap (proven, load-bearing, reusable as-is): the boundary runtime and merge-gate
(`bin/_dyad-rt` + floor + wrappers, live-fired end-to-end), session discipline (`d-start` +
`_reconcile`), the criteria/check/CI-matrix pipeline, the falsification method itself, and the
branch→PR→Operator-merge loop — today it ran three concurrent PRs to ratification.

**Amendment (same day, Operator falsification of this report's own frame):** the first draft of
this evaluation carried an unexamined assumption — *that all activity is driven synchronously
through operator↔agent chat-turns*. The Operator refuted it: an execution plan's nodes execute in
sequence but **not temporally adjacent**, so the chat-turn must decouple from execution. That is
G0 below — more foundational than the three gaps the draft called blocking (closing those three
is itself a multi-node plan that will span sessions — the counterexample was the report's own
close-order). This miss is an *instance* of the self-grading confound §1 already named: the gap
the agent could not see was absent from the list until the Operator supplied it.

## 0.5 G0 — No activity queue: chat-turn and execution are coupled. *Severity: MOST FOUNDATIONAL.*

Today, work exists only inside a live session: a turn requests, the same session executes, the
turn ends when the work does. There is no persistent **execution plan** — no queue of plan-nodes
that survives the session, whose nodes are executed *in dependency order but on no particular
clock*, by whichever future session picks them up. Consequences while this holds:

- any plan longer than one session exists only as prose in a chat scroll or a PR body — not as
  ground the practice can derive "what's next" from;
- the Operator can only steer synchronously — intent that arrives mid-execution has nowhere
  durable to land;
- SPAOR's **Plan → Act** joint is unmechanized: Plan output evaporates unless Act is immediate.

**The design is already ratified; only the mechanism is absent.** The concurrency evaluation
(`dialectic/2026-07-06-concurrency-fsm-evaluation.md` §4-5, Operator-merged) fixed the constraints
any queue here must obey:
- **plan = DAG of orthogonal nodes** with pre-req edges (the convergent floor, C1);
- **node state is DERIVED, never stored** — `DONE ⟺ criteria-green ∧ PR-merged` (C3): a stored
  status flag is wu-wei's drift trap, refuted by its own scars (C2). The queue file may hold
  *intent and edges*; it must never hold *truth about completion*;
- **WIP=1 preserved** — the queue decouples **time**, not adds workers: one converging stream,
  nodes sequential, sessions non-adjacent. (This is why G0 is not the deferred G8: no concurrency
  is introduced.)
- **ground on the remote** — the queue lives in the repo, synced via the existing
  branch/PR/merge loop, so enqueued intent is durable and Operator-ratifiable like everything else.

Natural seams, noted not designed (form waits for the spine): `d-start` gains a **frontier** line —
derive and *surface* the ready node(s) at session start (auto-trigger ≠ auto-judgment; executing a
node stays a disposition); the intake discipline (G1) becomes the queue's *producer* (a commission
brief decomposes into enqueued nodes); the reflect ledger (G7) meters turns per node.

- falsification_target: any tracked mechanism holding a cross-session work queue / execution plan
  with derived node state. None exists — `git ls-files` shows no plan kind, and the O3 allowlist
  has no home for one.

## 1. The gaps (falsifiable: each dies to one counterexample artifact)

**G1 — No commission-intake discipline (intent → criteria, mechanized).** *Severity: BLOCKING —
it is the craft's first move.* The telos is minimizing turns to pin down outcome + acceptance
criteria; the ledger's "one rule" (`reflect/convergence-patterns.md`: *elicit spine + criteria
before form*) and the two-payload vocabulary exist as **prose only**. There is no brief template,
no `d-commission` discipline, no gate that freezes executable criteria before build starts, no
regime check (*refuse the job that can't tolerate a mistake → careful human*, `craft_invariants`
corollary). This is precisely the anchor≠engine drift this dyad pins on peers — our best lesson,
unmechanized.
- falsification_target: any tracked artifact that mechanizes intake (a `d-*` discipline, a brief
  form, a criteria-freeze gate). `git ls-files` shows none.

**G2 — No home for product code, and no runtime propagation.** *Severity: BLOCKING — physically.*
The O3 allowlist (`criteria/org-invariants.sh:13`) rejects any `src/` at the root; the README
ontology has no *product* kind; zero product-source files are tracked. Two closes exist and the
choice is the Operator's (Builder hat):
  (a) **in-repo** — register a product kind-home, extend O3; keeps one repo, mixes practice and
      product histories;
  (b) **commission-per-repo** — this repo stays the practice's home, each commission gets its own
      repo. Requires a **bootstrap that propagates dyad-rt** (floor, wrappers, enforcer, launcher,
      `check`, CI) into a fresh repo — which does not exist, and `d-start`/`_reconcile` are
      single-repo tools.
- falsification_target: a registered product kind-home in README/O3, OR a propagation/bootstrap
  mechanism. Neither is tracked.

**G3 — Real-half is shape-grade, not behavior-grade.** *Severity: BLOCKING.* All current criteria
are shell-facts about files and guards. A product needs behavioral verification: a test framework
for the commission's stack, build/lint toolchains, and criteria that assert *what the software
does*. The decision record's C2 boundary (structured facts) arrives on day one of any real product
— the python3-stdlib hatch is codified (`dialectic/2026-07-07-criteria-primitive-sh-vs-py.md` §5)
but has **never been exercised**. Also unpatterned: the split between the product's own test suite
(lives with the product, run by its toolchain) and `criteria/` (acceptance-level, *invokes* the
suite rather than re-implementing it) — without that split, `./check` either misses the product or
drowns in it.
- falsification_target: one behavioral criterion (asserts runtime behavior of built software)
  anywhere in `criteria/`. There are none.

**G4 — No run-and-observe capability.** *Severity: HIGH.* Nothing in the practice can launch a
built artifact and observe it — no run harness, no end-to-end drive, no "exercise the affected
flow before PR" discipline. Static criteria prove a guard fires; they cannot prove an app serves a
request. *Real* for a product is observed behavior; today the dyad can only observe file states
and exit codes.
- falsification_target: any mechanism that runs a product and asserts on its observed behavior.

**G5 — Right-half loop degrades on behavior.** *Severity: HIGH.* Today *right* is sealed by the
Operator reading a diff and merging. For a product, the Operator must **experience** behavior to
judge *right* — a diff of source is not the outcome. Without demoable increments (run
instructions, screenshots/recordings, a "how to see it working" section in every PR), merge-as-
right silently degrades into rubber-stamping what is too expensive to experience — self-
certification by exhaustion, the exact thing `craft_invariants` forbids the agent to do overtly.
- falsification_target: a PR mechanism/template that carries an experience path for the Operator.

**G6 — No dependency / supply-chain hygiene.** *Severity: MEDIUM (BLOCKING for any stack with
dependencies).* The practice repo has zero dependencies **by design** (DR C3/C4); a product will
import. There is no lockfile policy, no pinning rule, no license-compatibility check against this
repo's 0BSD, no vulnerability scan in CI. Sharper: `bin/claude`'s safety envelope already names
the exposed non-git destructive class and rests on an isolated host — **a build that executes
arbitrary package code under bypassPermissions widens that exposure**, and the envelope must be
re-attested by the Operator for commission work, not assumed.
- falsification_target: any tracked dependency policy (lockfile rule, pin rule, scan in CI).

**G7 — Telos not instrumented for build work.** *Severity: MEDIUM.* The ledger counts
turns-per-slot for the identity session, hand-written. No per-commission turn metering exists —
turns-to-spine, turns-to-criteria-freeze, rework turns. Without a baseline from commission #1, the
craft cannot ground the claim that it is improving against its own telos; "fewer turns" would be a
story, not a measurement.
- falsification_target: a reflect/ metering convention (or mechanism) for build tasks.

**G8 — Concurrency ceiling: stays deferred, but the signal has appeared.** *Severity: DEFER
(honest).* DYAD.md defers a concurrency ceiling until real friction sets it. Note: the friction's
first signal arrived today — three same-day PRs all touching `criteria/org-invariants.sh`, with
merge-order compatibility analyzed by hand. Not enough to land a mechanism (WIP=1 fits a first
commission); enough to record that the defer is no longer hypothetical-free.

**self_named_confounds:** *self-grading* — the agent evaluates its own capability; inflation and
blind spots are structural (a gap the agent cannot see is absent from this list, and that absence
is invisible from inside). *Author-fluency:* severity rankings are agent-judged; the Operator may
weigh G5 (their own experience path) higher than the agent can feel. *Form-ahead-of-spine risk:*
closing gaps before a concrete commission exists risks building scaffolding for an imagined
product — G1 and G2 resist this (they are commission-independent); G3/G4/G6 partially depend on
the stack and should close *against* the first real commission, not before it.

## 2. Severity map

| Gap | What it blocks | Close before / with commission |
|---|---|---|
| G0 activity queue (turn↔execution decoupling) | any plan longer than a session — including closing the gaps below | **before — first** |
| G1 intake discipline | the first turn | **before** |
| G2 product home + propagation | the first commit | **before** (decision: Operator) |
| G3 behavioral real-half | the first "done" | with (stack-dependent) |
| G4 run-and-observe | trusting "it works" | with (stack-dependent) |
| G5 right-half experience path | the Operator's judgment | with (first PR) |
| G6 dependency hygiene | any dep-bearing stack | with (first dependency) |
| G7 telos metering | the baseline | with (cheap, from turn one) |
| G8 concurrency ceiling | nothing yet | defer (signal noted) |

## 3. Proposed close-order (Builder lane — the Operator disposes)

1. **G0 first — the queue is the ground everything else lands on.** Build the activity-queue
   mechanism (plan kind-home + derived frontier, per the ratified constraints in §0.5) — and then
   the reflexive move: **this report's remaining close-order becomes the first enqueued plan**,
   each item a node. From that moment the gaps close across sessions on the queue's clock, not
   this chat's — which is the capability being proven.
2. **G2 as an Operator decision, enqueued as a decision-node** — in-repo kind vs
   commission-per-repo. Everything product-shaped waits on it; nothing practice-shaped does.
   (Recommendation: commission-per-repo + a `dyad-rt` bootstrap — but this is a *right* call, not
   the agent's.)
3. **G1 as the queue's producer** — a `d-commission` intake discipline: brief → spine →
   executable acceptance criteria → regime check → freeze → **decompose into enqueued nodes**.
   Commission-independent; exercises the craft's own core loop.
4. **G3+G4 against the real commission** — stand up the stack's test/run harness as part of the
   commission's first PR, criteria invoking (not re-implementing) the product suite; first use of
   the python3-stdlib hatch likely lands here.
5. **G5 in the first PR's shape** — every commission PR carries "how to see it working."
6. **G6 at the first dependency; G7 from turn one** (a reflect/ ledger row per commission — and
   per node, once G0 exists).
7. **G8 stays deferred** until friction forces it. (G0 does not touch it: the queue decouples
   time, not workers.)
