---
name: commit
description: |
  Commit staged changes with a well-crafted message.
  Auto-invoked when Claude needs to create a git commit.
  Use when asked to commit, save changes, or after completing work that should be committed.
allowed-tools: Bash(git *), Bash(git -C *), Write(/tmp/claude-commit-msg), Read, Grep, Glob
---

# Commit

Create a git commit for staged changes, following the project's commit conventions.

## Why this skill exists

Multi-line heredoc commit messages don't match `Bash(git commit *)` permission globs
because `*` doesn't cross newlines.
This skill writes the message to a file and uses `git commit -F`, which is a single-line
command that matches the existing globs.

## Arguments

`$ARGUMENTS` — optional hint for what the commit message should focus on.

## Workflow

### 1. Understand the changes

Run in parallel:

- `git status` (or `git -C <path> status` if in a worktree)
- `git diff --cached` (to see what's staged)

If nothing is staged, tell the user and stop.

### 2. Match recent style

Run `git log --oneline -5` to see recent commit messages.

### 3. Draft the commit message

Follow these conventions (from AGENTS.md):

- **Title**: imperative mood, max 50 characters, describes *what* the change does.
  Fence inline code and file names unless it would exceed 50 chars.
- **Body** (only if the *why* isn't obvious from the title): explains *why*,
  uses semantic line breaks, never repeats the *what*.
- **Trailer block** (always):

```
---

Generated with the help of <agent harness and/or model name, URL (if avalilable)>

<Co-Authored-By: Agent+Model email (if available)>
```

Example:

```
---

Generated with the help of Claude Code, https://claude.ai/code

Co-Authored-By: Claude Code Opus 4.6 <noreply@anthropic.com>
```

If `$ARGUMENTS` provides a hint, use it to guide the message focus.

### 4. Write the message file

Use the `Write` tool to write the complete message to `/tmp/claude-commit-msg`.

### 5. Commit

Run:

```
git commit -F /tmp/claude-commit-msg
```

Or with `-C` if working in a worktree:

```
git -C <path> commit -F /tmp/claude-commit-msg
```

This is a single-line command that matches the permission globs.

### 6. Verify

Run `git status` to confirm the commit succeeded.
