#!/usr/bin/env python3
"""
Apply a single typo fix to a file. Uses exact line match for safety.
Usage: apply-fix.py <file> <line_num> <old_word> <new_word>

The replacement is done on the specified line only, replacing whole-word
matches of <old_word> with <new_word>. Preserves case style heuristically
but accepts that we pass exact-case words already.
"""
import sys
import re
from pathlib import Path

if len(sys.argv) != 5:
    print("Usage: apply-fix.py <file> <line_num> <old_word> <new_word>", file=sys.stderr)
    sys.exit(2)

path = Path(sys.argv[1])
line_num = int(sys.argv[2])
old = sys.argv[3]
new = sys.argv[4]

lines = path.read_text().splitlines(keepends=True)
if line_num < 1 or line_num > len(lines):
    print(f"Line {line_num} out of range for {path}", file=sys.stderr)
    sys.exit(1)

idx = line_num - 1
line = lines[idx]

# Word-boundary substitution. Use literal old, escape regex specials.
pattern = re.compile(r'\b' + re.escape(old) + r'\b')
match_count = len(pattern.findall(line))
if match_count == 0:
    print(f"No match for '{old}' on line {line_num} of {path}", file=sys.stderr)
    print(f"Line: {line!r}", file=sys.stderr)
    sys.exit(1)

new_line = pattern.sub(new, line)
lines[idx] = new_line
path.write_text(''.join(lines))
print(f"OK {path}:{line_num} {old}->{new} ({match_count} replacement)")
