#!/usr/bin/env bats

# Tests for the `link()` function in setup.sh and the `link_matches`
# helper it shares with dotfiles-doctor via lib/links.sh.
# Sources both (setup.sh bails at its BASH_SOURCE guard) so the functions
# are callable in isolation; link() calls link_matches, so the lib is needed.

SCRIPT_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"

setup() {
  TMP="$(mktemp -d)"
  # shellcheck source=/dev/null
  source "$SCRIPT_DIR/setup.sh"
  # shellcheck source=/dev/null
  source "$SCRIPT_DIR/lib/links.sh"
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

@test "dest is a symlink to the expected source: skips quietly" {
  echo "content" > "$TMP/source"
  ln -s "$TMP/source" "$TMP/dest"

  run link "$TMP/source" "$TMP/dest"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"exists already, skipping"* ]]
  [[ "$(readlink "$TMP/dest")" == "$TMP/source" ]]
}

@test "dest is a symlink to the wrong target: warns, leaves it alone" {
  echo "old-content" > "$TMP/old-target"
  ln -s "$TMP/old-target" "$TMP/dest"
  echo "new-content" > "$TMP/source"

  run link "$TMP/source" "$TMP/dest"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"WARNING"* ]]
  [[ "$output" == *"points to"* ]]
  # The wrong symlink is never clobbered.
  [[ "$(readlink "$TMP/dest")" == "$TMP/old-target" ]]
}

@test "dest is a broken symlink: updates it" {
  ln -s "$TMP/old-missing-target" "$TMP/dest"
  echo "new-content" > "$TMP/source"

  run link "$TMP/source" "$TMP/dest"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"Updating broken"* ]]
  [[ "$(readlink "$TMP/dest")" == "$TMP/source" ]]
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

@test "link_matches: symlink pointing at the source matches" {
  echo content > "$TMP/source"
  ln -s "$TMP/source" "$TMP/dest"
  run link_matches "$TMP/dest" "$TMP/source"
  [[ "$status" -eq 0 ]]
}

@test "link_matches: symlink pointing elsewhere does not match" {
  ln -s "$TMP/elsewhere" "$TMP/dest"
  run link_matches "$TMP/dest" "$TMP/source"
  [[ "$status" -ne 0 ]]
}

@test "link_matches: trailing slash on the source is tolerated" {
  mkdir "$TMP/source-dir"
  ln -s "$TMP/source-dir/" "$TMP/dest"
  run link_matches "$TMP/dest" "$TMP/source-dir"
  [[ "$status" -eq 0 ]]
}

@test "link_matches: a real file is not a match" {
  echo real > "$TMP/dest"
  run link_matches "$TMP/dest" "$TMP/source"
  [[ "$status" -ne 0 ]]
}

@test "ensure_real_dir: replaces old managed directory symlink" {
  mkdir -p "$TMP/source-dir"
  ln -s "$TMP/source-dir" "$TMP/dest"

  run ensure_real_dir "$TMP/dest" "$TMP/source-dir"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"Replacing"* ]]
  [[ -d "$TMP/dest" ]]
  [[ ! -h "$TMP/dest" ]]
}

@test "ensure_real_dir: leaves unexpected symlink alone" {
  mkdir -p "$TMP/other-dir"
  mkdir -p "$TMP/source-dir"
  ln -s "$TMP/other-dir" "$TMP/dest"

  run ensure_real_dir "$TMP/dest" "$TMP/source-dir"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"WARNING"* ]]
  [[ -h "$TMP/dest" ]]
  [[ "$(readlink "$TMP/dest")" == "$TMP/other-dir" ]]
}

@test "emit_links: publishes shared Codex assets" {
  local fake_dotfiles="$TMP/dotfiles"
  mkdir -p "$fake_dotfiles/agents/rules"
  mkdir -p "$fake_dotfiles/agents/skills"
  mkdir -p "$fake_dotfiles/claude/skills"
  mkdir -p "$fake_dotfiles/codex/hooks"
  touch "$fake_dotfiles/codex/hooks.json"
  mkdir -p "$TMP/home"

  run env HOME="$TMP/home" bash -c '
    source "$1"
    record_link() { printf "%s -> %s\n" "$1" "$2"; }
    emit_links record_link "$2"
  ' _ "$SCRIPT_DIR/lib/links.sh" "$fake_dotfiles"

  [[ "$status" -eq 0 ]]
  [[ "$output" == *"$fake_dotfiles/agents/AGENTS.md -> $TMP/home/.codex/AGENTS.md"* ]]
  [[ "$output" == *"$fake_dotfiles/codex/hooks.json -> $TMP/home/.codex/hooks.json"* ]]
  [[ "$output" == *"$fake_dotfiles/codex/hooks -> $TMP/home/.codex/hooks"* ]]
}

@test "emit_links: publishes shared skills per-skill to agents and claude" {
  local fake_dotfiles="$TMP/dotfiles"
  mkdir -p "$fake_dotfiles/agents/rules"
  mkdir -p "$fake_dotfiles/agents/skills/ci-monitor"
  mkdir -p "$fake_dotfiles/claude/skills/claude-only"
  mkdir -p "$TMP/home"

  run env HOME="$TMP/home" bash -c '
    source "$1"
    record_link() { printf "%s -> %s\n" "$1" "$2"; }
    emit_links record_link "$2"
  ' _ "$SCRIPT_DIR/lib/links.sh" "$fake_dotfiles"

  # Sources keep the trailing slash the `*/` glob gives them; link_matches
  # strips it on both sides, so the links still compare equal.
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"$fake_dotfiles/agents/skills/ci-monitor/ -> $TMP/home/.agents/skills/ci-monitor"* ]]
  [[ "$output" == *"$fake_dotfiles/agents/skills/ci-monitor/ -> $TMP/home/.claude/skills/ci-monitor"* ]]
  [[ "$output" == *"$fake_dotfiles/claude/skills/claude-only/ -> $TMP/home/.claude/skills/claude-only"* ]]
  [[ "$output" != *"$fake_dotfiles/claude/skills/claude-only/ -> $TMP/home/.agents/skills/claude-only"* ]]
}
