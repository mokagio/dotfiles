#!/usr/bin/env bats

# Tests for the `link()` function in setup.sh.
# Sources setup.sh (which bails out at the BASH_SOURCE guard) to make
# `link` callable in isolation.

SCRIPT_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"

setup() {
  TMP="$(mktemp -d)"
  # shellcheck source=/dev/null
  source "$SCRIPT_DIR/setup.sh"
}

teardown() {
  rm -rf "$TMP"
}

@test "missing source: returns 1 and prints ERROR" {
  run link "$TMP/nonexistent" "$TMP/dest"
  [[ "$status" -eq 1 ]]
  [[ "$output" == *"ERROR: source"* ]]
  [[ "$output" == *"does not exist"* ]]
  [[ ! -e "$TMP/dest" ]]
}

@test "source is a dangling symlink: returns 1 (treated as missing)" {
  ln -s "$TMP/no-such-file" "$TMP/dangling-source"
  run link "$TMP/dangling-source" "$TMP/dest"
  [[ "$status" -eq 1 ]]
  [[ "$output" == *"ERROR: source"* ]]
  [[ ! -e "$TMP/dest" ]]
}

@test "source exists, dest does not: creates the symlink" {
  echo "content" > "$TMP/source"
  run link "$TMP/source" "$TMP/dest"
  [[ "$status" -eq 0 ]]
  [[ -h "$TMP/dest" ]]
  [[ "$(readlink "$TMP/dest")" == "$TMP/source" ]]
}

@test "source is a directory: creates a directory symlink" {
  mkdir "$TMP/source-dir"
  run link "$TMP/source-dir" "$TMP/dest"
  [[ "$status" -eq 0 ]]
  [[ -h "$TMP/dest" ]]
  [[ -d "$TMP/dest" ]]
}

@test "dest is an existing symlink: skips, leaves it alone" {
  echo "old-content" > "$TMP/old-target"
  ln -s "$TMP/old-target" "$TMP/dest"
  echo "new-content" > "$TMP/source"

  run link "$TMP/source" "$TMP/dest"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"exists already, skipping"* ]]
  # Symlink still points at the old target.
  [[ "$(readlink "$TMP/dest")" == "$TMP/old-target" ]]
}

@test "dest is a real file: warns and leaves it alone" {
  echo "content" > "$TMP/source"
  echo "real-file" > "$TMP/dest"

  run link "$TMP/source" "$TMP/dest"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"WARNING"* ]]
  [[ "$output" == *"not a symlink"* ]]
  # The real file is untouched.
  [[ ! -h "$TMP/dest" ]]
  [[ "$(cat "$TMP/dest")" == "real-file" ]]
}
