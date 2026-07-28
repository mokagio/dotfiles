#!/usr/bin/env bats

# Tests for agents/skills/reminders-gtd/rgtd.py
#
# Strategy: place a mock `reminders` first on PATH, backed by a JSON state file
# that `show` reads and `edit` rewrites, so a write is observable on the next read.

SCRIPT_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
SCRIPT="$SCRIPT_DIR/agents/skills/reminders-gtd/rgtd.py"

setup() {
  MOCK_DIR="$(mktemp -d)"
  PATH="$MOCK_DIR:$PATH"
  export STATE="$MOCK_DIR/state.json"

  cat > "$STATE" <<'JSON'
[
  {"externalId": "AAA-111", "title": "Electrician for outside plug", "notes": "older block\n[agent: claude/opus-5 | 2026-07-01 09:00 AEST]"},
  {"externalId": "BBB-222", "title": "Buy new mouse"}
]
JSON

  cat > "$MOCK_DIR/reminders" <<'MOCK'
#!/usr/bin/env bash
case "$1" in
  show)
    cat "$STATE"
    ;;
  edit)
    # reminders edit <list> <id> --notes <text>
    python3 - "$3" "$5" <<'PY'
import json, os, sys
ext_id, notes = sys.argv[1], sys.argv[2]
path = os.environ["STATE"]
items = json.load(open(path))
for r in items:
    if r["externalId"] == ext_id:
        r["notes"] = notes
json.dump(items, open(path, "w"))
PY
    ;;
esac
MOCK
  chmod +x "$MOCK_DIR/reminders"
}

teardown() {
  rm -rf "$MOCK_DIR"
}

notes_of() {
  python3 -c '
import json, os, sys
items = json.load(open(os.environ["STATE"]))
print(next(r for r in items if r["externalId"] == sys.argv[1]).get("notes", ""))
' "$1"
}

# --- note: newest block on top ---

@test "new block lands above the existing note" {
  run bash -c "printf 'newest finding\n' | python3 '$SCRIPT' note 'One-off Inbox' AAA-111 --agent claude/test"
  [ "$status" -eq 0 ]
  [ "$(notes_of AAA-111 | head -1)" = "newest finding" ]
}

@test "existing content survives underneath" {
  printf 'newest finding\n' | python3 "$SCRIPT" note "One-off Inbox" AAA-111 --agent claude/test
  run notes_of AAA-111
  [[ "$output" == *"older block"* ]]
  [[ "$output" == *"2026-07-01 09:00 AEST"* ]]
}

@test "attribution footer follows its own block, not the note" {
  printf 'newest finding\n' | python3 "$SCRIPT" note "One-off Inbox" AAA-111 --agent claude/test
  run notes_of AAA-111
  [ "$(echo "$output" | sed -n 2p)" != "" ]
  [[ "$(echo "$output" | sed -n 2p)" == "[agent: claude/test | "* ]]
}

@test "two writes stack newest-first" {
  printf 'first\n' | python3 "$SCRIPT" note "One-off Inbox" BBB-222 --agent claude/test
  printf 'second\n' | python3 "$SCRIPT" note "One-off Inbox" BBB-222 --agent claude/test
  run notes_of BBB-222
  [ "$(echo "$output" | head -1)" = "second" ]
  [[ "$output" == *"first"* ]]
  # 'first' must come after 'second' in the note
  second_line="$(echo "$output" | grep -n '^second$' | cut -d: -f1)"
  first_line="$(echo "$output" | grep -n '^first$' | cut -d: -f1)"
  [ "$second_line" -lt "$first_line" ]
}

@test "write into an empty note leaves no leading blank line" {
  printf 'only block\n' | python3 "$SCRIPT" note "One-off Inbox" BBB-222 --agent claude/test
  [ "$(notes_of BBB-222 | head -1)" = "only block" ]
}

# --- guards ---

@test "block over the soft limit still writes but warns" {
  long="$(python3 -c 'print("x" * 800)')"
  run bash -c "printf '%s\n' '$long' | python3 '$SCRIPT' note 'One-off Inbox' BBB-222 --agent claude/test 2>&1"
  [ "$status" -eq 0 ]
  [[ "$output" == *"WARNING"* ]]
  [[ "$output" == *"read on a phone"* ]]
}

@test "unknown id fails instead of writing" {
  run bash -c "printf 'x\n' | python3 '$SCRIPT' note 'One-off Inbox' ZZZ-999 --agent claude/test"
  [ "$status" -ne 0 ]
  [[ "$output" == *"re-resolve before writing"* ]]
}

@test "empty stdin fails" {
  run bash -c "printf '' | python3 '$SCRIPT' note 'One-off Inbox' BBB-222 --agent claude/test"
  [ "$status" -ne 0 ]
  [[ "$output" == *"empty block"* ]]
}

# --- resolve ---

@test "resolve matches on a title substring, case-insensitively" {
  run python3 "$SCRIPT" resolve "One-off Inbox" "MOUSE"
  [ "$status" -eq 0 ]
  [[ "$output" == "BBB-222	Buy new mouse"* ]]
}

@test "resolve fails when nothing matches" {
  run python3 "$SCRIPT" resolve "One-off Inbox" "nonexistent"
  [ "$status" -ne 0 ]
}
