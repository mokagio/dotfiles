---
name: address-review-comments
description: |
  Address actionable pull request review feedback end-to-end.
  Use when asked to address review comments, handle requested changes,
  go through PR feedback, fix reviewer comments, or continue from a review
  finding list. Resolve the PR, inspect unresolved review threads, triage
  clear fixes versus subjective questions, implement selected changes, commit
  each addressed comment or inseparable comment cluster, push, and monitor CI.
user-invocable: true
allowed-tools: Bash, Edit, Read, Write, Glob, Grep, Skill, AskUserQuestion, Task
---

# Address Review Comments

Work through PR review feedback without losing the boundary between review
comments, commits, and verification.

## Arguments

`$ARGUMENTS` may be a PR URL, `<owner>/<repo>#<number>`, a PR number, or a
short instruction such as `address comments 1-3`.
If empty, detect the PR from the current branch.

## Prerequisites

Read the repo instructions first (`AGENTS.md`, `CLAUDE.md`, or equivalent).
If none exists, follow the user's repo-entry rule before editing.

Read these global rules when relevant:

- `~/.config/agents/rules/git.md`
- `~/.config/agents/rules/github.md`
- `~/.config/agents/rules/tool-results.md`
- `~/.config/agents/rules/closing-the-loop.md`
- `~/.config/agents/rules/testing.md`
- `agents/gh-reference.md` from the dotfiles repo before `gh` commands

## Workflow

### 1. Resolve the PR and branch

Source context from local git first:

- repo from `git remote get-url origin`
- branch from `git branch --show-current`
- HEAD from `git rev-parse HEAD`

Resolve the PR from `$ARGUMENTS`, or with:

```bash
gh pr view --json number,url,title,headRefName,isDraft
```

If the local branch is not the PR head branch, stop and ask.
Do not address comments on the wrong branch.

### 2. Fetch review feedback

Use thread-aware reads for GitHub review comments.
Prefer GraphQL through `gh api graphql` because flat REST comment lists do not
preserve enough thread state.

Fetch at least:

- review threads: `isResolved`, `isOutdated`, file path, line or original line,
  URL, comments, authors, and bodies
- PR reviews and review states
- top-level PR comments when the user says "all feedback" or mentions a
  non-inline reviewer comment

Ignore resolved or outdated threads unless the user explicitly asks to revisit
them.
Treat existing human or prior-agent replies as a signal that a thread may
already be handled; verify before acting.

### 3. Triage

Process comments in file order, then line order.
Group comments only when they touch the same hunk or are logically inseparable.

Use these buckets:

- **Auto-address**: factual, low-risk, clearly correct, and small.
- **Ask user**: subjective, ambiguous, behavioral, API-affecting, or risky.
- **Skip**: already handled, obsolete, duplicate, wrong, or intentionally not
  being changed.

Bias toward asking when uncertain.
A wrong fix costs more than a short question.

### 4. Implement selected fixes

For each auto-addressed or user-selected item:

1. Read the surrounding code and relevant style/linter config.
2. Make the smallest change that addresses the comment.
3. Avoid unrelated refactors and cleanup.
4. Verify autonomously with the cheapest meaningful check.
5. If verification fails, inspect the output, fix, and rerun.

For documentation-only changes, targeted formatting and searches may be enough.
For code changes, run the relevant test, build, lint, or smoke command.

### 5. Commit each addressed item

Use the `commit` skill.
Default to one commit per review comment.
If multiple comments touch the same hunk and cannot be separated cleanly, make
one commit for that cluster and say why.

Do not sweep unrelated dirty work into the commit.
Think in hunks, not files.

### 6. Reply or resolve only when authorized

Do not post GitHub replies, submit reviews, or resolve threads unless the user
asked for public GitHub updates or that is clearly part of the requested
workflow.

When posting through the user's identity:

- include the commit link or short SHA for addressed comments
- explain skips briefly
- append the sign-off required by `~/.config/agents/rules/github.md`

### 7. Push and monitor

After commits are ready, use the `push` skill.
After every push, immediately invoke `ci-monitor` for the affected PR.
If `ci-monitor` reports `danger/pr-check` failures, chain into `fix-pr-checks`
and keep monitoring until Danger reruns.

Do not report done while checks are still running unless the monitor times out
or the available tooling cannot see the remaining system.
If monitoring is blocked, report the exact blocked surface.

### 8. Final report

Keep the final report concise:

```text
PR #N — title

Addressed:
- file:line — summary — commit

Asked:
- file:line — question

Skipped:
- file:line — reason

Verification:
- command/result
- CI status
```

Mention unresolved or deferred comments explicitly.
