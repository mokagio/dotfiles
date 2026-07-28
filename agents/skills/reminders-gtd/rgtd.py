#!/usr/bin/env python3
"""Helpers for the reminders-gtd skill.

Wraps the two error-prone operations against keith/reminders-cli:
resolving an item to its stable externalId, and adding a block atop a
note without clobbering existing content, mangling curly quotes, or
fumbling the attribution footer.

Subcommands:
  resolve  LIST QUERY        find items whose title contains QUERY
  show-ids LIST [--open-only] list every item as ID<tab>title
  note     LIST ID --agent A add a stdin block + footer atop an item's note
"""
import re
import sys
import json
import subprocess
import argparse
from datetime import datetime

# Roughly one phone screen of note before scrolling starts.
BLOCK_SOFT_LIMIT = 700

# The user's opt-out, written into a note by hand. Agents must never emit
# either spelling, or they lock the item against their own next run.
NFR_RE = re.compile(r"\bNFR\b|no further research", re.IGNORECASE)


def _nfr(item):
    return bool(NFR_RE.search(item.get("notes") or ""))


def _show(list_name):
    out = subprocess.run(
        ["reminders", "show", list_name, "--format", "json"],
        capture_output=True, text=True,
    )
    if out.returncode != 0:
        sys.exit("reminders show failed: %s" % out.stderr.strip())
    return json.loads(out.stdout or "[]")


def _find(items, ext_id):
    return next((r for r in items if r["externalId"] == ext_id), None)


def cmd_resolve(args):
    q = args.query.lower()
    matches = [r for r in _show(args.list) if q in r["title"].lower()]
    for r in matches:
        snippet = (r.get("notes") or "").replace("\n", " ")[:60]
        print("%s\t%s\t%s" % (r["externalId"], r["title"], snippet))
    if not matches:
        sys.exit("no match for %r in list %r" % (args.query, args.list))
    if len(matches) > 1:
        sys.stderr.write(
            "WARNING: %d matches — confirm the right ID before any destructive op\n"
            % len(matches)
        )


def cmd_show_ids(args):
    for r in _show(args.list):
        if args.open_only and _nfr(r):
            continue
        flags = " [+notes]" if r.get("notes") else ""
        flags += " [NFR]" if _nfr(r) else ""
        print("%s\t%s%s" % (r["externalId"], r["title"], flags))


def cmd_note(args):
    r = _find(_show(args.list), args.id)
    if r is None:
        sys.exit(
            "id %s not in list %r — it may have synced away; re-resolve before writing"
            % (args.id, args.list)
        )
    if _nfr(r) and not args.force:
        sys.exit(
            "REFUSED: %r is marked NFR — the user has said no further research.\n"
            "Nothing was written. Use --force only if the user asked for this write."
            % r["title"]
        )

    block = sys.stdin.read().rstrip("\n")
    if not block.strip():
        sys.exit("empty block on stdin")

    stamp = datetime.now().astimezone().strftime("%Y-%m-%d %H:%M %Z")
    footer = "[agent: %s | %s]" % (args.agent, stamp)
    existing = (r.get("notes") or "").rstrip("\n")
    new = block + "\n" + footer + ("\n\n" + existing if existing else "")

    w = subprocess.run(
        ["reminders", "edit", args.list, args.id, "--notes", new],
        capture_output=True, text=True,
    )
    if w.returncode != 0:
        sys.exit("reminders edit failed: %s" % w.stderr.strip())

    r2 = _find(_show(args.list), args.id)
    if r2 is None or not (r2.get("notes") or "").startswith(block.splitlines()[0]):
        sys.exit("VERIFY FAILED: block not on top after write")
    if len(block) > BLOCK_SOFT_LIMIT:
        sys.stderr.write(
            "WARNING: block is %d chars — it is read on a phone, aim for under %d\n"
            % (len(block), BLOCK_SOFT_LIMIT)
        )
    print("OK: noted on %r (%d chars, footer %s)"
          % (r2["title"], len(r2.get("notes") or ""), stamp))


def main():
    p = argparse.ArgumentParser(prog="rgtd", description="reminders-gtd helpers")
    sub = p.add_subparsers(required=True)

    pr = sub.add_parser("resolve", help="find items whose title contains QUERY")
    pr.add_argument("list")
    pr.add_argument("query")
    pr.set_defaults(func=cmd_resolve)

    ps = sub.add_parser("show-ids", help="list every item as ID<tab>title")
    ps.add_argument("list")
    ps.add_argument("--open-only", action="store_true",
                    help="hide items the user marked NFR")
    ps.set_defaults(func=cmd_show_ids)

    pa = sub.add_parser("note", help="add a stdin block + footer atop a note")
    pa.add_argument("list")
    pa.add_argument("id")
    pa.add_argument("--agent", default="claude/opus-5",
                    help="attribution label, e.g. claude/opus-5")
    pa.add_argument("--force", action="store_true",
                    help="write even if the item is marked NFR")
    pa.set_defaults(func=cmd_note)

    args = p.parse_args()
    args.func(args)


if __name__ == "__main__":
    main()
