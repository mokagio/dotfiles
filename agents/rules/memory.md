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

**Recall before researching how to do something:**

Before reaching for the web, upstream docs, or a wide codebase search to answer "how do I do X here", run an engram recall on the topic first.
If we've done X before, the answer — including the gotchas the docs won't tell you — is likely already a memory.

Recall by *topic*, not only by project: the memory may have been written while working in a different repo.
Search the concrete nouns (`a8c-secrets ci`, `match s3 setup`, `notarization keychain`), and try a couple of phrasings before concluding there's nothing.

Triggers: "how do I set up X", "how does X work in CI", "what's the right way to configure X", or any moment you're about to `WebSearch` a tool or workflow that belongs to our stack.

Web research is the fallback, not the first move.
If recall comes back empty and you end up figuring it out from scratch, that's a memory worth saving when you're done.

**When to save a memory:**

Two paths capture memories, and they divide the work:

- **SessionEnd hook** — `hooks/session-end.sh` mines the transcript at exit and commits memories automatically, with no chatter. This is the default net. Trust it to sweep up the long tail; you do not need to inline-save everything you notice.
- **Inline save** — reserve for the high-value, easy-to-lose cases where waiting for session end is a real risk: a correction or feedback from the user, a sharp gotcha, or an explicit "remember this". Save those immediately, the moment they occur.

If unsure whether an inline save is warranted, save it — pruning is cheaper than rediscovery, and the hook would catch it anyway.

**Save silently. Never announce the intent to save.**

When an inline save is warranted, execute it — do not narrate the decision and do not ask.
Phrases like "I'd also save this as a memory", "this is worth remembering", "want me to save that?", or "I'll note this for next time" are forbidden: they surface intent instead of acting, which is just permission-seeking in a statement's clothing.
`/engram:remember` already backgrounds the work and commits it, so saving costs the conversation nothing.
Either save it (silently, or with a note no longer than "Noted.") or don't — there is no announce-and-defer.

**How to save:**

Prefer `/engram:remember` when that skill is available — it handles creation, commit, and dedup in one step.

If the skill is unavailable, follow this workflow end-to-end. **Do not stop after creating the file** — saving a memory is not done until it is committed.

1. Create the file:
   `zk --notebook-dir=~/Developer/mokacoding-pty-ltd/engram new ~/Developer/mokacoding-pty-ltd/engram/memories/ --title "..." --extra type=<type> --extra scope=<scope> --print-path --no-input`
   If `zk` is unavailable, write a markdown file directly with frontmatter matching `.zk/templates/memory.md`.
2. Edit the file to add content.
3. Commit the file via the `/commit` skill, one memory per commit.
   This step is mandatory — an uncommitted memory is lost on the next branch switch and invisible to recall on other machines.

**Work log:**

When actual project work begins or resumes, append to `~/Developer/mokacoding-pty-ltd/engram/work-log/YYYY-MM-DD.md`.
Do not append to the work log when only answering recall, context, or planning questions.
Create the file with a `# Work Log — YYYY-MM-DD` header if it doesn't exist.
Format: `- HH:MM — [project] one-line description`
