#!/usr/bin/env bash

set -eu

INPUT=$(cat)

COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# Block destructive patterns
if echo "$COMMAND" | grep -qE '(rm\s+-rf|git\s+reset\s+--hard|git\s+push\s+--force|git\s+push\s+-f|git\s+clean\s+-f|git\s+checkout\s+\.)'; then
  echo "Blocked destructive command: $COMMAND"
  echo "Ask the user for confirmation before running this."
  exit 2
fi
