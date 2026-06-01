---
name: push
description: |
  Push the current branch to its remote, setting upstream on the first push.
  Use when asked to "push", "push the branch", or invokes /push.
allowed-tools: Bash(git *), Bash(git -C *)
user-invocable: true
---

# Push

Push the current branch and report what landed.

## Workflow

1. Run `git status -sb` to learn: branch name, upstream presence, ahead/behind counts.
2. Push:
   - Upstream set → `git push`
   - No upstream → `git push -u <remote> <branch>` (use `origin` if present, otherwise the only remote from `git remote`)
3. Non-fast-forward rejection → relay git's message, point at `/pull`. No analysis, no recovery menu.

If the working tree has uncommitted hunks you authored this session, mention them — `git push` ships commits only, so unstaged work stays local.

## Constraints

- **Never `--force`.** If the user explicitly asks for a force-push, use `--force-with-lease` and refuse on `main`/`master`/`trunk` unless they confirm again.
- **Never push from a detached HEAD.** Surface the state and stop.
