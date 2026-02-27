#!/usr/bin/env bash

INPUT=$(cat)

FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# Only run on Ruby files
[[ "$FILE_PATH" == *.rb ]] || exit 0

# Only run if the file exists (skip deletes)
[[ -f "$FILE_PATH" ]] || exit 0

# Find repo root
REPO_ROOT=$(cd "$(dirname "$FILE_PATH")" && git rev-parse --show-toplevel 2>/dev/null) || exit 0

# Check if repo has RuboCop set up
HAS_RUBOCOP=false
[[ -f "$REPO_ROOT/.rubocop.yml" ]] && HAS_RUBOCOP=true
[[ "$HAS_RUBOCOP" == false ]] && [[ -f "$REPO_ROOT/Gemfile.lock" ]] && grep -q 'rubocop' "$REPO_ROOT/Gemfile.lock" && HAS_RUBOCOP=true
[[ "$HAS_RUBOCOP" == true ]] || exit 0

# Use bundler if Gemfile exists
if [[ -f "$REPO_ROOT/Gemfile" ]]; then
  cd "$REPO_ROOT" && bundle exec rubocop --autocorrect "$FILE_PATH" 2>&1
else
  rubocop --autocorrect "$FILE_PATH" 2>&1
fi
