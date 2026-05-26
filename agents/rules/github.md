**GitHub interaction rules.**

---

When opening a PR, always assign it to `@mokagio`.

---

When posting to GitHub using my account (PR comments, issue comments, reviews, etc.), always close with a note like:

> *Posted by AGENT (MODEL) on behalf of @mokagio with approval.*

Replace `AGENT` and `MODEL` with the tool and model in use (e.g., "Claude", "Opus 4.6").
This applies to any public-facing action taken through my identity.

---

When working with the GitHub CLI (`gh`), consult [`agents/gh-reference.md`](../gh-reference.md) for auth setup, token overrides, API patterns, and known gotchas.

---

**PR descriptions: keep them lean.**

Before drafting, check the repo for a template under `.github/` (e.g. `PULL_REQUEST_TEMPLATE.md`, `pull_request_template.md`, or `.github/PULL_REQUEST_TEMPLATE/`). If one exists, follow it.

Otherwise, a PR description should cover:

- **Rationale** — why this change, what motivated it.
- **Intentional tradeoffs** — choices that look surprising in the diff but were deliberate, if any.
- **Gotchas** — anything a reviewer or future reader needs to know that the diff alone won't tell them.
- **How to test** — concrete steps or links to CI runs.

**Length target: the whole description fits on one screen.**
Each section is 1–3 sentences, not paragraphs.
If a section has nothing important to say, omit it — don't pad with throat-clearing.
Bullets are fine when listing distinct items; prose is fine when explaining one thing. Pick one, don't mix.
Cut every sentence that doesn't change a reviewer's understanding.
When in doubt, default to terser.

**Do not explain the implementation** — the diff shows it.
Phrases like "the change works by …", "this PR introduces a helper that …", "we then iterate over …" describe code the reviewer can read.
Describe the *why* and the *constraints*, not the *how*.

**Do not pre-empt every possible reviewer question.**
Anticipatory paragraphs ("you might wonder why we …", "note that this does not …") are noise unless the concern is genuinely non-obvious.
Trust the reviewer to ask if they care.

Do **not** include a "change list" or file-by-file enumeration.
The diff already shows what changed; reviewers are smart enough to read it as long as the PR is small.
If the PR is not small, list the changes at the architecture overview only, as a guide to navigate the review.

Do not include "How it differs from sibling repos" sections, failure-trace appendices, or rule-by-rule design justification — those belong in commit message bodies or a lessons doc, not the PR.
If crucial information is tracked in the commit messages, mention it so the reviewers can look at them, but do not duplicate it.

Do not require reviewers to have context about adjacent or sibling projects.
If a sentence only makes sense to someone who knows another repo's setup, rewrite it so the point stands on its own.
Cross-project references are fine when they motivate the change, but only with a link the reviewer can follow.
Without a link, drop the reference and explain the technical point directly.

**"How to test" — recommend the project's task runner, not the underlying tool.**
If the repo has a fastlane lane, a `Makefile` target, a `rake` task, or an npm script that runs the relevant test/build, that is the command to write in the PR.
Do not recommend `xcodebuild test …` when `bundle exec fastlane test` exists; do not recommend a raw `jest` invocation when `yarn test` is wired up.
The wrapper encodes the project's expected env, build config, simulator selection, and test filter — bypassing it gives the reviewer (and CI) a different result than the author got.
Same rule applies to commands you run yourself while preparing the PR — see [`closing-the-loop.md`](closing-the-loop.md) for the local verification rationale.
