#!/usr/bin/env bats

# Tests for the check_link()/report() logic in scripts/dotfiles-doctor.
# Sources the script (which bails at the BASH_SOURCE guard) to call the
# functions in isolation.

SCRIPT_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"

setup() {
  TMP="$(mktemp -d)"
  # shellcheck source=/dev/null
  source "$SCRIPT_DIR/scripts/dotfiles-doctor"
  problems=0
}

teardown() {
  rm -rf "$TMP"
}

@test "correct symlink: quiet and no problem" {
  echo content > "$TMP/src"
  ln -s "$TMP/src" "$TMP/dest"
  run check_link "$TMP/src" "$TMP/dest"
  [[ "$status" -eq 0 ]]
  [[ -z "$output" ]]
}

@test "correct symlink counts as OK, not a problem" {
  echo content > "$TMP/src"
  ln -s "$TMP/src" "$TMP/dest"
  check_link "$TMP/src" "$TMP/dest" >/dev/null
  [[ "$problems" -eq 0 ]]
}

@test "verbose lists OK links" {
  echo content > "$TMP/src"
  ln -s "$TMP/src" "$TMP/dest"
  DOCTOR_VERBOSE=1 run check_link "$TMP/src" "$TMP/dest"
  [[ "$output" == *"OK"* ]]
}

@test "missing destination: reports MISSING and counts a problem" {
  echo content > "$TMP/src"
  run check_link "$TMP/src" "$TMP/dest"
  [[ "$output" == *"MISSING"* ]]
  check_link "$TMP/src" "$TMP/dest" >/dev/null
  [[ "$problems" -eq 1 ]]
}

@test "symlink to wrong target: reports WRONG with expected" {
  echo content > "$TMP/src"
  ln -s "$TMP/elsewhere" "$TMP/dest"
  run check_link "$TMP/src" "$TMP/dest"
  [[ "$output" == *"WRONG"* ]]
  [[ "$output" == *"expected"* ]]
}

@test "real file where a symlink is expected: reports NOTLINK and diffs" {
  printf 'repo\n' > "$TMP/src"
  printf 'local\n' > "$TMP/dest"
  run check_link "$TMP/src" "$TMP/dest"
  [[ "$output" == *"NOTLINK"* ]]
  [[ "$output" == *"-repo"* ]]
  [[ "$output" == *"+local"* ]]
}

@test "dangling symlink to the expected source: reports BROKEN" {
  ln -s "$TMP/src" "$TMP/dest"
  run check_link "$TMP/src" "$TMP/dest"
  [[ "$output" == *"BROKEN"* ]]
}
