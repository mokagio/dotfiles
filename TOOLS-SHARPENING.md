# Tools Sharpening

> **Do not commit this file.** It's a working scratchpad, not part of the repo.

Efficiency improvements identified 2026-03-02.
Ordered by expected impact.

## Notes

- 2026-04-10 — Codex/engram environment mismatch.
  Codex followed the `memory.md` rule but did not run the raw `engram` recall command when it depended on `ENGRAM_DIR`.
  Likely cause: `ENGRAM_DIR` is available in Claude Code sessions but not guaranteed in Codex sessions.
  Rule guidance for Codex should prefer absolute paths for `engram` commands instead of shell variables inherited from Claude-specific setup.
  Noted by Codex.

## High impact — daily friction reducers

- [ ] **Replace Antigen with zinit (or direct sourcing).**
  Antigen is abandonware (last meaningful commit 2018).
  It evaluates plugins on every shell start — slow and unmaintained.
  Zinit has lazy-loading and turbo mode.
  Alternatively, source the ~5 plugins directly.

- [x] **Prune Vim plugin cruft.**
  `vimrc.plugs` loads legacy plugins almost certainly unused:
  `vim-carthage`, `vim-cucumber`, `vim-jade`, `elm-vim`, `csv`, `vim-ps1`, `sourcekittendaemon`, `vim-xcode`, `vim-pbxproj`.
  ~10 plugins adding to startup time.
  If regular Vim isn't used anymore, drop `vimrc.plugs` entirely and maintain only the NeoVim path.

- [x] **Consolidate version managers: fnm + rbenv → mise.**
  Both `fnm` and `mise` are in the Brewfile; both manage Node.
  `mise` is the superset (Ruby, Node, Go, Python).
  Going all-in on mise would also drop `rbenv` and simplify `zshenv`.

- [x] **Remove stale aliases.**
  These reference tools/workflows that look dormant:
  - `tu`/`tub` — Carthage
  - `rn`/`rni` — React Native
  - `bpi`/`bip` — CocoaPods (`bundle exec pod install`)
  - `m` — MacDown
  - `ao` — Android Studio
  - `mp`/`npg`/`lnq` — morning/night pages

  Dead aliases add cognitive load and pollute tab-completion.

## Medium impact — workflow compounders

- [ ] **Build `/wrap-up` skill.**
  `patterns.md` notes this is "often skipped."
  Patterns don't get captured → breaks the feedback loop the whole system depends on.
  Highest-ROI compounding opportunity.

- [ ] **Build `/migrate` skill.**
  File-by-file migration pattern (pick → transform → test → commit → next) has been used multiple times.
  Encoding it makes the next batch faster.

- [ ] **Build permission rule authoring skill.**
  The heredoc-newline matching bug causes repeated permission prompts for `git commit`.
  A skill that generates correct rules and warns about known gotchas would at least document the workaround.

- [ ] **Add `git amend` interceptor.**
  `patterns.md` says `--amend` usage regresses every other day.
  A git alias would enforce the rule:
  ```gitconfig
  [alias]
  amend = "!echo 'Use a new commit. See AGENTS.md.' && false"
  ```

- [x] **Extract `gco()` to a standalone script.**
  The worktree-aware checkout function is buried in `aliases.git.sh`.
  Move to `scripts/git-checkout-worktree` on PATH → `git checkout-worktree` works everywhere.

## Low effort — quick wins

- [ ] **Merge `aliases.navigation.sh` into `aliases.sh`.**
  6 lines don't justify a separate file and source call.

- [x] **Remove Travis CI completion from `zshrc`.**
  Travis CI is effectively dead.

- [ ] **Add `.zshrc.local` template.**
  Support exists but there's no example in the repo.
  A commented template helps on new machine setup.

## New skills to build

- [ ] **`/wrap-up` — end-of-session memory capture.**
  Identified in `patterns.md` as "often skipped."
  The entire feedback loop (patterns → retros → overnight reviews) depends on data being logged.
  Single highest-ROI skill to build.
  Scope: review session context, prompt for learnings, append to `~/.me/patterns.md` + project memory.

- [ ] **`/repo-onboard` — scaffold agent instructions for new repos.**
  Currently a manual check-and-prompt loop on every repo entry.
  Skill would detect missing `CLAUDE.md`/`AGENTS.md`, read the repo's language/build system,
  and scaffold from a template.
  `patterns.md` ranks this #2 in compounding opportunities.

- [ ] **`/migrate` — file-by-file migration orchestrator.**
  Proven pattern from Quick+Nimble → Swift Testing, SwiftLint batch, JUnit migration.
  Loop: pick file → transform → run tests → commit → next.
  Currently done manually despite being the same pattern every time.

- [ ] **`/adr` — append ADR entry.**
  Auto-number, date, format.
  Trivial to build, removes friction from documenting decisions.

- [ ] **`/triage` — SLA zero pass.**
  `patterns.md` says this has been recommended 6+ times without action.
  Skill would pull Linear inbox + stale issues and walk through them interactively.
  Gives structural protection to the "admin items accumulate" pattern.

## Custom agents to consider

- [ ] **Code review agent.**
  Reviews PRs across 8+ repos.
  First-pass review: check conventions, flag missing tests, verify label/milestone, run lint.
  `ci-monitor` + `fix-pr-checks` handle post-push — this covers pre-merge.

- [ ] **Cert/provisioning agent.**
  `patterns.md` says 7 cert/provisioning incidents in 30 days, each 20-45min.
  Specialized agent for the fetch → validate → update → re-sign loop.
  High time savings, but needs careful scoping around secrets.

## Extract from SKILL.md into scripts

These are reusable pieces of logic currently embedded in skill definitions.

- [ ] **`scripts/date-window`** — from `ai-channel-digest` + `ai-daily-picks`.
  Monday → 3 days back; other days → yesterday.
  Used in 2+ skills and `nightly.sh`.
  Pure bash, no dependencies.

- [ ] **`scripts/gh-infer-label`** — from `fix-pr-checks`.
  Rule-based: scan PR title/body/diff → Bug, Feature, Enhancement, Tooling, etc.
  Useful from CLI too, not just inside Claude.

- [x] **`scripts/gh-infer-milestone`** — from `fix-pr-checks`.
  Next open milestone or release-branch match.
  Pure `gh api` logic.

- [ ] **`scripts/git-resolve-dir`** — from `commit` skill.
  Worktree-aware `.git` dir finder.
  Needed by the commit skill and potentially other git scripts.

- [ ] **`analyze-permissions.sh` → permission-authoring skill.**
  The nightly audit already mines `permission-requests.jsonl` for frequent commands.
  A skill could take that output and generate correct `settings.json` rules,
  embedding known glob-matching bugs (trailing `*`, heredoc newlines).

## Observations and resilience gaps

- [ ] **Agent skill-discovery gap.**
  `patterns.md` notes the agent "rediscovers what skills already encode" —
  multi-repo rollout was done manually despite existing skills.
  Fix applied (MEMORY.md maps task types to skills) but could be stronger:
  a `/help-skills` command listing available skills with when-to-use summaries.

- [ ] **MCP graceful degradation.**
  5 of 6 A8C skills depend on MCP providers (Linear, Slack, wpcom).
  When MCP is down, most of the pipeline fails.
  `overnight-review` has local-first fallback; the others don't.
  Worth adding graceful degradation to `sprint-update` and `ai-daily-picks`.

- [ ] **No skill smoke tests.**
  Skills are pure SKILL.md — no way to verify they still work after edits.
  Even a simple smoke-test script per skill (invoke with known input, check output format)
  would catch regressions.

## Architecture check

- [ ] **Verify A8C `settings.json` deny-rule inheritance.**
  The A8C project-level settings allow specific tool patterns but don't inherit deny rules from global settings.
  If Claude Code evaluates project-level before global, a project-level allow could override a global deny.
  Verify the merge behavior matches intent.

## New tools to install

- [ ] **`eza`** — modern `ls` with git awareness, tree view, icons.
  You already alias `cat=bat`; `ls=eza` is the natural companion.
  `eza --git --icons` shows file status inline.

- [ ] **`fd`** — fast `find` alternative, respects `.gitignore`.
  Pairs with fzf: `export FZF_DEFAULT_COMMAND='fd --type f'` makes Ctrl-T and `**<Tab>` faster and cleaner.

- [ ] **`delta`** — git pager with syntax highlighting, side-by-side diffs, line numbers.
  Drop-in via `[core] pager = delta` in gitconfig.
  Big upgrade over raw diff output, especially for large diffs.

- [ ] **`lazygit`** — TUI for git.
  `tig` covers viewing; lazygit adds interactive staging, rebase, cherry-pick, conflict resolution.
  Complements the worktree workflow.

- [ ] **`httpie`** or **`curlie`** — friendlier HTTP client than `curl` for API testing.
  `curlie` uses curl under the hood but with httpie-style syntax.

- [ ] **`gh dash`** — GitHub CLI extension, PR/issue dashboard TUI.
  Gives a single view across multiple repos without leaving the terminal.

- [ ] **`gh markdown-preview`** — renders local Markdown in the browser using GitHub's renderer.
  Preview READMEs, ADRs, PR descriptions exactly as GitHub will display them, without pushing.

- [ ] **`gh poi`** — post-merge cleanup extension.
  Switches to default branch, pulls, deletes local branch (and worktree), prunes remote refs.
  Automates the manual cleanup after merging a PR.
  May overlap with `git-worktree-prune` and `git-sweep` already in `scripts/`.

## TUIs to try

Identified 2026-04-10 from awesome-ratatui and awesome-tuis lists.

- [x] **`lt`** — unofficial TUI for Linear.app.
  Browse issues, update status, triage — without leaving the terminal.
  Direct replacement for browser context-switching to Linear.

- [ ] **`lazygit`** — (already listed above in "New tools to install").
  Interactive staging, rebase, cherry-pick, conflict resolution.
  Best-in-class TUI Git client; complements worktree workflow.

- [ ] **`crmux`** — TUI for monitoring multiple Claude Code sessions in tmux.
  Dashboard view over concurrent agent sessions.
  Useful when running background agents across repos.

- [ ] **`atuin`** — magical shell history with sync, search, and stats.
  Replaces `ctrl-r` with full-text search, per-directory filtering, and cross-machine sync.
  Big upgrade if still using default zsh history.

- [ ] **`mprocs`** — run multiple commands in parallel with separate output panes.
  Useful for running test suites or builds across repos simultaneously.

- [ ] **`serie`** — rich git commit graph in terminal.
  Nicer than `git log --graph` for understanding branch topology during release cuts.

- [ ] **`television`** — blazing fast fuzzy finder (fzf alternative in Rust).
  General productivity win; worth comparing against current fzf setup.

- [ ] **`ilmari`** — minimal tmux popup radar to track running agents.
  Lighter-weight alternative to crmux for quick agent status checks.

- [ ] **`kanash`** — learn kana in your terminal.
  Lightweight Japanese practice between builds.

## New fzf integrations (like `grb`)

- [ ] **fzf interactive staging** — replace `interactive-stage.rb`.
  `git diff --name-only | fzf -m --preview 'git diff --color=always {}'` → stage selected with Tab.
  Snappier than the Ruby script, native multi-select.

- [ ] **`fkill`** — fuzzy process killer.
  `ps aux | fzf | awk '{print $2}' | xargs kill`.
  Replaces `k9` when you don't remember the PID.

- [ ] **`fenv`** — fzf over `mise ls` to interactively switch/install runtime versions.

- [ ] **`git-fixup`** — select a recent commit via fzf, create `fixup!` commit, auto-rebase.
  `rebase.autosquash` is already on; this just streamlines the flow.

## New workflow scripts

- [ ] **`worktree-status`** — show all active worktrees with dirty/ahead/behind status.
  Quick "what am I working on" dashboard.
  Could be an alias or a script in `scripts/`.

## Neovim modernization

- [ ] **oil.nvim** or **mini.files** — replace NERDTree in Neovim with a buffer-based file explorer.
  Native LSP is already there; NERDTree is the last legacy piece.

- [ ] **telescope.nvim** — replace fzf.vim in Neovim.
  Native Lua, LSP-aware (find references, symbols), live grep with preview.
  Shell fzf integrations stay separate.

- [ ] **gitsigns.nvim** — replace vim-gitgutter in Neovim.
  Lua-native, faster, inline blame, hunk staging from the buffer.

## Redundant aliases

- [ ] **`ghs`/`gsh` — same command, pick one.**
  Both resolve to `git show HEAD`.
- [ ] **`ghp`/`gchp` — both `git checkout -p`.**
  Pick one and drop the other.
- [ ] **`ast`/`ao` — both open Android Studio.**
  Two aliases for the same app.

## Brewfile cleanup

- [ ] **Remove `hub`.**
  Fully superseded by `gh`. Comment already says "TODO: verify and remove."
- [ ] **Simplify `gh` tap to core.**
  `github/gh/gh` → `brew 'gh'` — now in Homebrew core.
- [ ] **Remove `rar`.**
  Gone from Homebrew. Has a FIXME comment.
- [ ] **Remove `the_silver_searcher`.**
  `ripgrep` covers the same use case and is already installed.

## Modernize

- [ ] **Fix `markdown-preview.nvim` install command.**
  `'do': 'cd app & yarn install'` — single `&` runs yarn in background without waiting for `cd`.
  Should be `&&`.
- [ ] **Silence Fastlane error on shells without Fastlane.**
  `zshrc` prints an error emoji on every shell start when Fastlane isn't installed.
  Guard with a `command -v fastlane` check or just drop the `else` branch.
