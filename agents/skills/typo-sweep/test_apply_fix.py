#!/usr/bin/env python3
"""
Tests for apply-fix.py. Self-contained (no pytest needed): `python3 test_apply_fix.py`.
Each case pins a behavior of the contract, not the implementation.
"""
import subprocess
import sys
import tempfile
from pathlib import Path

SCRIPT = Path(__file__).with_name("apply-fix.py")
failures = []


def run(content, args):
    """Write content to a tmp file, run apply-fix.py with args, return (rc, text_after, stderr)."""
    with tempfile.NamedTemporaryFile("w", suffix=".txt", delete=False) as f:
        f.write(content)
        p = f.name
    proc = subprocess.run(
        [sys.executable, str(SCRIPT), p, *map(str, args)],
        capture_output=True, text=True,
    )
    after = Path(p).read_text()
    Path(p).unlink()
    return proc.returncode, after, proc.stderr


def check(name, cond):
    print(f"{'ok' if cond else 'FAIL'} - {name}")
    if not cond:
        failures.append(name)


# 1. Plain apply (4-arg) on a comment line.
rc, after, _ = run("    // ensure it doesnt exist\n", [1, "doesnt", "doesn't"])
check("comment fix applies", rc == 0 and "doesn't exist" in after)

# 2. Word absent on the target line -> skip, file untouched.
rc, after, err = run("    // nothing to fix here\n", [1, "doesnt", "doesn't"])
check("word-absent skips", rc == 1 and after == "    // nothing to fix here\n" and "no-word" in err)

# 3. Single-quote guard refuses apostrophe into a single-quoted string.
src = "  it('user dont care') {\n"
rc, after, err = run(src, [1, "dont", "don't"])
check("single-quote string refused", rc == 1 and after == src and "single-quote" in err)

# 4. Same correction in a // comment is allowed.
rc, after, _ = run("  // user dont care\n", [1, "dont", "don't"])
check("apostrophe in comment allowed", rc == 0 and "don't care" in after)

# 5. Apostrophe inside a double-quoted string is fine.
rc, after, _ = run('  XCTAssert(x, "user dont care")\n', [1, "dont", "don't"])
check("apostrophe in double-quoted string allowed", rc == 0 and "don't care" in after)

# 6. Non-apostrophe correction inside single quotes still applies (guard is apostrophe-only).
rc, after, _ = run("  label: 'a seperate thing',\n", [1, "seperate", "separate"])
check("non-apostrophe fix in single quotes applies", rc == 0 and "separate thing" in after)

# 7. Drift: expected content moved to a different line number -> found and applied.
content = "header\nmoved\n    // ensure it doesnt exist\nfooter\n"
rc, after, _ = run(content, [99, "doesnt", "doesn't", "    // ensure it doesnt exist"])
check("drift content match applies at moved line", rc == 0 and "doesn't exist" in after)

# 8. Drift: original line gone (already fixed upstream) -> skip.
rc, after, err = run("    // ensure it doesn't exist\n", [1, "doesnt", "doesn't", "    // ensure it doesnt exist"])
check("drift missing line skips", rc == 1 and "doesn't exist" in after and "drift" in err)

# 9. Ambiguous: two identical original lines, line_num points to neither -> refuse.
content = "    // x doesnt y\nmid\n    // x doesnt y\n"
rc, after, err = run(content, [2, "doesnt", "doesn't", "    // x doesnt y"])
check("ambiguous content refused", rc == 1 and after == content and "ambiguous" in err)

# 10. Drift fast path: line_num correct and content matches -> applies there.
content = "a\n    // ensure it doesnt exist\nb\n"
rc, after, _ = run(content, [2, "doesnt", "doesn't", "    // ensure it doesnt exist"])
check("drift fast path applies", rc == 0 and "doesn't exist" in after)

print(f"\n{len(failures)} failure(s)" if failures else "\nall passed")
sys.exit(1 if failures else 0)
