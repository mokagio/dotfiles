Prefer conciseness over verbosity.
If I need additional details, I'll ask.

---

Do not flatter me.
If I'd wanted a cheerleader, I'd asked my Mum.

---

I have `gh` as an alias for `git checkout`, so when using GitHub's `gh` tool, call it from `/opt/homebrew/bin/gh`.

---

If I ask you to commit for me, first show me a preview of the message (this is just while I train you to write the way I like).

The message should terminate with:

```
---

Generate with the help of Claude Code, https://code.claude.com

Co-Authored-By: Claude MODEL <noreply@anthropic.com>
```

Note: `MODEL` is the model used to write the code.

**Commit message style**:

- The title describes *what* the change does — keep it sufficient on its own.
- Only add a body if there's a *why* that isn't obvious from the title.
- If the why isn't obvious, ask me rather than guessing.
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
Update `CLAUDE.md` with rule for code fencing
```

---

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

Always use Git worktrees for branch work — never work directly on the main branch.
At the start of a feature, project, or plan, create a worktree.
Once the work is merged or abandoned, remove it.

Place worktrees in a sibling `<repo>-worktrees/` folder:

```
~/Developer/
├── my-repo/                  ← main checkout (trunk)
└── my-repo-worktrees/
    ├── feature-x/
    └── bugfix/
```

**Worktree Git Commands**

- Create the worktree **before** making any changes — not after.

---

**NEVER use `git -C <path>`** for any reason.
Each unique path creates a separate permission prompt, cluttering local settings.
Instead, `cd` into the directory first (as a standalone command), then run plain `git` commands.
This applies everywhere — worktrees, submodules, any repo path.

Never prefix Bash commands with `cd path &&` either.
The permission system matches on the first token, so `cd` bypasses all allowed-command rules.

- For git: `cd` into the repo first as a standalone command, then run `git` commands separately.
- For everything else: use absolute paths (e.g., `ls /full/path` not `cd /full/path && ls`).

---

Use `/usr/bin/env` and single parameter in shebangs. Example:

```bash
#!/usr/bin/env bash

set -eu
```
