---
name: pre-review
description: |
  Review one or more GitHub PRs and write a per-PR findings file (with a go/no-go
  call at the top) into ~/Developer/ai-workspace/code-reviews/.
  Use when asked to "review this PR", "review my PRs", "write review notes",
  or given a PR URL / a search criteria for PRs to review.
  Produces documents for later human review or handoff to another agent that
  posts the comments — it does NOT post anything to GitHub.
allowed-tools: Bash, Read, Grep, Glob, Write, WebFetch
---

# PR Review Notes

Review GitHub PRs and emit one Markdown findings file per PR into
`~/Developer/ai-workspace/code-reviews/`.

Each file is a work product for **later** consumption — Gio reads it, or another
agent uses it to post inline comments. Nothing here touches GitHub.

## What Gio wants (and does NOT want)

He wants, in this order:

1. A **go / no-go** verdict at the very top.
2. **DRY** opportunities — duplicated logic that should be factored out.
3. **Modularization** opportunities — code that should be split, extracted, or
   given a cleaner boundary.
4. **Missing unit tests** — untested logic, especially anything risky or fiddly.
5. For any **defect** found: a concrete unit test that **reproduces** it, in the
   repo's own test framework.

He explicitly does **NOT** want:

- An explanation of what the PR does.
- A summary of the changes.
- A file-by-file walkthrough.
- Praise, restated context, or padding.

If a section has nothing to report, write `None found.` and move on. Do not
invent findings to fill space.

## Arguments

`$ARGUMENTS` is one of:

- **A specific PR** — a URL (`https://github.com/owner/repo/pull/123` or a
  `github.a8c.com` URL) or an `owner/repo#123` shorthand.
- **A criteria to look up PRs** — free text Gio expects you to turn into a `gh`
  search, e.g. "my open PRs", "PRs I need to review", "open PRs in
  woocommerce/woocommerce-ios labeled feature", "PRs #101 #102 #103".

If the criteria is ambiguous (which org? whose PRs? open only?), ask **one**
clarifying question before fanning out. A single named PR needs no confirmation.

## GitHub host & CLI

Pick the CLI by host:

- `github.com` → `gh`
- `github.a8c.com` (GitHub Enterprise) → `gh_a8c` (the SOCKS-proxy wrapper).
  Bare `gh` hangs or 404s against GHE. See the a8c AGENTS.md.

Detect the host from the PR URL. For criteria without a host, default to
`github.com` unless the repo is clearly a `github.a8c.com` one.

## Workflow

### 1. Resolve the target PR list

- Specific PR → a one-element list.
- Criteria → run the matching `gh`/`gh_a8c` search to get the list. Examples:
  - authored, open: `gh search prs --author "@me" --state open`
  - review-requested: `gh search prs --review-requested "@me" --state open`
  - by repo+label: `gh pr list --repo <owner/repo> --label <label> --state open`

  Echo the resolved list back before reviewing so Gio can course-correct.

### 2. For each PR, gather the material

Read, don't summarize:

- Metadata: `gh pr view <pr> --json number,title,url,headRefOid,baseRefName,files,additions,deletions`
- The diff: `gh pr diff <pr>`
- **The surrounding code.** The diff alone hides duplication and coupling. For
  each changed file, read enough of the file (and its obvious neighbors) to judge
  DRY and modularization honestly. Grep the repo for copies of logic the PR adds.
- The repo's test setup: find the test framework and where tests live (check
  `AGENTS.md`/`CLAUDE.md`, then `Rakefile`/`Makefile`/`package.json`/`*.xcodeproj`).
  You need this to write reproducing tests in the right dialect.

For very large diffs or many PRs, review PRs in parallel by launching a subagent
per PR (each writes its own file); keep per-PR analysis in one context so
cross-file duplication is visible.

### 3. Make the go / no-go call

**NO-GO** when any of these are present:

- A correctness or security defect in the changed code.
- A change that plausibly breaks existing behavior with no test covering it.
- Risky/fiddly new logic (parsing, conditionals, regex, money, auth, concurrency)
  shipped with **no** unit test.

Otherwise **GO**. DRY and modularization findings alone do not force a NO-GO —
they are improvements, not blockers — unless the duplication itself is the bug
(e.g. two copies already drifting). State the single driving reason in one line.

### 4. Write the findings file

Path: `~/Developer/ai-workspace/code-reviews/<owner>-<repo>-<number>.md`
(slugify `owner`/`repo`; e.g. `woocommerce-woocommerce-ios-12345.md`). Overwrite
if it exists — one canonical file per PR.

Use this exact skeleton. Keep it terse. Every finding must be **located**
(`path:line`) and **actionable** so a downstream agent can turn it straight into
an inline comment.

```markdown
# <owner>/<repo> #<number>

**Verdict: GO** — <one-line reason>

<!-- pr: <url> · head: <sha> · reviewed: <YYYY-MM-DD> -->

## Blocking

<!-- Only the findings that drive a NO-GO. Omit the section entirely on a GO with none. -->

- **<path>:<line>** — <what's wrong and why it blocks>.
  Repro test: see below.

## DRY

- **<path>:<line>** (dup of **<other-path>:<line>**) — <what to extract>.

## Modularization

- **<path>:<line>** — <what to split/extract and the seam to cut along>.

## Missing tests

- **<path>:<line>** — <untested behavior>; suggested case: <input → expected>.

## Reproducing tests

<!-- Only for defects. A paste-ready failing test in the repo's framework. -->

```<lang>
// <path/to/test_file> — fails on current HEAD, passes once fixed
<test code>
```
```

Rules for the file:

- The **verdict line is line 3** and starts with `**Verdict: GO**` or
  `**Verdict: NO-GO**` so it is greppable and unmissable.
- Use `path:line` from the PR's head, not the diff's hunk offset.
- Reproducing tests are for **defects only** — DRY/modularization/missing-test
  items are not bugs and get no repro. A "missing test" item describes the case;
  a "blocking" defect gets an actual failing test under Reproducing tests.
- No summary, no "this PR …", no change list. If you catch yourself explaining
  the PR, delete it.

### 5. Report back in chat

After all files are written, print a compact index — one line per PR — as
clickable Markdown links, verdict first:

```
- NO-GO — [woocommerce/woocommerce-ios#12345](url) — <file>
- GO — [Automattic/pocket-casts-ios#678](url) — <file>
```

Nothing else. The detail lives in the files.

## Constraints

- **Never post to GitHub.** No `gh pr review`, no `gh pr comment`, no replies.
  This skill only writes local files.
- Do not fabricate line numbers or findings. If you can't locate something
  precisely, say so in the finding rather than guessing a line.
- Respect the repo's conventions for test framework and layout when writing
  reproducing tests (Swift Testing vs XCTest, RSpec vs Minitest, Vitest vs Jest,
  pytest, etc.) — read the repo, don't assume.
