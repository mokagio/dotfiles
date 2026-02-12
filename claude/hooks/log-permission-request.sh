#!/usr/bin/env bash

set -eu

LOG_DIR="$HOME/.claude/logs"
LOG_FILE="$LOG_DIR/permission-requests.jsonl"
mkdir -p "$LOG_DIR"

INPUT=$(cat)

TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // "unknown"')
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // "unknown"')
CWD=$(echo "$INPUT" | jq -r '.cwd // "unknown"')

case "$TOOL_NAME" in
  Bash)
    DETAIL=$(echo "$INPUT" | jq -r '.tool_input.command // ""' | head -c 200)
    jq -n --arg ts "$TIMESTAMP" --arg sid "$SESSION_ID" --arg cwd "$CWD" \
           --arg tool "$TOOL_NAME" --arg detail "$DETAIL" \
      '{timestamp: $ts, session: $sid, cwd: $cwd, tool: $tool, detail: $detail}' \
      >> "$LOG_FILE"
    ;;
  *)
    DETAIL=$(echo "$INPUT" | jq -c '.tool_input // {}' | head -c 200)
    jq -n --arg ts "$TIMESTAMP" --arg sid "$SESSION_ID" --arg cwd "$CWD" \
           --arg tool "$TOOL_NAME" --arg detail "$DETAIL" \
      '{timestamp: $ts, session: $sid, cwd: $cwd, tool: $tool, detail: $detail}' \
      >> "$LOG_FILE"
    ;;
esac

# Don't interfere with the permission decision — just log
exit 0
