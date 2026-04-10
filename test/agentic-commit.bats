#!/usr/bin/env bats

# Tests for scripts/agentic-commit

SCRIPT_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
SCRIPT="$SCRIPT_DIR/scripts/agentic-commit"

setup() {
  REPO="$(mktemp -d)"
  git -C "$REPO" init --quiet
  git -C "$REPO" config user.email "test@test.com"
  git -C "$REPO" config user.name "Test"

  # Seed the repo with an initial commit
  echo "init" > "$REPO/init.txt"
  git -C "$REPO" add init.txt
  git -C "$REPO" commit -m "Initial commit" --quiet

  MSG_FILE="$(mktemp)"
  echo "Test commit message" > "$MSG_FILE"
}

teardown() {
  rm -rf "$REPO"
  rm -f "$MSG_FILE"
}

@test "stages files and commits" {
  echo "hello" > "$REPO/a.txt"
  run "$SCRIPT" -C "$REPO" -m "$MSG_FILE" -- a.txt
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"Test commit message"* ]]
  # Verify it's a real commit hash + title
  [[ "$output" =~ ^[0-9a-f]+ ]]
}

@test "prints short hash and title on success" {
  echo "content" > "$REPO/file.txt"
  result="$("$SCRIPT" -C "$REPO" -m "$MSG_FILE" -- file.txt)"
  # Should be exactly one line: <hash> <message>
  [[ "$(echo "$result" | wc -l)" -eq 1 ]]
  [[ "$result" =~ ^[0-9a-f]+\ Test\ commit\ message$ ]]
}

@test "stages multiple files" {
  echo "a" > "$REPO/a.txt"
  echo "b" > "$REPO/b.txt"
  run "$SCRIPT" -C "$REPO" -m "$MSG_FILE" -- a.txt b.txt
  [[ "$status" -eq 0 ]]
  # Both files should be in the commit
  committed="$(git -C "$REPO" diff-tree --no-commit-id --name-only -r HEAD)"
  [[ "$committed" == *"a.txt"* ]]
  [[ "$committed" == *"b.txt"* ]]
}

@test "works without -C flag from repo directory" {
  echo "hello" > "$REPO/a.txt"
  # Run from inside the repo
  result="$(cd "$REPO" && "$SCRIPT" -m "$MSG_FILE" -- a.txt)"
  [[ "$result" =~ ^[0-9a-f]+ ]]
}

@test "reads message from stdin when -m omitted" {
  echo "hello" > "$REPO/a.txt"
  result="$(echo "Stdin commit message" | "$SCRIPT" -C "$REPO" -- a.txt)"
  [[ "$result" =~ ^[0-9a-f]+\ Stdin\ commit\ message$ ]]
}

@test "stdin heredoc with multiline message" {
  echo "hello" > "$REPO/a.txt"
  result="$("$SCRIPT" -C "$REPO" -- a.txt <<'EOF'
Multiline title

Body line one.
Body line two.
EOF
)"
  [[ "$result" =~ ^[0-9a-f]+\ Multiline\ title$ ]]
}

@test "empty stdin exits 1" {
  echo "hello" > "$REPO/a.txt"
  run bash -c 'echo -n "" | '"'$SCRIPT'"' -C '"'$REPO'"' -- a.txt'
  [[ "$status" -eq 1 ]]
  [[ "$output" == *"empty message"* ]]
}

@test "no files provided exits 2" {
  run "$SCRIPT" -C "$REPO" -m "$MSG_FILE"
  [[ "$status" -eq 2 ]]
}

@test "no args exits 2" {
  run "$SCRIPT"
  [[ "$status" -eq 2 ]]
}

@test "missing message file exits 1" {
  echo "hello" > "$REPO/a.txt"
  run "$SCRIPT" -C "$REPO" -m /nonexistent/path -- a.txt
  [[ "$status" -eq 1 ]]
  [[ "$output" == *"not found"* ]]
}

@test "commit failure preserves exit code" {
  # Create a pre-commit hook that rejects
  mkdir -p "$REPO/.git/hooks"
  cat > "$REPO/.git/hooks/pre-commit" <<'HOOK'
#!/usr/bin/env bash
echo "hook rejected" >&2
exit 1
HOOK
  chmod +x "$REPO/.git/hooks/pre-commit"

  echo "hello" > "$REPO/a.txt"
  run "$SCRIPT" -C "$REPO" -m "$MSG_FILE" -- a.txt
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"hook rejected"* ]]
}

@test "files without -- separator" {
  echo "hello" > "$REPO/a.txt"
  run "$SCRIPT" -C "$REPO" -m "$MSG_FILE" a.txt
  [[ "$status" -eq 0 ]]
  [[ "$output" =~ ^[0-9a-f]+ ]]
}
