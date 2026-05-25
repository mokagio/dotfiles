#!/usr/bin/env bats

# Tests for claude/hooks/block-paths.sh
#
# Uses synthetic patterns like `.fake-secrets` so the test inputs don't
# accidentally trip the real block-paths hook configured in this user's
# Claude Code settings (which blocks `.a8c-secrets`).

SCRIPT_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
SCRIPT="$SCRIPT_DIR/claude/hooks/block-paths.sh"

# Pipe JSON to the hook with the given patterns as args.
# Usage: invoke '<json>' [pattern...]
invoke() {
  local input="$1"
  shift
  echo "$input" | "$SCRIPT" "$@"
}

# --- no args ---------------------------------------------------------------

@test "no args: any read is allowed (no patterns configured)" {
  run invoke '{"tool_name":"Read","tool_input":{"file_path":"/x/.fake-secrets/foo"}}'
  [[ "$status" -eq 0 ]]
}

# --- Read tool -------------------------------------------------------------

@test "Read: inside blocked dir blocks" {
  run invoke '{"tool_name":"Read","tool_input":{"file_path":"/x/.fake-secrets/foo"}}' .fake-secrets
  [[ "$status" -eq 2 ]]
}

@test "Read: blocked dir itself blocks" {
  run invoke '{"tool_name":"Read","tool_input":{"file_path":"/x/.fake-secrets"}}' .fake-secrets
  [[ "$status" -eq 2 ]]
}

@test "Read: similar-prefix dir is allowed (boundary anchor works)" {
  run invoke '{"tool_name":"Read","tool_input":{"file_path":"/x/.fake-secrets-archive/foo"}}' .fake-secrets
  [[ "$status" -eq 0 ]]
}

@test "Read: unrelated path is allowed" {
  run invoke '{"tool_name":"Read","tool_input":{"file_path":"/x/code/main.rb"}}' .fake-secrets
  [[ "$status" -eq 0 ]]
}

@test "Read: specific file pattern blocks" {
  run invoke '{"tool_name":"Read","tool_input":{"file_path":"/x/.fake-ssh/id_rsa"}}' .fake-ssh/id_rsa
  [[ "$status" -eq 2 ]]
}

@test "Read: multi-pattern matches second" {
  run invoke '{"tool_name":"Read","tool_input":{"file_path":"/x/.fake-gnupg/k.asc"}}' .fake-secrets .fake-gnupg
  [[ "$status" -eq 2 ]]
}

# --- arg-shape variants ----------------------------------------------------

@test "single space-separated arg: matches first" {
  run invoke '{"tool_name":"Read","tool_input":{"file_path":"/x/.fake-secrets/foo"}}' ".fake-secrets .fake-gnupg"
  [[ "$status" -eq 2 ]]
}

@test "single space-separated arg: matches second" {
  run invoke '{"tool_name":"Read","tool_input":{"file_path":"/x/.fake-gnupg/k"}}' ".fake-secrets .fake-gnupg"
  [[ "$status" -eq 2 ]]
}

@test "single space-separated arg: unmatched path allowed" {
  run invoke '{"tool_name":"Read","tool_input":{"file_path":"/x/code.rb"}}' ".fake-secrets .fake-gnupg"
  [[ "$status" -eq 0 ]]
}

# --- Bash tool -------------------------------------------------------------

@test "Bash: cat inside blocked dir blocks" {
  run invoke '{"tool_name":"Bash","tool_input":{"command":"cat ~/.fake-secrets/foo"}}' .fake-secrets
  [[ "$status" -eq 2 ]]
}

@test "Bash: ls is allowed (filename-revealing, not content-reading)" {
  run invoke '{"tool_name":"Bash","tool_input":{"command":"ls ~/.fake-secrets/"}}' .fake-secrets
  [[ "$status" -eq 0 ]]
}

@test "Bash: find is allowed" {
  run invoke '{"tool_name":"Bash","tool_input":{"command":"find ~/.fake-secrets -type f"}}' .fake-secrets
  [[ "$status" -eq 0 ]]
}

@test "Bash: stat is allowed" {
  run invoke '{"tool_name":"Bash","tool_input":{"command":"stat ~/.fake-secrets/foo"}}' .fake-secrets
  [[ "$status" -eq 0 ]]
}

@test "Bash: jq with pattern inside quoted JQ expression is allowed (false-positive avoidance)" {
  # The pattern appears inside the jq query string, not as a path token —
  # it should NOT trip the matcher.
  run invoke "{\"tool_name\":\"Bash\",\"tool_input\":{\"command\":\"jq '.fake-secrets[]' file.json\"}}" .fake-secrets
  [[ "$status" -eq 0 ]]
}

@test "Bash: similar-prefix dir is allowed" {
  run invoke '{"tool_name":"Bash","tool_input":{"command":"cat ~/.fake-secrets-archive/foo"}}' .fake-secrets
  [[ "$status" -eq 0 ]]
}

@test "Bash: blocked path in the middle of a multi-arg command blocks" {
  run invoke '{"tool_name":"Bash","tool_input":{"command":"cat /tmp/a ~/.fake-secrets/foo /tmp/b"}}' .fake-secrets
  [[ "$status" -eq 2 ]]
}

@test "Bash: cat of specific file pattern blocks" {
  run invoke '{"tool_name":"Bash","tool_input":{"command":"cat ~/.fake-ssh/id_rsa"}}' .fake-ssh/id_rsa
  [[ "$status" -eq 2 ]]
}

@test "Bash: content reader piped to another command still blocks" {
  run invoke '{"tool_name":"Bash","tool_input":{"command":"head -5 ~/.fake-secrets/x | jq ."}}' .fake-secrets
  [[ "$status" -eq 2 ]]
}

# --- other tools -----------------------------------------------------------

@test "Edit (or any other tool) is passed through unaltered" {
  run invoke '{"tool_name":"Edit","tool_input":{"file_path":"/x/.fake-secrets/foo"}}' .fake-secrets
  [[ "$status" -eq 0 ]]
}
