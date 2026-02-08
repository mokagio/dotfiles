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

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
```

Commit message style:

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

- Do NOT use `git -C <worktree-path>` — each unique
path creates a separate permission prompt, cluttering
local settings.
- Instead, `cd` into the worktree first, then run
plain `git` commands (`git status`, `git diff`, etc.).
- This keeps command strings stable and permission
approvals reusable.
