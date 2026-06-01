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
  warnings=0
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

@test "env var set to an existing dir: quiet, no problem, no warning" {
  export DOCTOR_TEST_VAR="$TMP"
  run check_env "DOCTOR_TEST_VAR|dir|notes root"
  [[ "$status" -eq 0 ]]
  [[ -z "$output" ]]
  check_env "DOCTOR_TEST_VAR|dir|notes root" >/dev/null
  [[ "$problems" -eq 0 ]]
  [[ "$warnings" -eq 0 ]]
}

@test "env var set to an existing dir: verbose lists OK with value" {
  export DOCTOR_TEST_VAR="$TMP"
  DOCTOR_VERBOSE=1 run check_env "DOCTOR_TEST_VAR|dir|notes root"
  [[ "$output" == *"OK"* ]]
  [[ "$output" == *"$TMP"* ]]
}

@test "unset env var: reports WARN and counts a warning, not a problem" {
  unset DOCTOR_TEST_VAR
  run check_env "DOCTOR_TEST_VAR|dir|notes root"
  [[ "$output" == *"WARN"* ]]
  [[ "$output" == *"unset"* ]]
  check_env "DOCTOR_TEST_VAR|dir|notes root" >/dev/null
  [[ "$warnings" -eq 1 ]]
  [[ "$problems" -eq 0 ]]
}

@test "dir var pointing at a missing path: reports WARN not a directory" {
  export DOCTOR_TEST_VAR="$TMP/does-not-exist"
  run check_env "DOCTOR_TEST_VAR|dir|notes root"
  [[ "$output" == *"WARN"* ]]
  [[ "$output" == *"not a directory"* ]]
}

@test "kind=any: a set value is OK regardless of filesystem" {
  export DOCTOR_TEST_VAR="anything-goes"
  check_env "DOCTOR_TEST_VAR|any|freeform value" >/dev/null
  [[ "$problems" -eq 0 ]]
  [[ "$warnings" -eq 0 ]]
}
