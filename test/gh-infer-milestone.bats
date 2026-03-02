#!/usr/bin/env bats

# Tests for scripts/gh-infer-milestone
#
# Strategy: place a mock `gh` script first on PATH that returns canned data
# instead of hitting the GitHub API.

SCRIPT_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
SCRIPT="$SCRIPT_DIR/scripts/gh-infer-milestone"

setup() {
  # Create a temp dir for the mock gh
  MOCK_DIR="$(mktemp -d)"
  PATH="$MOCK_DIR:$PATH"

  # Default mock: returns pre-filtered tab-separated output matching what
  # `gh api --jq` would produce from realistic WordPress-iOS-like data.
  cat > "$MOCK_DIR/gh" <<'MOCK'
#!/usr/bin/env bash
if [[ "$*" == *milestones* ]]; then
  printf '%s\t%s\t%s\n' 14  "Someday"       ""
  printf '%s\t%s\t%s\n' 41  "Pending"        ""
  printf '%s\t%s\t%s\n' 62  "High Priority"  ""
  printf '%s\t%s\t%s\n' 326 "26.7 ❄️"        "2026-02-23T00:00:00Z"
  printf '%s\t%s\t%s\n' 329 "26.8"           "2026-03-16T00:00:00Z"
  printf '%s\t%s\t%s\n' 330 "26.9"           "2026-04-16T00:00:00Z"
elif [[ "$*" == *repos/* ]]; then
  # The script calls: gh api "repos/<r>" --jq '.default_branch'
  # Return the already-filtered result (just the branch name).
  echo "trunk"
fi
MOCK
  chmod +x "$MOCK_DIR/gh"
}

teardown() {
  rm -rf "$MOCK_DIR"
}

# --- trunk/main/develop base branch ---

@test "trunk base: picks next non-frozen milestone with due date" {
  run "$SCRIPT" owner/repo trunk
  [ "$status" -eq 0 ]
  [[ "$output" == *"329"* ]]
  [[ "$output" == *"26.8"* ]]
}

@test "main base: same behavior as trunk" {
  run "$SCRIPT" owner/repo main
  [ "$status" -eq 0 ]
  [[ "$output" == *"329"* ]]
}

@test "develop base: same behavior as trunk" {
  run "$SCRIPT" owner/repo develop
  [ "$status" -eq 0 ]
  [[ "$output" == *"329"* ]]
}

@test "master base: same behavior as trunk" {
  run "$SCRIPT" owner/repo master
  [ "$status" -eq 0 ]
  [[ "$output" == *"329"* ]]
}

@test "skips undated milestones (Someday, Pending, High Priority)" {
  run "$SCRIPT" owner/repo trunk
  [ "$status" -eq 0 ]
  [[ "$output" != *"Someday"* ]]
  [[ "$output" != *"Pending"* ]]
  [[ "$output" != *"High Priority"* ]]
}

@test "skips frozen milestone (❄️)" {
  run "$SCRIPT" owner/repo trunk
  [ "$status" -eq 0 ]
  [[ "$output" != *"26.7"* ]]
}

# --- release/* base branch ---

@test "release branch: matches version in milestone title" {
  run "$SCRIPT" owner/repo release/26.7
  [ "$status" -eq 0 ]
  [[ "$output" == *"326"* ]]
  [[ "$output" == *"26.7"* ]]
}

@test "release branch: matches non-frozen version" {
  run "$SCRIPT" owner/repo release/26.9
  [ "$status" -eq 0 ]
  [[ "$output" == *"330"* ]]
  [[ "$output" == *"26.9"* ]]
}

# --- default branch discovery ---

@test "no base branch: discovers default and uses it" {
  run "$SCRIPT" owner/repo
  [ "$status" -eq 0 ]
  [[ "$output" == *"329"* ]]
}

# --- unknown base branch ---

@test "unknown base branch: falls back to next milestone" {
  run "$SCRIPT" owner/repo feature/something
  [ "$status" -eq 0 ]
  [[ "$output" == *"329"* ]]
}

# --- edge cases ---

@test "no milestones: exits 1" {
  cat > "$MOCK_DIR/gh" <<'MOCK'
#!/usr/bin/env bash
if [[ "$*" == *milestones* ]]; then
  # --jq on empty array produces no output
  true
else
  echo "trunk"
fi
MOCK
  chmod +x "$MOCK_DIR/gh"

  run "$SCRIPT" owner/repo trunk
  [ "$status" -eq 1 ]
  [[ "$output" == *"No open milestones"* ]]
}

@test "all milestones frozen: exits 2" {
  cat > "$MOCK_DIR/gh" <<'MOCK'
#!/usr/bin/env bash
if [[ "$*" == *milestones* ]]; then
  printf '%s\t%s\t%s\n' 1 "1.0 ❄️"    "2026-01-01T00:00:00Z"
  printf '%s\t%s\t%s\n' 2 "1.1 frozen" "2026-02-01T00:00:00Z"
else
  echo "trunk"
fi
MOCK
  chmod +x "$MOCK_DIR/gh"

  run "$SCRIPT" owner/repo trunk
  [ "$status" -eq 2 ]
}

@test "release branch with no matching milestone: exits 2" {
  run "$SCRIPT" owner/repo release/99.0
  [ "$status" -eq 2 ]
}

@test "missing repo argument: exits non-zero" {
  run "$SCRIPT"
  [ "$status" -ne 0 ]
}
