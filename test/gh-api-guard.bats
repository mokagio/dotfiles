#!/usr/bin/env bats

# Tests for claude/hooks/gh-api-guard.sh

SCRIPT_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
HOOK="$SCRIPT_DIR/claude/hooks/gh-api-guard.sh"

run_hook() {
  jq -n --arg c "$1" '{tool_name:"Bash",tool_input:{command:$c}}' | "$HOOK"
}

assert_allows() {
  [[ -z "$(run_hook "$1")" ]]
}

assert_asks() {
  [[ "$(run_hook "$1" | jq -r '.hookSpecificOutput.permissionDecision')" == "ask" ]]
}

@test "plain GET passes through" {
  assert_allows "gh api repos/o/r/pulls/336/reviews/1"
}

@test "explicit write method asks" {
  assert_asks "gh api -X POST repos/o/r/pulls/1/reviews -f event=APPROVE"
}

@test "heart reaction on a PR review comment is allowed" {
  assert_allows "gh api -X POST repos/o/r/pulls/comments/3387252395/reactions -f content=heart --jq '.content'"
}

@test "heart reaction with a shell variable id is allowed" {
  assert_allows 'for id in 1 2; do gh api -X POST repos/o/r/pulls/comments/$id/reactions -f content=heart; done'
}

@test "heart reaction with a braced variable id is allowed" {
  assert_allows 'gh api -X POST repos/o/r/issues/comments/${id}/reactions -f content=heart'
}

@test "+1 reaction on an issue comment is allowed" {
  assert_allows "gh api -X POST repos/o/r/issues/comments/123/reactions -f content=+1"
}

@test "quoted +1 reaction on an issue is allowed" {
  assert_allows "gh api -X POST repos/o/r/issues/42/reactions -f 'content=+1'"
}

@test "other reaction types still ask" {
  assert_asks "gh api -X POST repos/o/r/issues/42/reactions -f content=laugh"
  assert_asks "gh api -X POST repos/o/r/pulls/comments/9/reactions -f content=rocket"
}

@test "reaction content with allowed prefix still asks" {
  assert_asks "gh api -X POST repos/o/r/issues/42/reactions -f content=heartfelt"
}

@test "command substitution in the id position still asks" {
  assert_asks 'gh api -X POST repos/o/r/issues/$(date)/reactions -f content=heart'
}
