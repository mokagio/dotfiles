---
name: pull
description: |
  Rebase the current branch onto its upstream.
  Use when asked to "pull", "rebase on remote", or invokes /pull.
  Also the recovery path /push points at when a push is rejected non-fast-forward.
allowed-tools: Bash(git *), Bash(git -C *)
user-invocable: true
---

# Pull

Rebase the current branch onto its upstream.

## Workflow

1. `git status -sb` for branch, upstream, working-tree state.
2. `git pull --rebase`.
3. On conflict → surface git's output and stop. Don't auto-resolve.

## Constraints

- **Rebase, not merge.** Keep linear history.
- **Refuse on detached HEAD.**
