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

Do **not** include a "change list" or file-by-file enumeration.
The diff already shows what changed; reviewers are smart enough to read it as long as the PR is small.
If the PR is not small, list the changes at the architecture overview only, as a guide to navigate the review.

Do not include "How it differs from sibling repos" sections, failure-trace appendices, or rule-by-rule design justification — those belong in commit message bodies or a lessons doc, not the PR.
If crucial information is tracked in the commit messages, mention it so the reviewers can look at them, but do not duplicate it.
