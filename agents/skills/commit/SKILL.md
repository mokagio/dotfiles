---
name: commit
description: Commit changes with a well-crafted message.
allowed-tools: Bash(git *), Bash(git -C *), Bash(uuidgen), Write(/tmp/*), Read, Grep, Glob, AskUserQuestion
user-invocable: true
---

# Commit

Auto-invoked when Claude needs to create a git commit.
Use when asked to commit, save changes, or after completing work that should be committed.

## Arguments

`$ARGUMENTS` — optional commit description or guidance.
If empty, infer from staged/unstaged changes.

## Workflow

### 1. Gather context

Run these in parallel:

- `git status` — staged and unstaged changes (never use `-uall`)
- `git diff --cached` — what's already staged
- `git diff` — unstaged changes
- `git log --oneline -10` — recent commits for style reference

### 2. Determine what to commit

- If changes are already staged, use those.
- If nothing is staged, ask the user what to stage.
- Default to **one file per commit** unless the user specifies otherwise or the changes are logically coupled (e.g., a test double update required by a test migration).
- If multiple files have unrelated changes, propose splitting into separate commits and confirm with the user.

### 3. Stage files

Stage files individually by name.
**Never** use `git add -A` or `git add .`.

### 4. Compose the commit message

**Title (first line):**

- Describes *what* the change does
- Imperative mood ("Add feature", not "Added feature")
- Maximum 50 characters
- Drop backtick fencing from the title if needed to fit
- Must be sufficient on its own

**Body (optional, separated by blank line):**

- Explains *why* if not obvious from the title
- Never repeats the *what* — the diff covers that
- Use semantic line breaks (one sentence per line)
- Fence inline code and file names with backticks
- Track rationale and conversation details
- If the *why* is unclear, ask the user rather than guessing

**Footer (always present, separated by blank line):**

```
---

Generated with the help of <agent harness and/or model name, URL (if available)>

<Co-Authored-By: Agent+Model email (if available)>
```

Example:

```
---

Generated with the help of Claude Code, https://claude.ai/code

Co-Authored-By: Claude Code Opus 4.6 <noreply@anthropic.com>
```

If `$ARGUMENTS` provides a hint, use it to guide the message focus.

### 5. Write the message file

Generate a unique file path in `/tmp`:

```
/tmp/commit-msg-<uuid>
```

Use `uuidgen` to produce the UUID, then **Write** the complete message to that path.

**Why `/tmp` instead of `.git/COMMIT_MSG`?**
Writing to `.git/COMMIT_MSG` triggers permission prompts in Claude Code even when the `--skip-permissions` flag is set for `Write` on `.git/` paths.
`/tmp` is flushed on reboot and avoids the issue entirely.

### 6. Commit

Run:

```
git commit -F /tmp/commit-msg-<uuid>
```

Or with `-C` if working in a worktree:

```
git -C <path> commit -F /tmp/commit-msg-<uuid>
```

This is a single-line command that matches the permission globs.

### 7. Verify

Run `git status` after the commit to confirm success.

If a pre-commit hook fails:

1. Fix the issue
2. Re-stage the file(s)
3. Create a **new** commit — **never amend**

## Constraints

- **Never amend** — always create new commits.
- **Never use `git --git-dir`** — use `git -C` or `cd` then `git` in separate calls.
- **Never `cd path && git ...`** — the permission system matches on first token.
- **Never `git add -A`** or **`git add .`** — stage files by name.
- **Never skip hooks** (`--no-verify`) unless explicitly asked.
- If there are no changes to commit, say so and stop.
