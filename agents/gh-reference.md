# GitHub CLI Reference

Global reference for `gh` usage across all skills and agents.

## Authentication

`gh` authenticates via the system keyring (`gh auth login`).

### Token overrides

Some orgs require a different token.
Override by setting `GITHUB_TOKEN` for the `gh` invocation:

```bash
GITHUB_TOKEN="$MY_TOKEN" gh pr view 123 --repo owner/repo
```

These env vars are set in the shell environment (not in dotfiles).
Skills that need them should document which token they require.

## Invocation patterns

Always use the full path or rely on `$PATH`.
Never `source ~/.zshrc` before `gh` — it's unnecessary and slow.

### Targeting a repo

Use `--repo <owner>/<repo>` to avoid depending on the current directory:

```bash
gh pr view 42 --repo owner/repo
gh pr checks 42 --repo owner/repo
```

### JSON output

Use `--json` + `--jq` for structured output:

```bash
gh pr view 42 --repo owner/repo --json number,url,title,headRefName \
  --jq '{number, url, title, branch: .headRefName}'
```

## REST API (`gh api`)

Prefer `gh api` over `gh pr edit` for write operations.
See _Classic Projects gotcha_ below.

### Read (GET)

```bash
gh api repos/owner/repo/pulls/42
gh api repos/owner/repo/issues/42/comments
```

### Write (POST/PATCH/DELETE)

```bash
# Add labels
gh api repos/owner/repo/issues/42/labels \
  -f "labels[]=bug" --method POST

# Set milestone
gh api repos/owner/repo/issues/42 \
  -f milestone=7 --method PATCH
```

Write calls are guarded by `claude/hooks/gh-api-guard.sh`.
Safe PR metadata endpoints (labels, milestones) are allowlisted.
All other writes prompt for confirmation.

### GraphQL

```bash
gh api graphql -f query='{ viewer { login } }'
```

Mutations are flagged by `gh-api-guard.sh` and require confirmation.

## Known gotchas

### Classic Projects breaks `gh pr edit`

`gh pr edit` uses a GraphQL mutation that queries `projectCards`.
Repos that ever had classic Projects enabled will fail:

> Projects (classic) is being deprecated...

**Workaround**: use `gh api` REST endpoints instead.
This is why `fix-pr-checks` uses `gh api` for labels and milestones.

### `gh pr checks` output

`gh pr checks` returns tab-separated output.
Columns: check name, status, elapsed, URL.
Parse carefully — check names can contain spaces.

### Rate limiting

GitHub API has rate limits (5000 req/hour for authenticated users).
Polling loops should use intervals of 60–90 seconds minimum.
