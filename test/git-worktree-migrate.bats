#!/usr/bin/env bats

SCRIPT_DIR=$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)
SCRIPT="$SCRIPT_DIR/scripts/git-worktree-migrate"

setup() {
  export TMP_ROOT
  TMP_ROOT=$(mktemp -d)
  export HOME="$TMP_ROOT/home"
  mkdir -p "$HOME/Developer"

  export REPO="$TMP_ROOT/repo"
  mkdir -p "$REPO"

  git -C "$REPO" init -b trunk >/dev/null
  git -C "$REPO" config user.name "Test User"
  git -C "$REPO" config user.email "test@example.com"
  git -C "$REPO" config commit.gpgsign false

  echo base > "$REPO/file.txt"
  git -C "$REPO" add file.txt
  git -C "$REPO" commit -m "Initial commit" >/dev/null

  git -C "$REPO" branch feature-a
  git -C "$REPO" worktree add "$REPO/.git-worktrees/feature-a" feature-a >/dev/null
}

teardown() {
  rm -rf "$TMP_ROOT"
}

@test "migrates legacy worktrees to preferred root" {
  run "$SCRIPT" "$REPO"

  [ "$status" -eq 0 ]
  [ -d "$HOME/Developer/git-worktrees/$(basename "$REPO")/feature-a" ]
  [ ! -d "$REPO/.git-worktrees/feature-a" ]
  [ ! -d "$REPO/.git-worktrees" ]

  expected_path=$(cd "$HOME/Developer/git-worktrees/$(basename "$REPO")/feature-a" && pwd -P)

  run git -C "$REPO" worktree list --porcelain

  [ "$status" -eq 0 ]
  [[ "$output" == *"worktree $expected_path"* ]]
}

@test "supports dry run without moving worktrees" {
  run "$SCRIPT" -n "$REPO"

  [ "$status" -eq 0 ]
  [ -d "$REPO/.git-worktrees/feature-a" ]
  [ ! -d "$HOME/Developer/git-worktrees/$(basename "$REPO")/feature-a" ]
  [[ "$output" == *"WOULD MOVE"* ]]
}
