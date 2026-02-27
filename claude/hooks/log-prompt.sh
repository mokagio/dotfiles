#!/usr/bin/env bash

set -eu

# Logs every user prompt to a daily file for later review.
#
# Designed to run as a UserPromptSubmit hook.
# Receives hook JSON on stdin, extracts .prompt, appends to daily log.
# Always exits 0 — never blocks the user.

LOG_DIR="$HOME/.me/prompts/log"
mkdir -p "$LOG_DIR"

# Read hook input from stdin.
INPUT=$(cat)

PROMPT=$(echo "$INPUT" | jq -r '.prompt // empty' 2>/dev/null || true)
CWD=$(echo "$INPUT" | jq -r '.cwd // empty' 2>/dev/null || true)

# Nothing to log.
if [[ -z "$PROMPT" ]]; then
  exit 0
fi

TODAY=$(date +"%Y-%m-%d")
TIMESTAMP=$(date +"%H:%M:%S")
LOG_FILE="$LOG_DIR/$TODAY.md"

# Create file with header on first entry of the day.
if [[ ! -f "$LOG_FILE" ]]; then
  printf "# Prompt Log — %s\n\n" "$TODAY" > "$LOG_FILE"
fi

# Append the prompt entry.
# Use a heredoc to preserve multi-line prompts.
cat >> "$LOG_FILE" << EOF
## $TIMESTAMP

> **cwd:** \`$CWD\`

\`\`\`
$PROMPT
\`\`\`

EOF

exit 0
