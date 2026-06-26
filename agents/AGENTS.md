Prefer conciseness over verbosity.
If I need additional details, I'll ask.
Trust the reader: don't restate what context already supplies, and don't pre-empt edge cases that don't need defending.

---

Do not flatter me.
If I'd wanted a cheerleader, I'd asked my Mum.

---

Never abbreviate Buildkite as "BK" in chat, code comments, or commit messages.
Always write "Buildkite" in full.
I may type `bk` to save time; you have no such constraint.

Similarly, the fastlane tool's name is lowercase — `fastlane`, never `Fastlane`.

---

Writing and Markdown formatting rules live in:

@~/.config/agents/rules/writing.md

---

When writing code, always check if there are linter or style configurations in the repository that you should adopt.

Example: If a Ruby project has `.rubocop.yml` ensure the code you write matches the preferences specified there.

---

Code comment rules — stop at the non-obvious, cut provenance and environment archaeology — live in:

@~/.config/agents/rules/code-comments.md

---

Git workflow rules live in:

@~/.config/agents/rules/git.md

---

GitHub interaction rules live in:

@~/.config/agents/rules/github.md

---

Bash scripting rules live in:

@~/.config/agents/rules/bash.md

---

For changes spanning more than 2-3 files, use plan mode first.
Explore the codebase, present a roadmap, then execute.
This prevents wasted context from trial-and-error edits.

---

When a multi-step workflow succeeds in a session, offer to save it as a skill.
Don't wait for me to ask.

When I ask to create a global skill, make it cross-agent and track it in the dotfiles repo.
Do not create only an agent-specific local skill install.

---

Rules for tracking CLI wrapper opportunities live in:

@~/.config/agents/rules/cli-opportunities.md

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
- After pushing to a remote or running `gh pr create` → invoke `/ci-monitor` on the affected PR immediately, in the same turn, no asking.
  **Start the monitor without asking.** Don't say "want me to watch the build?" — just spawn it (background agent or `/ci-monitor`).
  In multi-PR sessions, each push and each `gh pr create` triggers its own monitor — don't batch them or defer to "the end".
  If `/ci-monitor` reports `danger/pr-check` failures, chain into `/fix-pr-checks` for that PR and keep monitoring until Danger re-runs.
  I'd rather kill a monitor I don't want than have to tell you to start one.
- After opening a PR → confirm checks pass before reporting done.

Never hand back work with "I believe this is done" when verification was possible and skipped, or when it was impossible and never raised.
One cycle of "edit → hope it works" is not enough; the loop closes when the result is confirmed.

---

After any rebase or merge that touches an Xcode project file (`*.pbxproj`), run `/audit-xcodeproj` before proceeding.
Merge conflicts in project files often produce silent corruption (truncated entries, dangling UUIDs) that only surfaces later as build failures.

---

iOS and Apple-platform project rules live in:

@~/.config/agents/rules/ios.md

---

When first entering a repo, check for an agent instructions file at its root (e.g., `CLAUDE.md`, `AGENTS.md`).
If there isn't one, prompt me to create it before doing anything else.
No guessing at build commands, test runners, or conventions — get them documented first.

---

When writing YAML, only quote strings when the content requires it (e.g., special characters, reserved words, embedded colons).
Prefer unquoted strings for cleaner, leaner files.

---

At session start, before answering any question about what you recall, remember, or know about a project, and whenever you uncover a durable lesson, decision, gotcha, or correction, read and follow:

@~/.config/agents/rules/memory.md

---

Rules for interpreting tool output — verifying what a thing is before acting on it, investigating surprising results before narrating, and the limits of headless rendering — live in:

@~/.config/agents/rules/tool-results.md

---

Rules for closing the verification loop efficiently — tiering changes by validation cost, deciding when to run locally vs. push and watch, and the Tier 2 traps that bite without a smoke invocation — live in:

@~/.config/agents/rules/closing-the-loop.md

---

Rules for testing — when to write a permanent test, where it lands, and turning ad-hoc smoke verification into committed coverage — live in:

@~/.config/agents/rules/testing.md

---

Use the Linear GraphQL API over the Linear MCP, unless the API isn't functional.
The MCP surface is limited (e.g. no comment tool).

---

Fastlane rules — gitignoring autogenerated files and lane signature conventions — live in:

@~/.config/agents/rules/fastlane.md

---

Swift Package Manager rules — pinning dependency updates by exact version when a release is tagged — live in:

@~/.config/agents/rules/swift-package-manager.md
