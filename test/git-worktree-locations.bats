#!/usr/bin/env bats

SCRIPT_DIR=$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)
DELETE_SCRIPT="$SCRIPT_DIR/scripts/git-worktree-delete"
PRUNE_SCRIPT="$SCRIPT_DIR/scripts/git-worktree-prune"

setup() {
  export TMP_ROOT
  TMP_ROOT=$(mktemp -d)
  export HOME="$TMP_ROOT/home"
  mkdir -p "$HOME/Developer"

  remote="$TMP_ROOT/remote.git"
  git -C "$TMP_ROOT" init --bare "$remote" >/dev/null

  export REPO="$TMP_ROOT/repo"
  git clone "$remote" "$REPO" >/dev/null 2>&1
  git -C "$REPO" switch -c trunk >/dev/null
  git -C "$REPO" config user.name "Test User"
  git -C "$REPO" config user.email "test@example.com"
  git -C "$REPO" config commit.gpgsign false

  echo base > "$REPO/file.txt"
  git -C "$REPO" add file.txt
  git -C "$REPO" commit -m "Initial commit" >/dev/null
  git -C "$REPO" push -u origin trunk >/dev/null 2>&1
}

teardown() {
  rm -rf "$TMP_ROOT"
}

@test "git-worktree-delete removes preferred-root worktrees by name" {
  preferred_root="$HOME/Developer/git-worktrees/$(basename "$REPO")"
  git -C "$REPO" worktree add "$preferred_root/feature-a" -b feature-a origin/trunk >/dev/null

  run env HOME="$HOME" bash -c 'cd "$1" && "$2" -y feature-a' _ "$REPO" "$DELETE_SCRIPT"

  [ "$status" -eq 0 ]
  [ ! -d "$preferred_root/feature-a" ]

  run git -C "$REPO" worktree list --porcelain

  [ "$status" -eq 0 ]
  [[ "$output" != *"feature-a"* ]]
}

@test "git-worktree-prune inspects preferred and legacy roots" {
  preferred_root="$HOME/Developer/git-worktrees/$(basename "$REPO")"
  git -C "$REPO" worktree add "$preferred_root/feature-a" -b feature-a origin/trunk >/dev/null
  git -C "$REPO" worktree add "$REPO/.git-worktrees/feature-b" -b feature-b origin/trunk >/dev/null

  run env HOME="$HOME" "$PRUNE_SCRIPT" -n "$REPO"

  [ "$status" -eq 0 ]
  [[ "$output" == *"$preferred_root"* ]]
  [[ "$output" == *"$REPO/.git-worktrees"* ]]
  [[ "$output" == *"WOULD DELETE feature-a"* ]]
  [[ "$output" == *"WOULD DELETE feature-b"* ]]
}
