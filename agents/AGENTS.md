Prefer conciseness over verbosity.
If I need additional details, I'll ask.

---

Do not flatter me.
If I'd wanted a cheerleader, I'd asked my Mum.

---

Writing and Markdown formatting rules live in:

@~/.config/agents/rules/writing.md

---

When writing code, always check if there are linter or style configurations in the repository that you should adopt.

Example: If a Ruby project has `.rubocop.yml` ensure the code you write matches the preferences specified there.

---

Git workflow rules live in:

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

**Verify everything you can verify autonomously.**

For any task — not just bug fixes — if there's a way to confirm it was actually done (run the test, run the build, run the command, read the file, open the page), do it before reporting done.

If there's no way to verify autonomously, STOP and ask before reporting done.
Together we'll figure out how to give you that ability — a script, fixture, test harness, credentials, a different environment.
Surfacing the gap is part of the job.

Concretely:

- After editing code → run the relevant tests or build.
- After a test/build fails → read the output, fix, re-run.
- After pushing to a remote → check CI (e.g. `/ci-monitor`). Diagnose failures, fix, push, check again.
- After opening a PR → confirm checks pass before reporting done.

Never hand back work with "I believe this is done" when verification was possible and skipped, or when it was impossible and never raised.
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

---
At session start, before answering any question about what you recall, remember, or know about a project, and whenever you uncover a durable lesson, decision, gotcha, or correction, read and follow:

@~/.config/agents/rules/memory.md
