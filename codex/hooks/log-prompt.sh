#!/usr/bin/env bash

set -euo pipefail

log_dir="${PROMPT_LOG_DIR:-$HOME/.me/prompts/log}"
mkdir -p "$log_dir"

input=$(cat)

prompt=$(jq -r '.prompt // .user_prompt // .userPrompt // .message // empty' <<<"$input" 2>/dev/null || true)
cwd=$(jq -r '.cwd // .workspace.current_dir // .workingDirectory // empty' <<<"$input" 2>/dev/null || true)

if [[ -z "$prompt" ]]; then
  exit 0
fi

today=$(date +"%Y-%m-%d")
timestamp=$(date +"%H:%M:%S")
log_file="$log_dir/$today.md"

if [[ ! -f "$log_file" ]]; then
  printf "# Prompt Log — %s\n\n" "$today" > "$log_file"
fi

cat >> "$log_file" << EOF
## $timestamp

> **cwd:** \`${cwd:-$(pwd)}\`

\`\`\`
$prompt
\`\`\`

EOF

exit 0
