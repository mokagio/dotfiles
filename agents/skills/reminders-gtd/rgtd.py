#!/usr/bin/env python3
"""Helpers for the reminders-gtd skill.

Wraps the two error-prone operations against keith/reminders-cli:
resolving an item to its stable externalId, and appending a block to a
note without clobbering existing content, mangling curly quotes, or
fumbling the attribution footer.

Subcommands:
  resolve  LIST QUERY        find items whose title contains QUERY
  show-ids LIST              list every item as  ID<tab>title
  append   LIST ID --agent A append a stdin block + footer to an item's note
"""
import sys
import json
import subprocess
import argparse
from datetime import datetime


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
        flag = " [+notes]" if r.get("notes") else ""
        print("%s\t%s%s" % (r["externalId"], r["title"], flag))


def cmd_append(args):
    r = _find(_show(args.list), args.id)
    if r is None:
        sys.exit(
            "id %s not in list %r — it may have synced away; re-resolve before writing"
            % (args.id, args.list)
        )
    block = sys.stdin.read().rstrip("\n")
    if not block.strip():
        sys.exit("empty block on stdin")

    stamp = datetime.now().astimezone().strftime("%Y-%m-%d %H:%M %Z")
    footer = "[agent: %s | %s]" % (args.agent, stamp)
    existing = (r.get("notes") or "").rstrip("\n")
    new = (existing + "\n\n" if existing else "") + block + "\n" + footer

    w = subprocess.run(
        ["reminders", "edit", args.list, args.id, "--notes", new],
        capture_output=True, text=True,
    )
    if w.returncode != 0:
        sys.exit("reminders edit failed: %s" % w.stderr.strip())

    r2 = _find(_show(args.list), args.id)
    if r2 is None or block.splitlines()[0] not in (r2.get("notes") or ""):
        sys.exit("VERIFY FAILED: block not present after write")
    print("OK: appended to %r (%d chars, footer %s)"
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
    ps.set_defaults(func=cmd_show_ids)

    pa = sub.add_parser("append", help="append a stdin block + footer to a note")
    pa.add_argument("list")
    pa.add_argument("id")
    pa.add_argument("--agent", default="claude/opus-4.8",
                    help="attribution label, e.g. claude/opus-4.8")
    pa.set_defaults(func=cmd_append)

    args = p.parse_args()
    args.func(args)


if __name__ == "__main__":
    main()
