#!/usr/bin/env bash
# Acceptance criteria for plan node N13 — bin/_node, the issue-as-node STATIC schema (the
# issues-as-home flip, N11). Conformance is PURE (body text + label list → pass/fail), so it is
# proven here with NO network: valid node-issues pass, malformed ones fail, and parse-body extracts
# the edges/done-condition. Dynamic transition rules are N14's guard, deliberately NOT tested here.
here="$(cd "$(dirname "$0")" && pwd)"; repo="$(cd "$here/.." && pwd)"
source "$here/_lib.sh"
cd "$repo" || exit 1
NODE="$repo/bin/_node"

assert "committed executable (git 100755): bin/_node" \
  bash -c '[ "$(git ls-files -s bin/_node | cut -d" " -f1)" = "100755" ]'

# A well-formed node-issue body.
good_body="$(printf 'Intent: build the thing.\n\nDepends-on: #12, #13\nDone: state-guard.sh\n')"
root_body="$(printf 'Intent: a root node, no deps.\n\nDone: disposition\n')"

# parse-body extracts edges + done-condition
po="$(printf '%s' "$good_body" | "$NODE" parse-body -)"
assert "parse-body extracts Depends-on edges"   bash -c 'printf "%s" "'"$po"'" | grep -q "^deps=#12, #13$"'
assert "parse-body extracts the done-condition" bash -c 'printf "%s" "'"$po"'" | grep -q "^done=state-guard.sh$"'
assert "parse-body: no Depends-on → deps=-" \
  bash -c 'printf "%s" "'"$root_body"'" | "'"$NODE"'" parse-body - | grep -q "^deps=-$"'

# validate — the conforming cases PASS
v() { printf '%s' "$1" | "$NODE" validate --body - --labels "$2"; }
assert "valid node-issue (deps + done + one status) passes"  v "$good_body" "status:clarify"
assert "valid root node (no deps, disposition done) passes"  v "$root_body" "status:dispose,ws:x"
assert "each lane accepted: execute"                         v "$good_body" "status:execute"
assert "each lane accepted: blocked"                         v "$good_body" "status:blocked"

# validate — the malformed cases FAIL
nv() { ! printf '%s' "$1" | "$NODE" validate --body - --labels "$2"; }
assert "reject: zero status labels"          nv "$good_body" "ws:x"
assert "reject: two status labels"           nv "$good_body" "status:clarify,status:execute"
assert "reject: unknown status lane"         nv "$good_body" "status:frobnicate"
assert "reject: missing Done: line"          nv "$(printf 'Intent only.\n')" "status:clarify"
assert "reject: malformed Done value"        nv "$(printf 'x\n\nDone: Foo.SH\n')" "status:clarify"
assert "reject: malformed dep (no #)"        nv "$(printf 'x\n\nDepends-on: 12\nDone: a.sh\n')" "status:clarify"

# create refuses to mint a non-conforming node-issue (no network reached: validation fails first).
assert "create validates before minting (rejects no --done)" \
  bash -c '! "'"$NODE"'" create --title T --status clarify 2>/dev/null'

assert_done
