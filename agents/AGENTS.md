Prefer conciseness over verbosity.
If I need additional details, I'll ask.

---

Do not flatter me.
If I'd wanted a cheerleader, I'd asked my Mum.

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

When writing Markdown, use [**semantic line breaks**](https://sembr.org/):

- One sentence per line.
- No blank line between closely related sentences.
- Blank line between distinct thoughts/paragraphs.

This keeps diffs clean and source readable.

---

When writing code, always check if there are linter or style configurations in the repository that you should adopt.

Example: If a Ruby project has `.rubocop.yml` ensure the code you write matches the preferences specified there.

---

Git and GitHub workflow rules live in:

@~/.config/agents/rules/git.md

---

When opening a PR, always assign it to `@mokagio`.

---

When posting to GitHub using my account (PR comments, issue comments, reviews, etc.), always close with a note like:

> *Posted by AGENT (MODEL) on behalf of @mokagio with approval.*

Replace `AGENT` and `MODEL` with the tool and model in use (e.g., "Claude", "Opus 4.6").
This applies to any public-facing action taken through my identity.

---

When working with the GitHub CLI (`gh`), consult [`agents/gh-reference.md`](gh-reference.md) for auth setup, token overrides, API patterns, and known gotchas.

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

**Close the loop on every change.**

After modifying code, verify it works — don't assume.
After verification fails, fix and verify again.
Repeat until clean or stuck.

Concretely:

- After editing code → run the relevant tests or build.
- After a test/build fails → read the output, fix, re-run.
- After pushing to a remote → check CI (e.g. `/ci-monitor`). If it fails, diagnose from the logs, fix, push, and check again.
- After opening a PR → confirm checks pass before reporting it as done.

Never hand back work with an untested change or an unverified push.
One cycle of "edit → hope it works" is not enough; the loop closes when the result is confirmed.

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

At the start of a session, if it's the first interaction of the day, greet briefly and suggest one actionable thing.
Check `~/.me/prompts/log/` to determine if today's log exists yet (if it does, this isn't the first session).

Suggestions to rotate through, in priority order:

- If yesterday's prompt log exists but no retro does → "Should we run `/prompt-retro` on yesterday's prompts?"
- If `~/.me/prompts/retros/` has a recent retro with a top pattern → remind about that pattern
- If there are pending items in `~/.me/patterns.md` → surface one

Keep it to 1-2 lines. Don't dump a wall of suggestions.
Example: "Good morning, Gio. Yesterday's prompts aren't reviewed yet — want to run `/prompt-retro`?"
