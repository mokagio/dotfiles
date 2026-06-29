---
name: dump-state
description: |
  Append a timestamped, super-condensed summary of the current session — plus any open loops to close later — to today's dump file at ~/.me/quick-dumps/YYYY-MM-DD.md.
  Use when asked to "dump state", "dump the session", "jot this down", "save where we're at", or invokes /dump-state.
allowed-tools: Bash(date *), Bash(mkdir *), Bash(cat *), Bash(test *), Bash(ls *), Read, Write, Edit
user-invocable: true
---

# Dump State

Capture where this session stands in one terse, timestamped block so a future session (or a future you) can pick it back up.

One file per day at `~/.me/quick-dumps/YYYY-MM-DD.md`; each invocation appends a new block. Never overwrite or rewrite earlier blocks — the file is an append-only log.

## Workflow

1. Resolve the paths and timestamp in one shot:

   ```bash
   mkdir -p ~/.me/quick-dumps
   date +'%Y-%m-%d %H:%M %Z'
   ```

   The date portion (`YYYY-MM-DD`) is the filename; the time portion is the block heading.

2. Check whether today's file already exists: `test -f ~/.me/quick-dumps/YYYY-MM-DD.md`.

3. Compose the block (format below). Pull it from the actual session — what was done, what's still open. Be ruthless: a reader skims this in seconds.

4. Write it:
   - **File does not exist** → create it with the day header, then the block.
   - **File exists** → append the block only. Read the file first so you append after the last block, and do not duplicate the day header.

5. Report the file path and how many blocks it now holds. Nothing else.

## File format

```markdown
# Quick Dumps — YYYY-MM-DD

## HH:MM — <≤8-word session title>
- <bullet: outcome or decision, one line each>
- <2–5 bullets total; cut anything a reader doesn't need>

**Open loops:**
- [ ] <unfinished thread that needs closing later — be specific and actionable>
- [ ] <include where it lives: PR #, branch, file, command to resume>
```

When there are no open loops, write `**Open loops:** none.` rather than an empty checklist — the absence is itself a signal.

## Constraints

- **Super condensed.** Summary bullets are fragments, not prose. If a bullet runs past one line, it's doing too much.
- **Append-only.** Earlier blocks and earlier days are never edited. Each block is a fixed snapshot of that moment.
- **Open loops are the point.** A vague loop ("finish the thing") is useless — name the artifact and the next concrete step so it's resumable cold.
- **No secrets.** Tokens, keys, customer data, long payloads never go in the dump.
- Convert relative time ("yesterday", "earlier") to absolute before writing — the block is read out of context later.
