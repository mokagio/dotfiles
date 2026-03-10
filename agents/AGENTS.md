Prefer conciseness over verbosity.
If I need additional details, I'll ask.

---

Do not flatter me.
If I'd wanted a cheerleader, I'd asked my Mum.

---

**NEVER use `git --git-dir=<path>`** — it bypasses permission rules.
**NEVER prefix Bash commands with `cd path &&` or `cd path;`.**
**NEVER chain commands with `&&` or `;` after a `cd`.**

The permission system matches on the first token of each Bash call.
`git --git-dir` creates unique permission prompts per path.
`cd foo && git ...` makes the first token `cd`, bypassing all allowed-command rules.

`git -C <path>` is fine — permission rules cover it.

**Correct patterns:**

- `git -C /path/to/repo status` (single Bash call)
- `cd /path/to/repo` then `git status` (two separate Bash calls)

**Wrong patterns (never do these):**

- `git --git-dir=/path/to/repo/.git status`
- `cd /path/to/repo && git status`
- `cd /path/to/repo; git status`

For non-git commands, prefer absolute paths (`ls /full/path`) over `cd` + relative.

---

The message should terminate with:

```
---

Generated with the help of AGENT, AGENT_URL

Co-Authored-By: AGENT MODEL <EMAIL>
```

Replace `AGENT` and `AGENT_URL` with the tool in use (e.g., "Claude Code", "https://code.claude.com").
Replace `MODEL` with the model used to write the code.

**Commit message style**:

- The title describes *what* the change does — keep it sufficient on its own.
- If there's a *why* that isn't absolutely obvious from the title, elaborate it in the body.
- Use the body to track rationale for the change and other conversation details.
- If the why isn't obvious to you, ask me rather than guessing.
- Never repeat the "what" in the body; the diff covers that.
- Titles must stay within the recommended 50 characters.
  Drop backtick fencing from the title if needed to fit.

---

I want an empty line before the start of my lists.

Bad:

```
Here are the items:
- One
- Two
- Three
```

Good:

```
Here are the items:

- One
- Two
- Three
```

When writing for me, including in commit messages, fence inline code and file names, unless doing so goes over the standard line length for the commit title.
Example:

```
Update `AGENTS.md` with rule for code fencing
```

---

**NEVER amend commits** — create a new commit instead.
Amending requires force-pushing, which is destructive and blocked by hooks.

Always use the `/commit` skill when creating git commits.
Never craft commit messages or run `git commit` directly.

Commits should be **small and atomic** and so should be the way you approach changes.

When doing mechanical migration work, commit each file migrated individually, unless there are dependencies.

Example: When migrating a Swift test suite from Quick+Nimble to modern Swift Testing, operate on one file at a time and commit it.
If a test double needs to be updated in order for a test to be migrated, then do the necessary update, then the migration, and commit them both in the same commit.
That's what I mean with small and atomic.

---

When writing Markdown, use [**semantic line breaks**](https://sembr.org/):

- One sentence per line.
- No blank line between closely related sentences.
- Blank line between distinct thoughts/paragraphs.

This keeps diffs clean and source readable.

---

When writing code, always check if there are linter or style configurations in the repository that you should adopt.

Example: If a Ruby project has `.rubocop.yml` ensure the code you write matches the preferences specified there.

---

Always use the `/worktree` skill when creating Git worktrees.
Never run `git worktree add` directly.

Always use Git worktrees for branch work — never work directly on the main branch.
**Every new task gets its own worktree**, even if you're already inside one.
A worktree is scoped to a single piece of work; unrelated changes must not land there.

At the start of a feature, project, or plan, create a worktree.
Once the work is merged or abandoned, remove it.

Place worktrees in `.git-worktrees/` inside the repo root:

```
~/Developer/
└── my-repo/
    ├── .git-worktrees/       ← gitignored globally
    │   ├── feature-x/
    │   └── bugfix/
    └── src/
```

This keeps worktrees inside the repo's sandbox, avoiding permission prompts for `cd`.

**Worktree Git Commands**

- Create the worktree **before** making any changes — not after.
- Always branch from an up-to-date default branch.
  Discover the default branch yourself (`git remote show origin | grep 'HEAD branch'`), then fetch and use `origin/<default>` as the start point.
- If you are currently inside a worktree for a different task, `cd` to the main checkout first, then create the new worktree from there.

---

Use `/usr/bin/env` and single parameter in shebangs. Example:

```bash
#!/usr/bin/env bash

set -eu
```

---

For changes spanning more than 2-3 files, use plan mode first.
Explore the codebase, present a roadmap, then execute.
This prevents wasted context from trial-and-error edits.

---

When a multi-step workflow succeeds in a session, offer to save it as a skill.
Don't wait for me to ask.

---

Run builds and test suites as background tasks when possible.
Continue working while they run; check results when done.

---

After any rebase or merge that touches an Xcode project file (`*.pbxproj`), run `/audit-xcodeproj` before proceeding.
Merge conflicts in project files often produce silent corruption (truncated entries, dangling UUIDs) that only surfaces later as build failures.

---

When first entering a repo, check for an agent instructions file at its root (e.g., `CLAUDE.md`, `AGENTS.md`).
If there isn't one, prompt me to create it before doing anything else.
No guessing at build commands, test runners, or conventions — get them documented first.

---

When writing YAML, only quote strings when the content requires it (e.g., special characters, reserved words, embedded colons).
Prefer unquoted strings for cleaner, leaner files.

---

When posting to GitHub using my account (PR comments, issue comments, reviews, etc.), always close with a note like:

> *Posted by AGENT (MODEL) on behalf of @mokagio with approval.*

Replace `AGENT` and `MODEL` with the tool and model in use (e.g., "Claude", "Opus 4.6").
This applies to any public-facing action taken through my identity.

---

When working with the GitHub CLI (`gh`), consult [`agents/gh-reference.md`](gh-reference.md) for auth setup, token overrides, API patterns, and known gotchas.

---

At the start of a session, if it's the first interaction of the day, greet briefly and suggest one actionable thing.
Check `~/.me/prompts/log/` to determine if today's log exists yet (if it does, this isn't the first session).

Suggestions to rotate through, in priority order:

- If yesterday's prompt log exists but no retro does → "Should we run `/prompt-retro` on yesterday's prompts?"
- If `~/.me/prompts/retros/` has a recent retro with a top pattern → remind about that pattern
- If there are pending items in `~/.me/patterns.md` → surface one

Keep it to 1-2 lines. Don't dump a wall of suggestions.
Example: "Good morning, Gio. Yesterday's prompts aren't reviewed yet — want to run `/prompt-retro`?"

---

Before wrapping up a session, review what you learned and log it:

- **Your global memory** (`~/.claude/memory/`) — cross-project preferences, workflow patterns
- **Your project memory** (`~/.claude/projects/<project>/memory/`) — repo-specific patterns
- **`~/.me/patterns.md`** — durable learnings that persist in my system, not just yours

Skip if the session was trivial or nothing new came up.
