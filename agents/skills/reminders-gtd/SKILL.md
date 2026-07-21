---
name: reminders-gtd
description: |
  Drive Apple Reminders as a GTD system from the command line — capture to an inbox, read and search across lists, enrich items with notes, complete, delete, and triage with the 2-minute rule.
  Use when asked to add/capture a task or idea, "add to my inbox / Stuff list", reschedule or move an item, process/triage the inbox, find 2-minute items, or write research findings into a reminder's note.
  macOS + iCloud only, via the `reminders` CLI (keith/reminders-cli). Read/capture/enrich is fully supported; moving between lists and rescheduling due dates are not (see Gaps).
allowed-tools: Bash(reminders *), Bash(python3 *), Bash(osascript *), Read
user-invocable: true
---

# Reminders as a GTD system

Apple Reminders is EventKit-backed, so the `reminders` CLI is a real read/write interface that syncs through iCloud safely — unlike Notes, which has no API.
This skill is how to drive it without the two things that bite: **stale list positions** and a **store that changes underneath you**.

`rgtd.py` sits next to this file and wraps the two fiddly operations (resolve-to-ID and append-to-note).
Everything else is plain `reminders` subcommands.

## The three golden rules

1. **Address items by `externalId`, never by list position.**
   The `#` index in `reminders show` re-sorts between reads and as other devices sync.
   Acting on a stale index deletes or completes the wrong item.
   Resolve title → ID, confirm the title, then act on the ID.
2. **The store is eventually-consistent and syncs live.**
   Lists can appear mid-session; open counts drift as the phone works the list concurrently.
   Any snapshot is a moving target — re-resolve the ID at the moment you act, not from a listing you took earlier.
3. **Verify every write.**
   After a note write, read it back and confirm the block landed.
   After a destructive op, confirm the target is gone and nothing else changed.

## What the CLI can and cannot do

Supported — the capture-and-review half of GTD:

- **Read** everything, all fields: `reminders show <list> --format json` (title, notes, dueDate, priority, isCompleted, externalId). Null fields are *omitted*, so parse defensively.
- **Capture**: `reminders add <list> "text" [--notes ..] [--due-date "tomorrow 9am"] [--priority ..]`. Natural-language dates work and respect local time.
- **Enrich**: `reminders edit <list> <id> --notes "..."` (title and notes only). `edit` accepts an `externalId` or an index — always pass the ID.
- **Complete / delete**: `reminders complete <list> <id>`, `reminders delete <list> <id>`.
- **Lists**: `reminders show-lists`, `reminders new-list "..."`.

Not supported — the clarify half. Do **not** promise these via the CLI:

- **Move between lists** — no `move` subcommand.
- **Reschedule a due date** or **change priority** after creation — `edit` only touches title/notes.
- **Tags, subtasks, recurrence** — no public EventKit API exposes them at all.

See **Gaps and escape hatches** before attempting any of these.

## Workflow

### Resolve before you act

```bash
SKILL_DIR="$HOME/.agents/skills/reminders-gtd"   # or ~/.claude/skills/reminders-gtd
python3 "$SKILL_DIR/rgtd.py" resolve "Stuff" "godaddy"
# -> B603F650-...  Update card on Godaddy   <note snippet>
```

`resolve` prints `ID<tab>title<tab>note-snippet` for every title match and warns on stdout if more than one matches.
On a multi-match, disambiguate and confirm with the user before any delete/complete — duplicate titles are common in a capture pile.
`show-ids <list>` dumps every item as `ID<tab>title` when you need the whole list with IDs.

### Capture

Send undecided inputs to the inbox list as-is; do not clarify at capture time.

```bash
reminders add "Stuff" "Buy packing cubes for backpack"
```

### Complete or delete (destructive — confirm first)

Resolve to an ID, confirm the title in the same breath, then act on the ID:

```bash
reminders complete "Stuff" EFDC2C3C-....
reminders delete   "Stuff" B603F650-....
```

When handing the user a menu to pick from, give them a **frozen numbered table** that pins each row to an ID (`1 → <id> → title`).
"delete 3" then means the ID in row 3 of *your* table, not position 3 in the app.
Re-resolve those IDs immediately before acting anyway — the table can go stale between the message and the command.

### Write research / notes into an item

Use `append`, not `edit` — it read-modify-writes so it never clobbers existing content, preserves curly quotes and apostrophes byte-for-byte, and stamps the attribution footer for you:

```bash
python3 "$SKILL_DIR/rgtd.py" append "Stuff" 939B911B-... --agent claude/opus-4.8 <<'EOF'
Best everyday card for Woolworths points, no travel.
1. Amex Membership Rewards — $108/yr — 2,500 MR = 2,000 EDR pts = $10.
Bottom line: it's a 2% play; treat the points as a rounding error.
EOF
```

The footer it appends is `[agent: <label> | YYYY-MM-DD HH:MM AEST]`.
Keep note blocks tight — they are read on a phone: short lines, plain text, no markdown tables.

## Triage: the 2-minute rule

When processing the inbox, a 2-minute item is one whose **next action is unambiguous and doable in one short sitting**.
Filter hard:

- **Exclude "research X", "buy Y", "write Z".** These are projects in disguise — each hides a decision or a sub-workflow. (A "buy packing cubes" line became a full research-and-clarify loop.)
- **A title is not a scope.** `Amex`, `Handles`, `Share with MPAS` read as 2-minute but hide unknowns only the user can resolve. If it hides a decision, it is not a 2-minute item.
- Good 2-minute items: send one message, follow an account, rename a thing, book one appointment, a physical stopgap.

## Finding the inbox

Do not trust list names or the EventKit default list to find the capture point — both mislead (a default list of `Writing`, a `Reminders` list that is actually a beach-packing list).
Identify the inbox by **content shape**: undated, high count, heterogeneous.
When automating capture, take the inbox list name as explicit config; do not detect it.

## Gaps and escape hatches

**Move / reschedule / priority are not in the CLI.**
The tempting shortcut — AppleScript — is a trap: `osascript` can move an item (a true move; `externalId` survives), but it only sees a subset of lists (grouped/folder lists are invisible), so it fails outright on most of them.
Do not build a workflow on AppleScript moves.
The correct fix is an EventKit-direct helper (Swift or PyObjC): `EKReminder.calendar`, `dueDateComponents`, and `priority` are all writable there.
Until that helper exists, tell the user these operations are manual in the app rather than faking them.

**Notes grow unbounded.**
`append` stacks a new block + footer each round; there is no length guard.
Fine for a couple of passes, awkward on a phone after that.
If a note is being revised repeatedly, prefer superseding the stale block over appending yet another.

## Permissions

EventKit access is granted to the *responsible process* up the call chain, not to the `reminders` binary.
The first call from a new terminal or agent may trigger a one-time TCC prompt (or hang waiting on one you cannot see).
If calls fail or hang on a fresh setup, run `reminders show-lists` once by hand in Terminal to settle the grant.
