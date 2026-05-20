---
name: open-in-github
description: |
  Open the GitHub PR for the current branch in the browser.
  Falls back to the repo home page if no PR exists.
  Use when asked to "open PR", "open in GitHub", or invokes /open-in-github.
allowed-tools: Bash(gh *), Bash(open *)
user-invocable: true
---

# Open in GitHub

Open the current branch's PR (or repo home) in the default browser.

## Workflow

1. Run `gh pr view --json url --jq .url` to get the PR URL for the current branch.
2. If that succeeds, run `open <url>`.
3. If no PR exists, run `gh repo view --json url --jq .url` to get the repo URL, then `open <url>`.

That's it. No output beyond confirming what was opened.
