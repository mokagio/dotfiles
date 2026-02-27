#!/usr/bin/env bash

set -eu

# Ensures Claude Code project memory is shared across git worktrees.
#
# Convention: worktrees live in <repo>/.git-worktrees/<name>/.
# This script detects when the CWD is inside a worktree and symlinks
# its auto-memory directory to the main checkout's memory directory
# (the canonical location).
#
# Designed to run as a UserPromptSubmit hook — fires once per message,
# short-circuits fast when the symlink already exists.

CLAUDE_PROJECTS_DIR="$HOME/.claude/projects"

# Try to read CWD from hook JSON input; fall back to $PWD.
CWD="${PWD}"
if ! [ -t 0 ]; then
  INPUT=$(cat)
  HOOK_CWD=$(echo "$INPUT" | jq -r '.cwd // empty' 2>/dev/null || true)
  if [[ -n "$HOOK_CWD" ]]; then
    CWD="$HOOK_CWD"
  fi
fi

# Only act when inside a .git-worktrees directory.
if [[ "$CWD" != */.git-worktrees/* ]]; then
  exit 0
fi

# Derive the main repo path: strip /.git-worktrees/<name> (and any trailing subpath).
MAIN_REPO="${CWD%%/.git-worktrees/*}"

# Convert absolute paths to Claude's dash-encoded project key.
# /Users/gio/Developer/foo → -Users-gio-Developer-foo
encode_path() {
  echo "$1" | sed 's|^/|-|; s|/|-|g'
}

WORKTREE_KEY=$(encode_path "$CWD")
MAIN_KEY=$(encode_path "$MAIN_REPO")

CANONICAL_MEMORY="$CLAUDE_PROJECTS_DIR/$MAIN_KEY/memory"
WORKTREE_MEMORY="$CLAUDE_PROJECTS_DIR/$WORKTREE_KEY/memory"

# Fast path: symlink already correct.
if [[ -L "$WORKTREE_MEMORY" ]]; then
  CURRENT_TARGET=$(readlink "$WORKTREE_MEMORY")
  if [[ "$CURRENT_TARGET" == "$CANONICAL_MEMORY" ]]; then
    exit 0
  fi
  # Points somewhere wrong — fix it.
  rm "$WORKTREE_MEMORY"
fi

# Ensure canonical directory exists.
mkdir -p "$CANONICAL_MEMORY"

# If the worktree already has a real memory dir, migrate its contents.
if [[ -d "$WORKTREE_MEMORY" && ! -L "$WORKTREE_MEMORY" ]]; then
  # Copy without overwriting existing canonical files.
  find "$WORKTREE_MEMORY" -maxdepth 1 -type f -exec \
    sh -c 'for f; do cp -n "$f" "'"$CANONICAL_MEMORY"'/" 2>/dev/null || true; done' _ {} +
  rm -rf "$WORKTREE_MEMORY"
fi

# Ensure parent directory exists.
mkdir -p "$(dirname "$WORKTREE_MEMORY")"

# Create the symlink.
ln -s "$CANONICAL_MEMORY" "$WORKTREE_MEMORY"

exit 0
