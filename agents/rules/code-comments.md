**Code comments: stop at the non-obvious.**

---

When a comment legitimately explains a hidden thing — a quirk of an external API, a subtle invariant, a workaround, behavior a reader can't deduce from the code in front of them — end it there.
Do not pad with sentences justifying ordinary choices the next line already evidences.
Phrases like "single source of truth", "for clarity", "to avoid duplication", "to keep things DRY" don't earn their keep — the code shows the choice was made; a reader doesn't need it defended.
If you find yourself appending such a justification to an otherwise legitimate comment, cut it.

A comment that earns its place can still be twice as long as it needs to be.
Once it's staying, tighten it: lead with the actionable point — when to remove it, what to change — then name the cause in one clause.
Cut the narrative reconstruction: the verbatim error string, the step-by-step account of how you diagnosed it, the transitive-dependency walk.
An upstream-issue link carries that depth for whoever wants it; the comment carries only what a reader needs in-place.

Padded — six lines replaying the diagnosis:

```ruby
# fastlane <= 2.235.0 crashes at startup on Ruby 3.3+ with "multi_json is not
# part of the bundle": Google stopped pulling it transitively and fastlane
# eagerly loads its Google Play actions, which require it through representable.
# fastlane re-added it as a direct dep for 2.236.0 — drop once the lock moves there.
gem 'multi_json'
```

Tight — same payload, the link holds the depth:

```ruby
# Workaround: fastlane <= 2.235.0 won't boot on Ruby 3.3+ without multi_json (fastlane/fastlane#30062).
# Drop once the lock is on fastlane >= 2.236.0.
gem 'multi_json'
```

The same bar applies to orientation and pointer comments.
Header lines that paraphrase the block underneath ("Loop the test files…", "Run the tests with Ruby…") are noise — the block speaks for itself.
Cross-references like "see `foo/bar/*`" right above a line that already iterates, imports, or reads `foo/bar/*` are noise — the reader is already going there.
And if the fact you're stating is already documented in the file the next line touches (e.g. "this uses stdlib X" when the file itself says so at the top), the comment is duplicating what's one click away.
If the comment is asking the reader to look somewhere they're about to look anyway, or to learn something the next file they open will tell them, delete it.

Enumerating the inputs a self-naming command consumes ("Reads `FOO`, `BAR` from the environment" above a `fastlane notarize_app` call) is the same noise dressed up as a dependency contract.
That contract is declared where the command is defined; the call site doesn't need it restated.

Provenance narratives are that noise pointed upstream instead of down.
Where an external command's cert, secret, or toolchain comes from, what it writes, which other repos lean on it — that genealogy isn't needed in-place to run the line.
Collapse it to a one-line pointer that the thing is external ("This command comes from the CI toolkit") and let the toolkit's own docs hold the depth.

Environment archaeology earns no more.
Justifying a setup step by inventorying the runtime — "the agent image ships bun/go/rust but no Node, unlike the mac/linux agents that get it from the nvm plugin, so we install it ourselves" — narrates infrastructure the step already implies.
The `install nodejs` call is its own reason; cut the contrast with how other machines do it.

A bare sibling-repo name in parentheses ("Workaround (per simplenote-electron): …") is not a followable reference — it's the unlinked cross-project pointer the GitHub rules already warn against.
Keep the workaround note; drop the parenthetical.

This applies to config and ownership files too, not just code.
A `CODEOWNERS` line like `Gemfile* @org/team`, or a `dependabot.yml` block, is self-explanatory; a header comment naming what the block does ("Route Dependabot Ruby PRs to the tooling team") is the same paraphrase noise.
Tacking a ticket reference onto it ("See PROJ-123") does not redeem it — if a reviewer needs the why, it belongs in the PR description or commit body, where it's read once, not as a permanent comment re-explaining a line that already speaks for itself.

Do not add a comment for tooling that does not exist yet.
A Makefile `## Run all lint tasks` on a target named `lint`, justified as "ready if you later add a `help` target", is noise twice over: the target name already says it, and the consumer is hypothetical.
Write the comment when the consumer lands, not in anticipation of it.
The target/key/variable name is the documentation; a self-documenting-Makefile annotation earns its place only once a `help` target actually greps for it.
