#!/usr/bin/env bats

SCRIPT_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
STATUS_LINE='status_line = ["model", "context-remaining", "current-dir", "git-branch"]'

setup() {
  TMP="$(mktemp -d)"
}

teardown() {
  rm -rf "$TMP"
}

run_ensure_codex_status_line() {
  run env HOME="$TMP/home" CODEX_CONFIG="$TMP/home/.codex/config.toml" bash -c '
    source "$1"
    ensure_codex_status_line
  ' _ "$SCRIPT_DIR/setup.sh"
}

@test "creates Codex config with status line" {
  run_ensure_codex_status_line

  [[ "$status" -eq 0 ]]
  [[ "$(cat "$TMP/home/.codex/config.toml")" == *"[tui]"* ]]
  [[ "$(cat "$TMP/home/.codex/config.toml")" == *"$STATUS_LINE"* ]]
}

@test "adds status line without replacing machine config" {
  mkdir -p "$TMP/home/.codex"
  cat > "$TMP/home/.codex/config.toml" <<'TOML'
[projects."/tmp/example"]
trust_level = "trusted"
TOML

  run_ensure_codex_status_line

  [[ "$status" -eq 0 ]]
  [[ "$(cat "$TMP/home/.codex/config.toml")" == *'[projects."/tmp/example"]'* ]]
  [[ "$(cat "$TMP/home/.codex/config.toml")" == *"$STATUS_LINE"* ]]
}

@test "replaces an existing status line in the tui section" {
  mkdir -p "$TMP/home/.codex"
  cat > "$TMP/home/.codex/config.toml" <<'TOML'
[tui]
status_line = ["current-dir"]

[hooks.state]
TOML

  run_ensure_codex_status_line

  [[ "$status" -eq 0 ]]
  [[ "$(grep -c '^status_line =' "$TMP/home/.codex/config.toml")" -eq 1 ]]
  [[ "$(cat "$TMP/home/.codex/config.toml")" == *"$STATUS_LINE"* ]]
  [[ "$(cat "$TMP/home/.codex/config.toml")" == *"[hooks.state]"* ]]
}
