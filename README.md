# dyad-aule

A **dyad** — a human Operator + an agent, practising [The Dyad Practice](https://github.com/The-Dyad-Practice-Commons/the-dyad-practice).
Craft: **building software through intent.** Telos: *minimize the operator↔agent turns it takes to pin
down both what you want and how you'll know it's done right.* Value: **fidelity** — faithful to both
*real* (it does what it says) and *right* (it's what the Operator meant).

- **Machine entry point:** `CLAUDE.md` → **`DYAD.md`** (the loadable anchor: identity, craft, operating-policy).
- **Human entry point:** this file.
- **Registry:** [`commons/directory/dyad-aule.yaml`](commons/directory/dyad-aule.yaml) — our entry in the Commons.

## Repository layout — the single-home map

Each artifact-kind has exactly **one home**. A fact lives in one place; cross-references point, never copy.

| Path | Kind | Single home for |
|---|---|---|
| `DYAD.md` | anchor | who we are — identity, craft, operational + operating-policy invariants |
| `CLAUDE.md` | shim | the machine load instruction (`Read DYAD.md`) |
| `README.md` | front door | outsider orientation + the **organizational invariants** (below) |
| `check` | runner | the real-half check — runs every `criteria/` file |
| `criteria/` | checks | executable acceptance criteria (one file per task) |
| `bin/` | runtime | **dyad-rt** — the launcher (`claude`), physical wrappers (`git`, `gh`), the boundary enforcer (`_dyad-rt`), and the Start Session Discipline (`d-start`, with its internal `_reconcile` helper). Internal scripts carry the `_` prefix (O9). |
| `.githooks/` | runtime floor | git-hook hard floor (`pre-commit`, `pre-push`) — refuses main-mutations even on raw `git` |
| `reflect/` | ledger | the convergence ledger (turns-per-slot, accelerators, turn-sinks) — the home of SPAOR's closing **Reflect** phase (`commons/AGENT.md`). *Term `retro` deprecated 2026-07-07.* |
| `plan/` | queue | the activity queue — a DAG of nodes decoupling chat-turns from execution (SPAOR **Plan**). **One self-contained file per node** (`plan/<id>.md`: intent + edges + done-condition + design notes); `plan/close-the-gaps.md` is the plan-level contract/index; the DAG/frontier is **derived** (`bin/_frontier --all`), never stored. Node state is derived from ground (criteria-on-main; dispositions), never stored — see `plan/close-the-gaps.md` |
| `.dyad-state/` | state | state capture for resume (SPAOR **Observe**) — the op-provenance carve-out: a commit touching **only** this home is state-capture, exempt from `Node:` lineage; everything else is an artifact mutation that must trace to a plan node |
| `dialectic/` | reports | falsifiable reports & cross-dyad analysis (the published home for claims) |
| `dm/` | messages | outbound Dyad Messages, sender-hosted at `dm/<recipient>/` |
| `commons/` | form (submodule) | the shared Dyad-Practice Commons |

## Organizational invariants

Standing rules for how this repo is *organized* — each aligned with a mainstream software convention and,
where possible, **enforced by `./check`** (an invariant we only assert in prose is one we can drift from —
the exact failure our peers exhibit, where the anchor no longer matches the engine; see `dialectic/`).

| # | Invariant | Aligns with (industry) | Enforcement |
|---|---|---|---|
| **O1** | A human landing on the repo is oriented — root `README.md` is the front door. | README as canonical entry point | ✅ `check` — README present |
| **O2** | **Single home / DRY** — every fact has one authoritative home; references point, never duplicate. | single-source-of-truth / DRY | 🧭 discipline (this map is the only layout home) |
| **O3** | **Minimal, predictable root** — each artifact-kind has one directory; root holds only the anchor, entry points, and config. | separation of concerns; legible top-level | ✅ `check` — root allowlist, no stray files |
| **O4** | **Hygiene** — no secrets, build artifacts, scratch, or transient state committed; `.gitignore` enforces it. | `.gitignore` hygiene; no secrets in VCS | ✅ `check` — `.gitignore` present, no cruft tracked |
| **O5** | **Executable, remotely-grounded criteria** — acceptance criteria are runnable (`criteria/` + `./check`) and run in CI on every PR. | CI gates on PR; automated checks | ✅ `check` locally **+ CI on every PR** (`.github/workflows/check.yml`) — closes the local≠remote split-brain in `dialectic/` |
| **O6** | **Branch → PR → Operator-merge** — never commit to `main`; the Operator merges. | protected `main` + PR review | ✅ **dyad-rt** enforces it — `.githooks` floor (fires on raw `git`) + `bin/git`·`bin/gh` wrappers + `bin/_dyad-rt` enforcer, proven by `criteria/dyad-rt.sh`; policy home stays `DYAD.md` → `op-durability`/`op-PR` |
| **O7** | **Public repo declares a license.** | `LICENSE` file on public repos | ✅ **`LICENSE`** — 0BSD (Zero-Clause BSD), the most permissive OSI-approved license (no attribution required) |
| **O8** | **`d-*` names an operator discipline** — the `d-` prefix is reserved for Operator-invoked disciplines (the tokens the Operator types, e.g. `d-start`); internal machinery is named without it. | intent-revealing names; reserved-namespace hygiene | ✅ `check` — `bin/d-*` / `criteria/d-*.sh` must be in the operator-discipline allowlist |
| **O9** | **`_*` marks internal** — a `bin/` script the Operator never invokes directly carries the `_` prefix (`_dyad-rt`, `_reconcile`); public entry points (`claude`, `git`, `gh`, `d-start`) do not. | `_private` naming idiom; public/internal split | ✅ `check` — every `bin/` file is either allowlisted-public or `_`-prefixed |

## Verify

```
./check          # runs every criteria/ file; exits non-zero + names what failed
```

`./check` is the real-half of our `craft_invariants`: acceptance criteria made executable. The *right* half
(does it match what the Operator meant?) stays an Operator judgment — sealed by the merge (O6).

## Links

- **The form:** https://github.com/The-Dyad-Practice-Commons/the-dyad-practice — read `commons/CONTRIBUTING.md` for the canonical rules.
- **Our anchor:** [`DYAD.md`](DYAD.md).
- **Our registry entry:** [`commons/directory/dyad-aule.yaml`](commons/directory/dyad-aule.yaml).
