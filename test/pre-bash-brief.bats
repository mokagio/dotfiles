#!/usr/bin/env bats

# Tests for claude/hooks/pre-bash-brief.sh

SCRIPT_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
HOOK="$SCRIPT_DIR/claude/hooks/pre-bash-brief.sh"

@test "matching command rewrites to brief wrapper" {
  result="$(echo '{"tool_name":"Bash","tool_input":{"command":"pytest -q tests/"}}' | "$HOOK")"
  echo "$result" | jq -e '.hookSpecificOutput.updatedInput.command' >/dev/null
  [[ "$(echo "$result" | jq -r '.hookSpecificOutput.permissionDecision')" == "allow" ]]
  [[ "$(echo "$result" | jq -r '.hookSpecificOutput.updatedInput.command')" == *"brief"* ]]
  [[ "$(echo "$result" | jq -r '.hookSpecificOutput.updatedInput.command')" == *"pytest -q tests/"* ]]
}

@test "exact prefix match with no args" {
  result="$(echo '{"tool_name":"Bash","tool_input":{"command":"pytest"}}' | "$HOOK")"
  [[ "$(echo "$result" | jq -r '.hookSpecificOutput.updatedInput.command')" == *"brief"* ]]
}

@test "multi-word prefix match" {
  result="$(echo '{"tool_name":"Bash","tool_input":{"command":"xcodebuild test -scheme MyApp"}}' | "$HOOK")"
  [[ "$(echo "$result" | jq -r '.hookSpecificOutput.updatedInput.command')" == *"xcodebuild-test"* ]]
  [[ "$(echo "$result" | jq -r '.hookSpecificOutput.updatedInput.command')" == *"xcodebuild test -scheme MyApp"* ]]
}

@test "non-matching command produces no output" {
  run bash -c 'echo "{\"tool_name\":\"Bash\",\"tool_input\":{\"command\":\"ls -la\"}}" | '"'$HOOK'"
  [[ "$status" -eq 0 ]]
  [[ -z "$output" ]]
}

@test "non-Bash tool produces no output" {
  run bash -c 'echo "{\"tool_name\":\"Read\",\"tool_input\":{\"command\":\"pytest\"}}" | '"'$HOOK'"
  [[ "$status" -eq 0 ]]
  [[ -z "$output" ]]
}

@test "empty command produces no output" {
  run bash -c 'echo "{\"tool_name\":\"Bash\",\"tool_input\":{\"command\":\"\"}}" | '"'$HOOK'"
  [[ "$status" -eq 0 ]]
  [[ -z "$output" ]]
}

@test "missing command field produces no output" {
  run bash -c 'echo "{\"tool_name\":\"Bash\",\"tool_input\":{}}" | '"'$HOOK'"
  [[ "$status" -eq 0 ]]
  [[ -z "$output" ]]
}

@test "invalid JSON produces no output" {
  run bash -c 'echo "not json" | '"'$HOOK'"
  [[ "$status" -eq 0 ]]
  [[ -z "$output" ]]
}

@test "label uses hyphen for multi-word prefix" {
  result="$(echo '{"tool_name":"Bash","tool_input":{"command":"npm test"}}' | "$HOOK")"
  [[ "$(echo "$result" | jq -r '.hookSpecificOutput.updatedInput.command')" == *"'npm-test'"* ]]
}

@test "toolName variant is supported" {
  result="$(echo '{"toolName":"Bash","toolInput":{"command":"pytest -v"}}' | "$HOOK")"
  [[ "$(echo "$result" | jq -r '.hookSpecificOutput.updatedInput.command')" == *"brief"* ]]
}
