#!/usr/bin/env bash
# Acceptance criteria for op-ui-links (the dyad's UI invariant, Operator-directed 2026-07-08):
# Operator-facing surfaces hyperlink their referenced artifacts, so disposition is click-through,
# never a hunt. Mechanized by bin/_node linkify; this is its real-half. The transform is PURE (base
# passed in), proven with NO network. The anchor must NAME the invariant (no asserted-but-unwired).
here="$(cd "$(dirname "$0")" && pwd)"; repo="$(cd "$here/.." && pwd)"
source "$here/_lib.sh"
cd "$repo" || exit 1
NODE="$repo/bin/_node"
B="https://github.com/o/r/blob/main"

lk() { printf '%s' "$1" | "$NODE" linkify --base "$B"; }

# Done: <criteria> → a markdown link to criteria/<name>.sh
out_done="$(lk "$(printf 'Intent.\n\nDepends-on: #12\nDone: state-guard.sh\n')")"
assert "Done: criteria rendered as a hyperlink" \
  bash -c 'printf "%s" "'"$out_done"'" | grep -qF "Done: [state-guard.sh]('"$B"'/criteria/state-guard.sh)"'

# an explicit repo path in prose → hyperlink
out_path="$(lk "see dialectic/2026-07-08-plan-home-local-vs-issues.md for the ruling")"
assert "repo-path reference rendered as a hyperlink" \
  bash -c 'printf "%s" "'"$out_path"'" | grep -qF "[dialectic/2026-07-08-plan-home-local-vs-issues.md]('"$B"'/dialectic/2026-07-08-plan-home-local-vs-issues.md)"'

# anchor file reference → hyperlink
assert "DYAD.md reference rendered as a hyperlink" \
  bash -c 'printf "see DYAD.md" | "'"$NODE"'" linkify --base "'"$B"'" | grep -qF "[DYAD.md]('"$B"'/DYAD.md)"'

# bare issue/commit refs are left for GitHub to auto-link (not double-processed)
assert "issue ref #12 left bare (GitHub auto-links it)" \
  bash -c 'printf "Depends-on: #12" | "'"$NODE"'" linkify --base "'"$B"'" | grep -qxF "Depends-on: #12"'

# PURE: no network (base passed → no git/gh call needed)
ngh="$(mktemp -d)"; printf '#!/bin/sh\nexit 99\n' >"$ngh/gh"; chmod +x "$ngh/gh"
assert "linkify needs no network when --base given" \
  bash -c 'printf "Done: a.sh\n" | PATH="'"$ngh"':$PATH" "'"$NODE"'" linkify --base "'"$B"'" | grep -q "\[a.sh\]"'
rm -rf "$ngh"

# op-ui-links is ANCHORED (named in DYAD.md) with its mechanism — not asserted-but-unwired.
assert "anchor names op-ui-links"                    grep -qF 'op-ui-links' DYAD.md
assert "anchor points at the mechanism (_node linkify)" grep -qF '_node linkify' DYAD.md
assert "mechanism present: _node linkify"            bash -c '"'"$NODE"'" linkify --base x </dev/null >/dev/null 2>&1'

assert_done
