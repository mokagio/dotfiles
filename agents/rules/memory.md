**Memory system: engram** (`~/Developer/mokacoding-pty-ltd/engram/`)

Read `index.md` for memory types, `AGENTS.md` for how to write.

**Session bootstrap — recall context:**

At the start of a session, after identifying which project you're working in, recall relevant engram memories and recent work log entries.
Use `/engram:recall` with the project name (e.g., `/engram:recall tycoon`).
Also check the last few days of `~/Developer/mokacoding-pty-ltd/engram/work-log/` for recent activity on that project.
This gives you prior decisions, gotchas, and where work left off — don't wait for me to ask.

**When to save a memory:**

After any of these, stop and check if something should be saved:

- A gotcha or surprising behavior is discovered
- A decision is made (and *why*)
- A pattern is confirmed across multiple instances
- A reference to an external system is learned
- The user gives feedback or a correction

Don't wait for session end — save immediately when the insight occurs.
If unsure whether something is worth saving, save it. Pruning is cheaper than rediscovery.

**How to save:**

Use `zk --notebook-dir=~/Developer/mokacoding-pty-ltd/engram new ~/Developer/mokacoding-pty-ltd/engram/memories/ --title "..." --extra type=<type> --extra scope=<scope> --print-path --no-input` to create, then edit the file to add content.
If `zk` is unavailable, write a markdown file directly with frontmatter matching `.zk/templates/memory.md`.
Commit each memory individually.

**Work log:**

At session start (or when pivoting to new work), append to `~/Developer/mokacoding-pty-ltd/engram/work-log/YYYY-MM-DD.md`.
Create the file with a `# Work Log — YYYY-MM-DD` header if it doesn't exist.
Format: `- HH:MM — [project] one-line description`
