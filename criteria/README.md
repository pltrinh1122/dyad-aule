# criteria/ — executable acceptance criteria (the real-half check)

This bucket is the *real* half of dyad-aule's `craft_invariants`, made computational
(see `DYAD.md`). It answers the craft's second payload — **how you'll know it's done
right** — as code, not prose.

## The discipline

- One file per task: `criteria/<task>.sh`.
- Each file sources `_lib.sh`, makes its acceptance criteria as `assert` lines, and ends
  with `assert_done` (its exit status).
- `../check` runs every `criteria/[!_]*.sh` and fails loud, naming what broke.

## Why it exists

The telos: **minimize the turns it takes to convey both the intended outcome and the
acceptance criteria that prove it.** Writing criteria as executable assertions is the
operator paying *once*, in turns, to stand up the check — after which grounding the
*real* half is free on every run. The *right* half (does it match what I meant?) stays an
operator judgment by design; this bucket never claims to compute it.

Invariant it enforces: **never save a turn by trusting what you haven't checked.**
`../check` is that check.
