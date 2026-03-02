---
name: fix-pr-checks
description: |
  Fix PR metadata issues flagged by Danger (labels, milestones).
  Use when a PR fails danger/pr-check due to missing labels or milestones.
  Can be invoked standalone or by ci-monitor when it detects Danger failures.
allowed-tools: Bash(gh pr view *), Bash(gh pr checks *), Bash(gh api *), Bash(gh label list *), Bash(gh pr diff *), Read, Grep, Glob
---

# Fix PR Checks

Automatically fix PR metadata issues flagged by Danger.

## Prerequisites

Read [`agents/gh-reference.md`](../../../agents/gh-reference.md) for auth setup and token overrides before running any `gh` commands.

## Arguments

`$ARGUMENTS` — one of:

- A PR URL: `https://github.com/<owner>/<repo>/pull/<number>`
- `<owner>/<repo>#<number>` or `<owner>/<repo> <number>`
- Just `<number>` (requires `--repo` context or current repo)

## Step 1: Parse input

Extract `owner/repo` and PR number from `$ARGUMENTS`.
If only a number is given, detect the repo from the current git remote.

## Step 2: Fetch PR state and Danger feedback

Run in parallel:

- `gh pr view <number> --repo <owner/repo> --json title,labels,milestone,baseRefName,body`
- `gh pr checks <number> --repo <owner/repo>` to see if `danger/pr-check` failed
- `gh api repos/<owner/repo>/issues/<number>/comments` to read the Danger comment

Parse the Danger comment for actionable items.
Known fixable issues:

- "PR requires at least one label"
- "PR is not assigned to a milestone"

Known non-fixable issues (report but skip):

- "This PR is larger than N lines" — mention it, move on

If there are no fixable issues, report that and stop.

## Step 3: Determine the right label

Fetch available labels:

```
gh label list --repo <owner/repo> --limit 100 --json name --jq '.[].name'
```

Infer the label from the PR title, body, and diff:

- Project/build file changes → `[Type] Tooling`
- Bug fixes (title contains "fix", "bug", "crash") → `[Type] Bug`
- New features → `[Type] Feature` or `[Type] Enhancement`
- Dependency updates → `Dependencies`
- Documentation changes → `documentation`
- Refactoring → `refactoring`

If unsure, list the top 3 candidates and ask the user to pick.

## Step 4: Determine the right milestone

Use the `gh-infer-milestone` script (on PATH via `scripts/`):

```
gh-infer-milestone <owner/repo> <base-branch>
```

Output is tab-separated: `<milestone_number>\t<milestone_title>`.
Exit code 2 means ambiguous — ask the user.

If the script is unavailable, fall back to manual logic:

- Fetch open milestones: `gh api repos/<owner/repo>/milestones?direction=asc&sort=due_date`
- If the base branch is `trunk`/`main`/`develop`: pick the **next** open milestone with a due date
  (skip any milestone marked with frozen indicators like ❄️ or "frozen" in the title).
- If the base branch is `release/*`: pick the milestone matching the release version.
- If unsure, ask the user.

## Step 5: Apply fixes

Use the GitHub API directly (not `gh pr edit`, which fails on repos with classic Projects):

**Add label:**

```
gh api repos/<owner/repo>/issues/<number>/labels -f "labels[]=<label>" --method POST
```

**Set milestone:**

```
gh api repos/<owner/repo>/issues/<number> -f milestone=<milestone_number> --method PATCH
```

Run both in parallel if both are needed.

## Step 6: Verify

Fetch the PR state again to confirm:

```
gh api repos/<owner/repo>/issues/<number> --jq '{milestone: .milestone.title, labels: [.labels[].name]}'
```

## Step 7: Report

Summarize what was fixed:

```
PR #42 — Add widget support

Fixed:
  label: [Type] Enhancement
  milestone: 1.2

Skipped:
  - Large diff warning (not fixable)

Danger should pass on next CI run.
```

## Why `gh api` instead of `gh pr edit`

`gh pr edit` uses a GraphQL mutation that queries `projectCards` (classic Projects).
Repos that ever had classic Projects enabled will fail:

> Projects (classic) is being deprecated...

The REST API (`gh api repos/.../issues/...`) avoids this entirely.

## Permissions

The label and milestone API calls are allowlisted in `gh-api-guard.sh`.
No additional `settings.json` entries are needed beyond the existing `Bash(gh api *)`.
