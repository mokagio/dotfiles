#!/usr/bin/env bash

# Second line of defence against destructive commands.
# settings.json deny rules are the primary guard; this hook adds a
# runtime regex check (~20ms overhead per Bash call) in case a
# destructive pattern slips through the glob matching.

set -eu

INPUT=$(cat)

COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')
if echo "$COMMAND" | grep -qE '(rm\s+-rf|git\s+reset\s+--hard|git\s+push\s+--force|git\s+push\s+-f|git\s+clean\s+-f|git\s+checkout\s+\.)'; then
  echo "Blocked destructive command: $COMMAND"
  echo "Ask the user for confirmation before running this."
  exit 2
fi
