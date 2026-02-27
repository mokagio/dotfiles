---
name: ci-monitor
description: |
  Check CI status for PRs and Buildkite builds, diagnose failures, auto-fix when possible.
  Use when asked to "check CI", "check PR status", "how's the build", "monitor CI",
  "what's failing", or given a Buildkite build URL.
  Also use after pushing code when the user wants to track the build.
allowed-tools: Bash(gh *), Bash(git *), Bash(git -C *), Bash(sleep *), Read, Glob, Grep, Task, Skill, mcp__buildkite__get_build, mcp__buildkite__wait_for_build, mcp__buildkite__tail_logs, mcp__buildkite__search_logs, mcp__buildkite__list_annotations, mcp__buildkite__get_failed_executions
---

# CI Monitor

Check CI health for a PR or Buildkite build.
Diagnose failures and auto-fix what's fixable.
Always monitor until all checks reach a terminal state.

## Prerequisites

Read [`agents/gh-reference.md`](../../../agents/gh-reference.md) for auth setup and token overrides before running any `gh` commands.
Determine the correct token for the repo's org from that reference.

## Input

`$ARGUMENTS` — one of:

- A Buildkite URL: `https://buildkite.com/<org>/<pipeline>/builds/<number>`
- A PR URL or number: `https://github.com/<owner>/<repo>/pull/<number>` or just `<number>`
- Empty — detect from current branch

## Step 1: Resolve context

### If given a Buildkite URL

Parse `org_slug`, `pipeline_slug`, `build_number` from the URL.
Skip to **Step 3** (Buildkite deep dive).

### If given a PR number or URL

Use that PR.
Detect `owner/repo` from the URL, or from the current git remote if only a number.

### If no arguments

Detect the current branch and find its PR:

```bash
gh pr view --json number,url,title,headRefName \
  --jq '{number, url, title, branch: .headRefName}'
```

Use `--repo <owner/repo>` if not inside the repo directory.
Set `GITHUB_TOKEN` per `gh-reference.md` if the org requires it.

If no PR exists for the current branch, tell the user and stop.

## Step 2: Check PR status

```bash
gh pr checks <PR_NUMBER> --repo <owner/repo>
```

Report a summary table: check name, status, duration.

### All checks passed

Done. Report the summary.

### All checks still running, no failures yet

Proceed to **Step 5** (monitoring loop).

### Some checks failed

Identify each failure, then proceed through steps 3 and 4.

## Step 3: Auto-fix Danger failures

When `danger/pr-check` has failed, **always** invoke `/fix-pr-checks`:

```
Skill(skill="fix-pr-checks", args="<owner/repo>#<number>")
```

This handles missing labels and milestones automatically.
After the skill completes, proceed to **Step 5** to monitor until the re-triggered Danger check passes.

Do not ask whether to fix — just fix it.

## Step 4: Diagnose Buildkite failures

**MCP fallback**: The Buildkite MCP token expires periodically.
If any MCP call returns a re-authorization error, fall back to `gh pr checks` for status polling.
Report the failure with its Buildkite link and ask the user to check logs manually.

For each failed Buildkite job:

1. **Get build info**: `mcp__buildkite__get_build` with `job_state: "failed,broken"`, `detail_level: "detailed"`.
   Skip jobs where `soft_failed: true` — mention them but don't investigate.

2. **Read tail**: `mcp__buildkite__tail_logs` with `tail: 50` for each hard-failed job.

3. **Search for errors** (if tail isn't clear): `mcp__buildkite__search_logs` with pattern `error|Error|FAILED|fatal` (limit: 20, context: 3).

4. **Check annotations**: `mcp__buildkite__list_annotations` — build annotations often contain formatted error summaries.

5. **Report**: For each failure, state:

   - Job name
   - Root cause (quote the relevant log line)
   - Assessment: code issue vs. infra flake vs. configuration problem
   - Suggested fix if obvious

## Step 5: Monitor until terminal

Always monitor until every check reaches a terminal state (passed, failed, canceled).
This is not optional — never stop while checks are still running.

**Timeout**: 15 minutes from first poll.
**Poll interval**: 90 seconds.
No hard iteration cap — keep going until timeout or all checks are terminal.

### Loop

Spawn a background agent if the user wants to continue working:

```
Task(subagent_type="general-purpose", run_in_background=true)
```

The monitoring loop:

```
Repeat until all checks terminal OR 15 minutes elapsed:

1. Run `gh pr checks <number> --repo <owner/repo>`.
2. Print status summary:
   "PR #N: X/Y passed, Z failed, W running (elapsed: Mm Ss)"
3. If all terminal → break.
4. If new failures since last check:
   - Danger failure → invoke `/fix-pr-checks`, then continue loop.
   - Buildkite failure → diagnose immediately (Step 4).
5. Sleep 90 seconds.
6. Repeat.
```

After the loop:

- **All passed**: report final summary.
- **Failures**: ensure all hard failures are diagnosed.
- **Timeout**: report current state, tell user to check back.

## Output format

Keep it concise:

```
PR #42 — Add widget support

  12/13 passed, 1 soft-failed (Mac UI Tests — known flaky)
  Buildkite #1084: passed
  Danger: passed (after auto-fix: added label + milestone)
  GHA claude: skipping (normal)
```

For failures, add diagnosis details inline.

## Repo-specific notes

Document repo-specific CI quirks here as you encounter them.
Do not hardcode repo names in the steps above — keep steps generic.
