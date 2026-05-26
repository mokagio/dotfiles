# Closing the loop efficiently

Verifying changes is the job, but verification has a cost.
Tier each change to decide where validation happens.

## Tier 1 — always do, costs seconds

Run regardless of change type:

- Syntax: `bash -n`, `ruby -c`, YAML/JSON parse, linter for the language.
- `git diff` audit before staging — confirm hunks are mine and only mine.
- File-existence and path checks for any new references.

## Tier 2 — do unless setup is the bottleneck

Smoke-invoke the actual entry point with stubs/dummies.
The first meaningful failure tells me whether the dependency surface is sane.

- Fastlane lane: `MATCH_S3_ACCESS_KEY=fake bundle exec fastlane <lane>`.
  Failing at a network call = surface OK.
  Failing at constant resolution = bug to fix before push.
- npm/yarn script: run with stubs, watch for missing deps and typos.
- Build script: invoke with the env vars CI would set.
- Type checks, linters, unit tests for touched files.

### Use the project's task runner, not the underlying tool

When the repo wraps its build/test commands in a fastlane lane, a `Makefile` target, a `rake` task, or an npm/yarn script, **invoke the wrapper, not the underlying tool**.

- iOS: `bundle exec fastlane test` over `xcodebuild test -workspace … -scheme …`.
- Ruby: `bundle exec rake test` over `bundle exec ruby -Itest test/foo.rb`.
- C/C++: `make test` over hand-rolled `gcc`/`cmake` invocations.
- Node: `yarn test` or `npm test` over a raw `jest`/`vitest` call.

The wrapper encodes setup the underlying tool doesn't know about: env vars, build configurations, simulator/device selection, test filtering, retry behavior, code-coverage flags, output formatting CI consumes.
Bypassing it gets a different result than CI will, and reviewers who try to reproduce the test step using the recommended command will fail.

Discover the runner before improvising: check `fastlane/Fastfile`, `Makefile`, `Rakefile`, `package.json` scripts, `README` "How to test" / "Development" sections.
If none exists and the tool requires non-trivial flags to invoke correctly, surface that as a finding — adding a one-liner wrapper is usually a small change worth proposing — rather than recommending the raw command to the user.

This rule applies symmetrically to PR descriptions: see the "How to test" guidance in [`github.md`](github.md).

## Tier 3 — push and watch

No faithful local equivalent; faking one wastes more time than a CI iteration.

- Code signing (real cert + Apple trust eval).
- Notarization (Apple servers).
- CI-injected secrets (only on real agents).
- Pipeline-runtime env semantics (only the runner knows).
- VM-image-specific tooling (Python, Xcode SDK, system Ruby).

## Decision rule

Before pushing any change, ask:
**Does the change touch a code path I can load locally?**

Yes → Tier 2 minimum, even if it'll fail at a step I can't fully exercise.
The failure line is the data.

No → Tier 3, push and watch.
But write the commit with the expected failure in mind so I can compare CI output against my hypothesis.

The line:
it is fine to push when local setup is genuinely more expensive than a CI iteration.
It is not fine to skip Tier 2 when the validation is a 10-second invocation away.

## Verify the right target

Before running validation, confirm that the code under inspection is the actual target of the user's question.

Examples:

- PR question -> PR head checkout/worktree
- specific commit question -> that commit checked out or shown directly
- local branch question -> current branch is fine only if it matches the requested branch

Running the right test on the wrong tree does not close the loop.

## Frequent Tier 2 traps

- Lockfile changes (Gemfile.lock, package-lock.json, yarn.lock):
  always Tier 2.
  Loose `~>` pins in upstream gems mean a fresh resolve can install a too-old transitive dep that crashes at action-load.
- Plugin or module additions: same.
  Load the consumer code; do not trust a `--version` or `lanes` listing.
- Renames and refactors that do not change behaviour:
  Tier 1 is enough.
- Fastlane action changes:
  always invoke the lane after a gem bump.
  `fastlane lanes` is parse-only — it does not load action bodies.

## After a change

If verification was possible and skipped, do not say done.
If verification was impossible, surface the gap before saying done.
One cycle of "edit then hope it works" is not enough; the loop closes when the result is confirmed.
