# .dyad-state/ — state capture (the op-provenance carve-out)

Files here are **state artifacts** for resume/durability — Observe-phase capture, not work
(Operator carve-out, 2026-07-07). The rule this home exists for (op-provenance, plan node N8):

- A commit touching **only** this directory is class-derived as **state capture** — exempt from
  `Node:` lineage. The class is derived from paths, never self-declared.
- A commit touching anything else is an **artifact mutation** and must carry a `Node: <id>`
  trailer resolving to `plan/` — enforced at the `.githooks/commit-msg` floor (early steering)
  and authoritatively at the CI PR gate.

Keep real work out of here: parking an artifact in `.dyad-state/` to dodge provenance is visible
in the diff and reads exactly like what it is.
