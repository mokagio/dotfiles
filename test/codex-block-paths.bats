#!/usr/bin/env bats

# Tests for codex/hooks/block-paths.sh
#
# Uses synthetic patterns like `.fake-vault` so the test inputs don't
# accidentally trip the real block-paths hook configured in this user's
# Claude Code settings (which blocks `.a8c-secrets`).
#
# The Codex hook is not a port of the Claude one and does not share its
# behaviour; see the divergence cases at the bottom.

SCRIPT_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
SCRIPT="$SCRIPT_DIR/codex/hooks/block-paths.sh"

# Pipe JSON to the hook with the given patterns as args.
# Usage: invoke '<json>' [pattern...]
invoke() {
  local input="$1"
  shift
  echo "$input" | "$SCRIPT" "$@"
}

# --- no args ---------------------------------------------------------------

@test "no args: any command is allowed (no patterns configured)" {
  run invoke '{"tool_name":"Bash","tool_input":{"command":"cat ~/.fake-vault/foo"}}'
  [[ "$status" -eq 0 ]]
}

# --- path spellings --------------------------------------------------------
#
# A bare pattern is anchored to the home directory, and each spelling of it
# has to match: an agent may write any of the three.

@test "tilde path blocks" {
  run invoke '{"tool_name":"Bash","tool_input":{"command":"cat ~/.fake-vault/foo"}}' .fake-vault
  [[ "$status" -eq 2 ]]
}

@test "expanded absolute path blocks" {
  run invoke "{\"tool_name\":\"Bash\",\"tool_input\":{\"command\":\"cat $HOME/.fake-vault/foo\"}}" .fake-vault
  [[ "$status" -eq 2 ]]
}

@test "unexpanded \$HOME path blocks" {
  run invoke '{"tool_name":"Bash","tool_input":{"command":"cat \"$HOME/.fake-vault/foo\""}}' .fake-vault
  [[ "$status" -eq 2 ]]
}

@test "blocked dir itself blocks" {
  run invoke '{"tool_name":"Bash","tool_input":{"command":"cat ~/.fake-vault"}}' .fake-vault
  [[ "$status" -eq 2 ]]
}

# --- every tool is covered, not just Bash ----------------------------------
#
# Codex edits files through `apply_patch`, which carries no command string;
# the hook matches the whole serialised input so those still block.

@test "Read of a blocked path blocks" {
  run invoke '{"tool_name":"Read","tool_input":{"file_path":"~/.fake-vault/foo"}}' .fake-vault
  [[ "$status" -eq 2 ]]
}

@test "Write to a blocked path blocks" {
  run invoke '{"tool_name":"Write","tool_input":{"file_path":"~/.fake-vault/foo"}}' .fake-vault
  [[ "$status" -eq 2 ]]
}

@test "Edit of a blocked path blocks" {
  run invoke '{"tool_name":"Edit","tool_input":{"file_path":"~/.fake-vault/foo"}}' .fake-vault
  [[ "$status" -eq 2 ]]
}

@test "apply_patch touching a blocked path blocks" {
  run invoke '{"tool_name":"apply_patch","tool_input":{"input":"*** Update File: ~/.fake-vault/foo"}}' .fake-vault
  [[ "$status" -eq 2 ]]
}

# --- writes, moves and deletes ---------------------------------------------

@test "copying plaintext out blocks" {
  run invoke '{"tool_name":"Bash","tool_input":{"command":"cp ~/.fake-vault/foo /tmp/leak"}}' .fake-vault
  [[ "$status" -eq 2 ]]
}

@test "clobbering plaintext via redirect blocks" {
  run invoke '{"tool_name":"Bash","tool_input":{"command":"printf junk > ~/.fake-vault/foo"}}' .fake-vault
  [[ "$status" -eq 2 ]]
}

@test "deleting plaintext blocks" {
  run invoke '{"tool_name":"Bash","tool_input":{"command":"rm ~/.fake-vault/foo"}}' .fake-vault
  [[ "$status" -eq 2 ]]
}

@test "heredoc bodies are matched, so a piped script cannot smuggle" {
  run invoke '{"tool_name":"Bash","tool_input":{"command":"bash <<EOF\ncat ~/.fake-vault/foo\nEOF"}}' .fake-vault
  [[ "$status" -eq 2 ]]
}

# --- boundary anchors ------------------------------------------------------

@test "similar-prefix dir is allowed" {
  run invoke '{"tool_name":"Bash","tool_input":{"command":"cat ~/.fake-vault-archive/foo"}}' .fake-vault
  [[ "$status" -eq 0 ]]
}

@test "pattern inside a quoted jq expression is allowed" {
  # The pattern is a search string here, not a path token.
  run invoke "{\"tool_name\":\"Bash\",\"tool_input\":{\"command\":\"jq '.fake-vault[]' f.json\"}}" .fake-vault
  [[ "$status" -eq 0 ]]
}

@test "unrelated command is allowed" {
  run invoke '{"tool_name":"Bash","tool_input":{"command":"git status"}}' .fake-vault
  [[ "$status" -eq 0 ]]
}

# --- pattern shapes --------------------------------------------------------

@test "single space-separated arg: matches second pattern" {
  run invoke '{"tool_name":"Bash","tool_input":{"command":"cat ~/.fake-keys/k"}}' ".fake-vault .fake-keys"
  [[ "$status" -eq 2 ]]
}

@test "multiple args: matches second pattern" {
  run invoke '{"tool_name":"Bash","tool_input":{"command":"cat ~/.fake-keys/k"}}' .fake-vault .fake-keys
  [[ "$status" -eq 2 ]]
}

@test "trailing slash on the configured pattern is ignored" {
  run invoke '{"tool_name":"Bash","tool_input":{"command":"cat ~/.fake-vault/foo"}}' .fake-vault/
  [[ "$status" -eq 2 ]]
}

@test "absolute configured pattern blocks outside home" {
  run invoke '{"tool_name":"Bash","tool_input":{"command":"cat /etc/fake-keys/x"}}' /etc/fake-keys
  [[ "$status" -eq 2 ]]
}

@test "specific file pattern blocks" {
  run invoke '{"tool_name":"Bash","tool_input":{"command":"cat ~/.fake-ssh/id_rsa"}}' .fake-ssh/id_rsa
  [[ "$status" -eq 2 ]]
}

# --- divergence from the Claude hook ---------------------------------------
#
# These pin deliberate differences. If either flips, the change was probably
# unintentional.

@test "filename-only verbs still block, unlike the Claude hook" {
  # The Claude hook allows `ls`/`find` because they reveal names, not content.
  # This one has no verb model at all: a match on the path is enough.
  run invoke '{"tool_name":"Bash","tool_input":{"command":"ls ~/.fake-vault/"}}' .fake-vault
  [[ "$status" -eq 2 ]]
}

@test "a bare pattern under a non-home parent is allowed" {
  # Bare patterns expand to home-anchored candidates only, so a same-named
  # directory elsewhere does not match. Configure an absolute pattern to
  # cover one.
  run invoke '{"tool_name":"Bash","tool_input":{"command":"cat /srv/.fake-vault/foo"}}' .fake-vault
  [[ "$status" -eq 0 ]]
}
