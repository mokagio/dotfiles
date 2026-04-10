**Memory system: engram** (`~/Developer/mokacoding-pty-ltd/engram/`)

Read `index.md` for memory types, `AGENTS.md` for how to write.

**When asked what you recall, remember, or know about a project:**

- Do not answer from general repo inspection alone.
- First identify the project name.
- Then perform engram recall for that project as the first recall step.
- Prefer `/engram:recall <project>` when that skill is available.
- If the skill is unavailable, run the raw recall command: `node "$ENGRAM_DIR/bin/engram.js" recall "<project>" --dir "$ENGRAM_DIR"`.
- Only if the skill and raw recall command are both unavailable or fail should you fall back to direct file lookup or search in `~/Developer/mokacoding-pty-ltd/engram/`.
- Also check the last few days of `~/Developer/mokacoding-pty-ltd/engram/work-log/` for recent activity on that project.
- Only then answer, clearly separating recalled memory from fresh repo inspection.
- If engram recall could not be performed, say so explicitly instead of implying a memory-based answer.
- This is a read-only flow. Do not append to the work log or save a memory when only answering a recall or context question.

**Session bootstrap — recall context:**

At the start of a session, after identifying which project you're working in, perform engram recall immediately.
Prefer `/engram:recall <project>` when that skill is available.
If the skill is unavailable, run the raw recall command: `node "$ENGRAM_DIR/bin/engram.js" recall "<project>" --dir "$ENGRAM_DIR"`.
Only if the skill and raw recall command are both unavailable or fail should you fall back to direct file lookup or search in `~/Developer/mokacoding-pty-ltd/engram/`.
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

When actual project work begins or resumes, append to `~/Developer/mokacoding-pty-ltd/engram/work-log/YYYY-MM-DD.md`.
Do not append to the work log when only answering recall, context, or planning questions.
Create the file with a `# Work Log — YYYY-MM-DD` header if it doesn't exist.
Format: `- HH:MM — [project] one-line description`
