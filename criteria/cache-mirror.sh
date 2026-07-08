#!/usr/bin/env bash
# Acceptance criteria for plan node N15 — bin/_cache, the issues→local-cache mirror (issues-as-home
# flip, N11). The record→cache transform is PURE, so it is proven here with NO network. The cache is
# Observe-phase capture (home under .dyad-state/ ⇒ provenance-exempt), a derived view, never a writer.
here="$(cd "$(dirname "$0")" && pwd)"; repo="$(cd "$here/.." && pwd)"
source "$here/_lib.sh"
cd "$repo" || exit 1
C="$repo/bin/_cache"

assert "committed executable (git 100755): bin/_cache" \
  bash -c '[ "$(git ls-files -s bin/_cache | cut -d" " -f1)" = "100755" ]'

# PURE render: TSV <number> <state> <status> <deps> <done> <title> → cache lines.
rec_exec="$(printf '42\topen\texecute\t#12, #13\tstate-guard.sh\tBuild the guard\n')"
rec_done="$(printf '7\tclosed\t\t-\tprovenance.sh\tShipped node\n')"
rec_root="$(printf '3\topen\tclarify\t\t\tRoot intent\n')"
out="$(printf '%s\n%s\n%s\n' "$rec_exec" "$rec_done" "$rec_root" | "$C" render)"
has() { printf '%s\n' "$out" | grep -qE "$1"; }

assert "render: execute node keeps status + deps + done + title" \
  has '^CACHE-NODE #42 status=execute deps=#12, #13 done=state-guard.sh :: Build the guard$'
assert "render: closed issue renders status=done"       has '^CACHE-NODE #7 status=done .* :: Shipped node$'
assert "render: empty deps → deps=-"                    has '^CACHE-NODE #3 .* deps=- '
assert "render: empty done → done=-"                    has '^CACHE-NODE #3 .* done=- '

# PURE path is network-free (green with a failing gh shadowing PATH).
ngh="$(mktemp -d)"; printf '#!/bin/sh\nexit 99\n' >"$ngh/gh"; chmod +x "$ngh/gh"
assert "render needs no network" \
  bash -c 'printf "9\topen\texecute\t-\ta.sh\tt\n" | PATH="'"$ngh"':$PATH" "'"$C"'" render | grep -q "^CACHE-NODE #9"'
rm -rf "$ngh"

# The cache is Observe-phase capture: its home is under .dyad-state/ (provenance-exempt state-capture).
assert "cache home is under .dyad-state/ (provenance-exempt)" \
  grep -qE 'CACHE_DIR_DEFAULT="\.dyad-state/' bin/_cache
assert "cache is one-way (never writes back to the issue truth)" \
  bash -c '! grep -qE "gh issue (edit|close|create|comment)" bin/_cache'
assert "state kind-home .dyad-state/ exists (the cache lands there)" test -d .dyad-state

assert_done
