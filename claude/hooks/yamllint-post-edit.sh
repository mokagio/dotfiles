#!/usr/bin/env bash

set -eu

INPUT=$(cat)

FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# Only run on YAML files
[[ "$FILE_PATH" == *.yaml || "$FILE_PATH" == *.yml ]] || exit 0

# Only run if the file exists (skip deletes)
[[ -f "$FILE_PATH" ]] || exit 0

# Fail if yamllint is not installed
if ! command -v yamllint &>/dev/null; then
  echo "yamllint is not installed" >&2
  exit 1
fi

yamllint "$FILE_PATH" 2>&1
