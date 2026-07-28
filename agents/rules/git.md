**NEVER use `git --git-dir=<path>`** — it bypasses permission rules.
**NEVER prefix Bash commands with `cd path &&` or `cd path;`.**
**NEVER chain commands with `&&` or `;` after a `cd`.**

The permission system matches on the first token of each Bash call.
`git --git-dir` creates unique permission prompts per path.
`cd foo && git ...` makes the first token `cd`, bypassing all allowed-command rules.

`git -C <path>` is fine — permission rules cover it.

**Correct patterns:**

- `git -C /path/to/repo status` (single Bash call)
- `cd /path/to/repo` then `git status` (two separate Bash calls)

**Wrong patterns (never do these):**

- `git --git-dir=/path/to/repo/.git status`
- `cd /path/to/repo && git status`
- `cd /path/to/repo; git status`

For non-git commands, prefer absolute paths (`ls /full/path`) over `cd` + relative.

---

The message should terminate with:

```
---

Generated with the help of AGENT, AGENT_URL

Co-Authored-By: AGENT MODEL <EMAIL>
```

Replace `AGENT` and `AGENT_URL` with the tool in use (e.g., "Claude Code", "https://code.claude.com").
Replace `MODEL` with the model used to write the code.

**Commit message style**:

- The title describes *what* the change does — keep it sufficient on its own.
- If there's a *why* that isn't absolutely obvious from the title, elaborate it in the body.
- Use the body to track rationale for the change and other conversation details.
- If the why isn't obvious to you, ask me rather than guessing.
- Never repeat the "what" in the body; the diff covers that.
- Titles must stay within the recommended 50 characters.
  Drop backtick fencing from the title if needed to fit.

---

**NEVER amend commits** — create a new commit instead.
Amending requires force-pushing, which is destructive and blocked by hooks.

Always use the `/commit` skill when creating git commits.
Never craft commit messages or run `git commit` directly.

Commits should be **small and atomic** and so should be the way you approach changes.

When doing mechanical migration work, commit each file migrated individually, unless there are dependencies.

Example: When migrating a Swift test suite from Quick+Nimble to modern Swift Testing, operate on one file at a time and commit it.
If a test double needs to be updated in order for a test to be migrated, then do the necessary update, then the migration, and commit them both in the same commit.
That's what I mean with small and atomic.

---

**Branch names:**

- If a Linear issue is connected, use Linear's own branch name verbatim: `ainfra-2751-enable-azure-artifact-signing-for-cortex-windows-buildkite`.
  That is the exact shape — lowercased issue ID, then the kebab-cased title, and **no `mokagio/` prefix**.
  Never invent `mokagio/ainfra-NUM-...`; the Linear format has no username segment.
- No Linear issue, shared repo: prefix with `mokagio/` so authorship is obvious at a glance.
- No Linear issue, personal repo: short self-explanatory name, no prefix.

---

Always use the `/worktree` skill when creating Git worktrees.
Never run `git worktree add` directly.

On personal projects, work directly on `main` by default — commit and push straight to it — and only create a worktree when I explicitly ask for one.
On work projects, every new task gets its own worktree, even if you're already inside one.
When you can't tell which kind of project you're in, ask me.

Either way, a worktree is scoped to a single piece of work; unrelated changes must not land there.
Create it at the start of the feature, project, or plan, and remove it once the work is merged or abandoned.

Place worktrees in `.git-worktrees/` inside the repo root:

```
~/Developer/
└── my-repo/
    ├── .git-worktrees/       ← gitignored globally
    │   ├── feature-x/
    │   └── bugfix/
    └── src/
```

This keeps worktrees inside the repo's sandbox, avoiding permission prompts for `cd`.

**Worktree Git Commands**

- Create the worktree **before** making any changes — not after.
- Always branch from an up-to-date default branch.
  Discover the default branch yourself (`git remote show origin | grep 'HEAD branch'`), then fetch and use `origin/<default>` as the start point.
- If you are currently inside a worktree for a different task, `cd` to the main checkout first, then create the new worktree from there.

---
