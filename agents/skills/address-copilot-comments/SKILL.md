---
name: address-copilot-comments
description: |
  Walk through Copilot review comments on a PR, auto-address the clear-cut ones,
  and queue subjective ones for the user to decide.
  If the PR is a draft or Copilot hasn't reviewed it yet, mark it ready for
  review, wait for Copilot's review, then address it.
  Use when asked to "address Copilot comments", "go through Copilot review",
  or given a PR URL with Copilot feedback.
user-invocable: true
allowed-tools: Bash, Edit, Read, Write, Glob, Grep, Skill, AskUserQuestion, Task
---

# Address Copilot Comments

Triage and address GitHub Copilot review comments on a pull request.

## Arguments

`$ARGUMENTS` — optional PR URL (`https://github.com/<owner>/<repo>/pull/<number>`),
`<owner>/<repo>#<number>`, or just `<number>`.

If empty, ask GitHub only for the pieces that aren't available locally — the PR number (and title, for the final report):

```
gh pr view --json number,title
```

If no PR is found, ask the user via `AskUserQuestion`. Don't guess.

## Workflow

### 1. Resolve the PR

Source everything you can from local git before touching the GitHub API.
The status bar shows `PR #N` because Claude Code runs its own lookup, but the agent can't read it — so we still need *one* call for the number when it isn't passed in. Everything else is on disk:

- `<owner>/<repo>` → parse `git remote get-url origin`.
- Current branch → `git branch --show-current`.
- Current HEAD SHA → `git rev-parse HEAD`.

Then resolve `<number>`:

- `$ARGUMENTS` has a URL or `owner/repo#n` → parse it.
- `$ARGUMENTS` has just `<n>` → use it; owner/repo come from the remote.
- `$ARGUMENTS` empty → `gh pr view --json number,title` (single, small call; title is reused in the final report).

Branch-alignment check:

- If the PR number came from `gh pr view` (empty `$ARGUMENTS` path), the branch matches by construction — no extra call needed.
- If the PR number came from `$ARGUMENTS`, verify with one call: `gh pr view <n> --json headRefName,title` and compare `headRefName` to the local branch (keep `title` for the final report).

If the local checkout is not on the PR's head branch, **stop and ask the user**.
Addressing comments on the wrong branch will produce commits that never reach the PR.

Also capture the PR's draft state in the same lookup — add `isDraft` (and `headRefName`/`title` if not already fetched) to the `gh pr view` `--json` field list. You need it in step 2.

### 2. Ensure a Copilot review exists

The user invoked this skill to act on Copilot feedback. If there's nothing to act on yet because the PR is a **draft** and/or **Copilot hasn't reviewed it**, the right move is to *get* that review — not to report "no comments" and stop.

Decide based on two facts gathered so far:

- Is the PR a draft? (`isDraft` from step 1)
- Has Copilot already reviewed? Check `gh api repos/<owner>/<repo>/pulls/<n>/reviews --paginate` and `.../comments --paginate` for any entry whose `user.login` matches `Copilot` or `copilot-*[bot]`.

**If the PR is not a draft AND a Copilot review already exists**, skip this step — go straight to step 3.

Otherwise, trigger a review and wait:

1. **If the PR is a draft, mark it ready for review:**
   ```
   gh pr ready <n> --repo <owner>/<repo>
   ```
   In most org setups this alone auto-requests a Copilot review.

2. **Ensure Copilot is requested as a reviewer** (no-op / benign error if the ready step already did it):
   ```
   gh api repos/<owner>/<repo>/pulls/<n>/requested_reviewers \
     --method POST -f "reviewers[]=copilot-pull-request-reviewer[bot]"
   ```
   If that login is rejected, try `gh pr edit <n> --repo <owner>/<repo> --add-reviewer "Copilot"`.
   Treat an "already requested" response as success.

3. **Wait for Copilot to post its review.** Poll `.../reviews` and `.../comments` every ~30s until a Copilot review or inline Copilot comment appears, capped at ~10 minutes. Copilot usually responds within 1–3 minutes. Run the wait as a background poll loop so it survives the turn.
   - If the review lands → fall through to step 3.
   - If nothing arrives within the cap → report that the review was requested but hasn't landed yet, and stop. Do not fabricate work.

This step is the only place the skill marks a PR ready for review. Do not flip draft state anywhere else.

### 3. Fetch Copilot comments

Copilot leaves two distinct things:

- **Reviews** (`/pulls/<n>/reviews`) — a summary overview (`state: COMMENTED`, `user.login: copilot-pull-request-reviewer[bot]`).
  Usually a description, rarely actionable.
- **Inline review comments** (`/pulls/<n>/comments`) — line-anchored suggestions (`user.login: Copilot`).
  These are the actionable items.

Fetch both in parallel:

```
gh api "repos/<owner>/<repo>/pulls/<n>/comments" --paginate
gh api "repos/<owner>/<repo>/pulls/<n>/reviews"  --paginate
```

Filter inline comments to top-level threads only (where `in_reply_to_id` is null) authored by `Copilot` or `copilot-*[bot]`.

For each top-level Copilot comment, fetch the thread replies to check whether **someone has already responded** (the user, the agent in a prior run, or Copilot itself in a follow-up). If a human or prior-agent reply exists, mark as already-handled and skip.

If there are zero unhandled Copilot comments, report that and stop.

### 4. Triage each comment

Process comments **in file order, then line order**, not API order.
Group by file so related fixes can be considered together.

For each comment, decide one of:

- **Auto-address** — the fix is clearly correct, low-risk, and the user would agree without discussion.
- **Queue for user** — anything subjective, ambiguous, or that changes behaviour in a non-obvious way.

#### Auto-address bias

Lean auto-address when ALL of:

- The change is small (a few lines).
- The fix is a factual correction (typo, wrong type, dead code, obvious bug).
- The fix matches the project's conventions (check `CLAUDE.md` / `AGENTS.md` / `.swiftlint.yml` / equivalent linter config).
- The diff doesn't change observable behaviour, OR the comment correctly identifies a bug the diff under review introduced.

Examples of auto-address material:

- Typos in comments, strings, identifiers (when safe to rename).
- Off-by-one or boundary fixes where Copilot is plainly right.
- Removing unused imports/variables Copilot flagged.
- Replacing `XCTAssertTrue(x == y)` with `XCTAssertEqual(x, y)` per project style.
- Adding a missing `final`, `private`, or `weak` qualifier the style guide requires.

#### Queue for user

Anything that:

- Is a stylistic preference where the project has no documented rule.
- Suggests a refactor (extract method, rename type, restructure flow).
- Changes externally observable behaviour or public API.
- Touches threading, concurrency, or memory semantics in non-trivial ways.
- Conflicts with a pattern the user has used elsewhere in the diff intentionally.
- You're uncertain about — when in doubt, **queue, don't auto-address**.

A wrong auto-address costs a revert + apology. A queued question costs 10 seconds of the user's time.

### 5. Auto-address loop

For each comment marked auto-address, in sequence:

#### a. Make the fix

Read the file at the commented line. Apply the minimal change that addresses the comment. Do not bundle unrelated cleanups — one comment, one change.

#### b. Commit

Use the `/commit` skill. One commit per comment unless two comments touch the same hunk and are inseparable.

Commit title: imperative, ≤ 50 chars, describing the fix (not the comment).
Examples:

- `Fix typo in BookingService comment`
- `Use XCTAssertEqual for clarity`
- `Mark CardReaderHelper as final`

Commit body (optional): include the comment URL or quote the comment if the why isn't obvious. Always include the standard footer from `~/.config/agents/rules/git.md`.

#### c. Push and reply (background)

After the commit lands locally, capture the SHA:

```
sha=$(git rev-parse HEAD)
short=$(git rev-parse --short HEAD)
```

Kick off **one background task** that pushes and then replies. Pushing must complete before the reply, otherwise the SHA link in the reply 404s. Use `Bash` with `run_in_background`:

```
git push origin <branch> && \
gh api repos/<owner>/<repo>/pulls/<n>/comments/<comment_id>/replies \
  --method POST -f "body=Addressed in <sha-link>"
```

Where `<sha-link>` is `https://github.com/<owner>/<repo>/commit/<sha>` — GitHub auto-renders the short SHA from the URL.

**Serialize pushes.** Concurrent `git push`es to the same branch race; the second one will fail non-fast-forward. Options:

- Cheapest: chain push+reply inside one bg task, and wait for that task to finish before starting the next comment's push.
- Or: keep all commits local, do one push at the end, then fire all replies in parallel.

Pick the second pattern when there are many comments — it's faster and simpler. Pick the first when the user explicitly wants per-comment visibility on the PR timeline.

Default to **batched push**: commit all auto-addresses, push once, then fan out replies in parallel.

Track every background bash ID. You need them in step 8.

### 6. Present the queued questions

Once auto-addresses are committed (and pushed/replied, if using the per-comment pattern), present the queue to the user.

Use `AskUserQuestion` when there are 1–4 items. For more, print a numbered list and ask the user to respond in free form.

For each queued comment, include:

- Comment URL (so the user can read it in context).
- File and line.
- A 1–2 sentence summary of what Copilot is suggesting.
- A 1-sentence note on why you didn't auto-address (your hesitation).
- A recommendation if you have one: "I'd lean address" / "I'd lean skip" / "Genuinely unsure".

### 7. Apply user decisions

For each item the user chose to **address**: same flow as step 5 (edit, commit, queue push/reply).

For each item the user chose to **skip**:

- Default: post a brief reply to the Copilot thread explaining the skip. Example: `Skipping — <reason in one short sentence>.` Keep it neutral; Copilot is a bot, but the thread is public.
- If the user said *"I'll reply myself"* or similar: do not post anything for that item.
- If the user gave a specific skip reason, use it verbatim (or paraphrased lightly).

For each item the user said to **defer** ("ask me later", "not now"): leave the thread untouched, no reply. List deferrals in the final report.

### 8. Drain background tasks

Before reporting done:

- For every background bash ID you spawned, confirm it has exited (use the harness's task-status check, or wait for the completion notification).
- If any push or reply failed, surface the error and ask the user how to proceed. Do not silently retry — a failed reply means the PR thread doesn't reflect what actually happened.

### 9. Final verification

Re-fetch the PR's comment threads:

```
gh api "repos/<owner>/<repo>/pulls/<n>/comments" --paginate
```

For every Copilot comment you intended to handle (auto-addressed, user-addressed, or skipped-with-reply), verify a reply from the user (or `mokagio`, or whichever identity `gh` is authenticated as) is present in the thread.

If any expected reply is missing, retry it once. If it still fails, list it under "Outstanding" in the final report.

Cross-check: the count of `addressed + skipped-with-reply + skipped-silently + deferred` must equal the count of Copilot comments triaged in step 4. If not, surface the discrepancy.

### 10. Report

Print a concise summary:

```
PR #<n> — <title>

Auto-addressed (N):
  - <file>:<line> — <one-line fix description> — <commit short SHA>
  ...

Addressed after asking (M):
  - <file>:<line> — <one-line> — <SHA>
  ...

Skipped (K):
  - <file>:<line> — <reason>
  ...

Deferred (D):
  - <file>:<line> — <one-line>
  ...

Outstanding (X):
  - <anything that failed and needs manual attention>
```

## Constraints

- **Verify branch alignment first.** Wrong branch = wasted commits.
- **One comment, one commit.** Don't bundle.
- **Lean queue over auto-address when uncertain.** Reverts are expensive; questions are cheap.
- **Always reply on skip** unless the user explicitly says they will. Silent skips leave Copilot threads unresolved and look like the comment was ignored.
- **Serialize pushes**, parallelize replies.
- **Never amend.** Always new commits (per `~/.config/agents/rules/git.md`).
- **Use the `/commit` skill** for commits — don't craft messages by hand.
- **Sign off replies** per `~/.config/agents/rules/github.md`:
  `*Posted by Claude (<model>) on behalf of @mokagio with approval.*`
  Append this to every reply posted to GitHub through the user's identity.

## GitHub API reference

- List inline comments: `gh api repos/<o>/<r>/pulls/<n>/comments --paginate`
- List reviews (overview): `gh api repos/<o>/<r>/pulls/<n>/reviews --paginate`
- Reply to a thread: `gh api repos/<o>/<r>/pulls/<n>/comments/<id>/replies --method POST -f body='...'`
- Copilot user logins to filter on: `Copilot`, `copilot-pull-request-reviewer[bot]`

If the repo lives in the `woocommerce` GitHub org and reads require it, prefix reads with `GITHUB_TOKEN="$GITHUB_TOKEN_WOOCOMMERCE_ORG"`. Writes use the default `gh` auth.
