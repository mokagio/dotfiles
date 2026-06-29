#!/usr/bin/env bats

SCRIPT_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
HOOK="$SCRIPT_DIR/codex/hooks/log-prompt.sh"

setup() {
  TMP="$(mktemp -d)"
}

teardown() {
  rm -rf "$TMP"
}

@test "logs Codex prompt payloads" {
  run env HOME="$TMP/home" PROMPT_LOG_DIR="$TMP/logs" bash "$HOOK" <<JSON
{"prompt":"make the Codex prompt logger match Claude","cwd":"/tmp/project"}
JSON

  [[ "$status" -eq 0 ]]
  local log_file
  log_file="$(find "$TMP/logs" -name '*.md' -print -quit)"
  [[ -n "$log_file" ]]
  [[ "$(cat "$log_file")" == *"# Prompt Log"* ]]
  [[ "$(cat "$log_file")" == *"> **cwd:** \`/tmp/project\`"* ]]
  [[ "$(cat "$log_file")" == *"make the Codex prompt logger match Claude"* ]]
}

@test "supports alternate prompt and cwd field names" {
  run env HOME="$TMP/home" PROMPT_LOG_DIR="$TMP/logs" bash "$HOOK" <<JSON
{"userPrompt":"alternate field","workspace":{"current_dir":"/tmp/workspace"}}
JSON

  [[ "$status" -eq 0 ]]
  local log_file
  log_file="$(find "$TMP/logs" -name '*.md' -print -quit)"
  [[ "$(cat "$log_file")" == *"> **cwd:** \`/tmp/workspace\`"* ]]
  [[ "$(cat "$log_file")" == *"alternate field"* ]]
}

@test "skips payloads without a prompt" {
  run env HOME="$TMP/home" PROMPT_LOG_DIR="$TMP/logs" bash "$HOOK" <<JSON
{"cwd":"/tmp/project"}
JSON

  [[ "$status" -eq 0 ]]
  [[ ! -e "$TMP/logs" || -z "$(find "$TMP/logs" -type f -print -quit)" ]]
}
