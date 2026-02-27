#!/usr/bin/env bash

set -eu

LOG_DIR="$HOME/.claude/logs"
LOG_FILE="$LOG_DIR/permission-requests.jsonl"
mkdir -p "$LOG_DIR"

INPUT=$(cat)

echo "$INPUT" | jq -c '{
  timestamp: (now | strftime("%Y-%m-%dT%H:%M:%SZ")),
  session: (.session_id // "unknown"),
  cwd: (.cwd // "unknown"),
  tool: (.tool_name // "unknown"),
  detail: ((.tool_input.command // (.tool_input | tostring)) | .[:200])
}' >> "$LOG_FILE"
