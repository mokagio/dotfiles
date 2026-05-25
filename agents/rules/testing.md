**Testing rules: persist verification as repo tests.**

---

When writing or substantively changing code with logic worth verifying — parsing, conditional flow, edge cases, regex, anything fiddly enough that you ran a smoke test in the moment — write a permanent test alongside the change.

The ad-hoc smoke tests you run during development are throwaway.
Convert them into repo tests so the same cases run forever and future edits don't silently regress the behavior.
"It passed the one-off shell loop I just ran" is not coverage; it's a moment in time.

---

**When to write a test:**

- The change has branching logic, parsing, regex, or any condition that distinguishes one input from another.
- You found yourself constructing a smoke matrix (multiple inputs, expected outputs) to convince yourself the code works.
- The behavior is fiddly enough that a future edit could plausibly break it without the author noticing.
- The function is at the boundary of the system (CLI args, file input, JSON parsing, HTTP payloads).

**When not to:**

- Pure renames, mechanical refactors with no behavior change.
- One-liner glue code where the test would be longer than the implementation and equally trivial.
- Throwaway scripts.

---

**Where the test lands:**

- If the repo already has a test framework (bats, RSpec, Minitest, Vitest, XCTest, Swift Testing, pytest, ...), match it.
- If the repo has tests but no runner entry point (Makefile, `scripts/test`, npm script, ...), surface this — adding a one-line `make test` target is a small cost for a big ergonomic win, and unlocks CI later.
- If the repo has no tests at all, default to writing one anyway, in the framework that suits the language, under a conventional path (`test/`, `tests/`, `spec/`). Bringing the first test into a repo is more valuable than writing none.

Language defaults when starting from zero:

- Shell scripts → `bats-core`
- Ruby → match the project; otherwise RSpec
- Swift → Swift Testing if the project is on Swift 5.10+, otherwise XCTest
- JavaScript/TypeScript → match the project's runner; Vitest is a reasonable default for new projects
- Python → pytest

---

**What the test should look like:**

- Assert the **contract**, not the implementation.
  A test that locks in internal structure (private function shapes, intermediate state) creates churn without protection.
- Be hermetic when feasible: tmpdirs, fixtures, env stubs.
  Avoid depending on machine-global state, network, or wall-clock time.
- One assertion per case where practical, but multi-assert is fine when the cases share setup.
- Name cases after the *behavior* they pin down (`Read of similar-prefix dir is allowed`), not the implementation step (`grep regex returns 0`).

---

**Critical**: the work is not done when the smoke test passes in your shell. It is done when the verification is committed to the repo and will run again. Whenever you find yourself iterating on a behavior in this session, ask: "if I commit this and walk away, what stops a future edit from regressing it?" If the answer is "nothing", write the test before you stop.
