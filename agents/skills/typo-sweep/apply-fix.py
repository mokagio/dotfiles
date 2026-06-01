#!/usr/bin/env python3
"""
Apply a single typo fix to a file, with two safety guards.

Usage: apply-fix.py <file> <line_num> <old_word> <new_word> [expected_line]

Replaces the first whole-word match of <old_word> with <new_word> on the
target line. The fix is refused (loudly, exit 1) rather than applied wrongly
when either guard trips:

1. Content match (drift-safe). When <expected_line> is given — pass the verbatim
   line text the scan saw (the part after `path:line:col:` in scan.sh output) —
   the substitution only happens on a line whose content equals it. If line
   <line_num> still matches, that line is used; otherwise the file is searched
   for the (unique) line with that content. A line that has since changed or
   been fixed upstream is skipped, never guessed at. Omit <expected_line> to
   fall back to plain line-number addressing.

2. Single-quote guard. A correction containing an apostrophe (don't, doesn't,
   today's, ...) is refused when the match sits inside a single-quoted string
   literal — the apostrophe would terminate the string (e.g. RSpec `it '...'`,
   JS `it('...')`) and break the build. Comments and double-quoted strings are
   safe and proceed normally.

Exit codes: 0 applied · 1 skipped (drift / word absent / would break string) · 2 usage.
"""
import sys
import re
from pathlib import Path

if len(sys.argv) not in (5, 6):
    print("Usage: apply-fix.py <file> <line_num> <old_word> <new_word> [expected_line]", file=sys.stderr)
    sys.exit(2)

path = Path(sys.argv[1])
line_num = int(sys.argv[2])
old = sys.argv[3]
new = sys.argv[4]
expected = sys.argv[5] if len(sys.argv) == 6 else None

lines = path.read_text().splitlines(keepends=True)
pattern = re.compile(r'\b' + re.escape(old) + r'\b')


def body(line):
    return line.rstrip('\n').rstrip('\r')


def has_word(line):
    return pattern.search(line) is not None


# --- Choose the target line index ---------------------------------------------
if expected is None:
    if line_num < 1 or line_num > len(lines):
        print(f"Line {line_num} out of range for {path}", file=sys.stderr)
        sys.exit(1)
    idx = line_num - 1
    if not has_word(lines[idx]):
        print(f"SKIP(no-word) {path}:{line_num} '{old}' not on line: {lines[idx]!r}", file=sys.stderr)
        sys.exit(1)
else:
    # Drift-safe: locate the line by its original content, not its number.
    candidates = [i for i, l in enumerate(lines) if body(l) == expected and has_word(l)]
    if 1 <= line_num <= len(lines) and (line_num - 1) in candidates:
        idx = line_num - 1                       # fast path: line hasn't drifted
    elif len(candidates) == 1:
        idx = candidates[0]                      # moved, but unambiguous
    elif not candidates:
        print(f"SKIP(drift) {path}: original line for '{old}->{new}' not found "
              f"(changed or already fixed upstream)", file=sys.stderr)
        sys.exit(1)
    else:
        print(f"SKIP(ambiguous) {path}: {len(candidates)} lines match the original "
              f"content for '{old}->{new}'; refusing to guess", file=sys.stderr)
        sys.exit(1)

line = lines[idx]
match = pattern.search(line)

# --- Single-quote guard -------------------------------------------------------
if "'" in new:
    in_single = in_double = False
    for ch in line[:match.start()]:
        if ch == "'" and not in_double:
            in_single = not in_single
        elif ch == '"' and not in_single:
            in_double = not in_double
    if in_single:
        print(f"SKIP(single-quote) {path}:{idx + 1} '{old}->{new}' sits inside a "
              f"single-quoted string; apostrophe would break it", file=sys.stderr)
        sys.exit(1)

lines[idx] = pattern.sub(new, line, count=1)
path.write_text(''.join(lines))
print(f"OK {path}:{idx + 1} {old}->{new}")
