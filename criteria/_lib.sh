# shellcheck shell=bash
# _lib.sh — tiny assertion helpers for criteria files. Source me; don't run me.
#
#   source "$(dirname "$0")/_lib.sh"
#   assert "<what must be true>" <command that exits 0 iff it is true>
#   ...
#   assert_done      # last line: exit status of the criteria file
#
# Keeps each criteria file terse (reusable criteria = fewer turns, per the ledger).
_fails=0
assert() {                    # assert "<description>" <cmd...>
  local desc="$1"; shift
  if "$@" >/dev/null 2>&1; then
    echo "  ok   $desc"
  else
    echo "  MISS $desc"
    _fails=$((_fails + 1))
  fi
}
# Convenience: assert a file does NOT contain a string (a discharged TODO, a stale flag).
absent() {                    # absent "<description>" <file> <string>
  local desc="$1" file="$2" needle="$3"
  if grep -qF -- "$needle" "$file" 2>/dev/null; then
    echo "  MISS $desc"
    _fails=$((_fails + 1))
  else
    echo "  ok   $desc"
  fi
}
assert_done() { [ "$_fails" -eq 0 ]; }
