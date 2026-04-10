#!/usr/bin/env bats

# Tests for scripts/brief

SCRIPT_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
BRIEF="$SCRIPT_DIR/scripts/brief"

setup() {
  LOG_DIR="$(mktemp -d)"
  export BRIEF_PROJECT="test"
  export BRIEF_AGENT="test"
}

teardown() {
  rm -rf "$LOG_DIR"
}

@test "success: prints compact line and exits 0" {
  run "$BRIEF" my-label -- echo "hello"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"✓ my-label"* ]]
  [[ "$output" == *"[log:"* ]]
}

@test "success: creates log file with command output" {
  output="$("$BRIEF" my-label -- echo "hello world")"
  log_path="$(echo "$output" | sed -n 's/.*\[log: \(.*\)\].*/\1/p')"
  [[ -f "$log_path" ]]
  [[ "$(cat "$log_path")" == "hello world" ]]
}

@test "failure: replays output to stderr and preserves exit code" {
  run "$BRIEF" my-label -- bash -c 'echo "error msg" >&2; exit 42'
  [[ "$status" -eq 42 ]]
  [[ "$output" == *"error msg"* ]]
}

@test "failure: log file still exists with output" {
  # Run and capture stderr to find the log path from a subsequent success
  # We can verify by checking /tmp/brief-logs/test/ has a file
  "$BRIEF" my-label -- bash -c 'echo "logged"; exit 1' 2>/dev/null || true
  log_count="$(find /tmp/brief-logs/test -name '*-test-my-label.log' -newer /tmp -print 2>/dev/null | wc -l)"
  [[ "$log_count" -gt 0 ]]
}

@test "label slugification: uppercase and special chars" {
  run "$BRIEF" "MY Label!" -- echo "ok"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"✓ MY Label!"* ]]
}

@test "BRIEF_COLOR=1 enables color in non-TTY" {
  result="$(BRIEF_COLOR=1 "$BRIEF" my-label -- echo "ok")"
  # Check for ANSI escape codes (green: \033[32m)
  [[ "$result" == *$'\033[32m'* ]]
}

@test "NO_COLOR disables color even with BRIEF_COLOR=1" {
  result="$(NO_COLOR=1 BRIEF_COLOR=1 "$BRIEF" my-label -- echo "ok")"
  # Should NOT contain ANSI escape codes
  [[ "$result" != *$'\033[32m'* ]]
  [[ "$result" == *"✓ my-label"* ]]
}

@test "missing -- separator exits 2" {
  run "$BRIEF" label echo "hello"
  [[ "$status" -eq 2 ]]
}

@test "too few args exits 2" {
  run "$BRIEF" label
  [[ "$status" -eq 2 ]]
}

@test "no args exits 2" {
  run "$BRIEF"
  [[ "$status" -eq 2 ]]
}
