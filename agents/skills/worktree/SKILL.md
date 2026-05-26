---
name: worktree
description: |
  Create a Git worktree for a new task.
  This skill should be used when the user asks to "start working on", "implement", "fix", "add", "refactor", "migrate", or otherwise begin a code task that requires a new branch.
  Do not use for trivial tasks like reading files, answering questions, or changes to the current dotfiles repo.
allowed-tools: Bash(git *), Bash(git -C *), Read, Glob
---

# Worktree

Create a Git worktree for a new task, following the project's worktree protocol.

## Why this skill exists

The worktree protocol (AGENTS.md lines 120–143) is multi-step and easy to get wrong:
forgetting to fetch, branching from a stale default, creating in the wrong directory.
This skill automates the full procedure.

## Arguments

`$ARGUMENTS` — description of the task (used to derive the branch/worktree slug).

## Workflow

### 1. Resolve the main checkout

Determine the main repo checkout path:

- First resolve Git's common dir with `git -C <cwd-or-main> rev-parse --path-format=absolute --git-common-dir`.
- If the common dir ends in `/.git`, the main checkout is its parent directory.
- This works for both legacy repo-local worktrees and preferred worktrees under `~/Developer/git-worktrees/<repo>/<branch>`.
- Legacy example: `/Users/gio/Developer/my-repo/.git-worktrees/feature-x` → `/Users/gio/Developer/my-repo`.
- Preferred example: `/Users/gio/Developer/git-worktrees/my-repo/feature-x` → `/Users/gio/Developer/my-repo`.

Verify the resolved path is a git repo with `git -C <main> rev-parse --git-dir`.

### 2. Discover the default branch

```
git -C <main> remote show origin | grep 'HEAD branch'
```

Parse the branch name (e.g., `main`, `trunk`, `master`).

### 3. Fetch

```
git -C <main> fetch origin
```

### 4. Derive the worktree slug

From `$ARGUMENTS` or the task description, create a short slug:

- Lowercase, hyphen-separated, no special characters.
- Keep it under ~30 characters.
- Example: "Add user authentication" → `add-user-auth`.

### 5. Create the worktree

Resolve the preferred and legacy worktree roots in this order:

- Preferred root: `~/Developer/git-worktrees/<repo-name>/`
- Legacy root: `<main>/.git-worktrees/`

Search the preferred root first when checking for existing migrated worktrees.
Only fall back to the legacy root when the preferred root is absent or the repo has not been migrated yet.

New worktrees always go in the preferred root.
If the repo still has legacy worktrees under `<main>/.git-worktrees/`, suggest running `git-worktree-migrate <main>` to migrate them.

Create the preferred root if needed, then add the new worktree there.

```
git -C <main> worktree add ~/Developer/git-worktrees/<repo-name>/<slug> -b <slug> origin/<default>
```

### 6. Bootstrap

Discover and run any repo-defined bootstrap procedure so the new worktree is ready to build and test.

- Read the new worktree's agent instructions file (`AGENTS.md`, `CLAUDE.md`, etc.) and look for a section titled "Bootstrap" — or an equivalent label.
- Run the command(s) that section names, in the new worktree, as a background task so the rest of the session can continue in parallel.
- If no such section exists, surface that to the user as a finding — do not guess.

### 7. Report

Print the worktree path, the branch's upstream, and the bootstrap status.
Example:

> Worktree created at `/Users/gio/Developer/git-worktrees/my-repo/add-user-auth`.
> Branch `add-user-auth` tracking `origin/main`.
> Bootstrap running in background (per `AGENTS.md` § Bootstrap).

## Constraints

- **Never** use `git --git-dir` or `cd path &&` — use `git -C` for all operations.
- **Never** work directly on the main branch — always create a worktree first.
- If already inside a worktree for a different task, resolve back to the main checkout before creating.
- New worktrees go in `~/Developer/git-worktrees/<repo-name>/`.
- `.git-worktrees/` is legacy fallback only.
