#!/usr/bin/env bash
set -euo pipefail

REAL_PATH="$(readlink -f "$0" 2>/dev/null || realpath "$0")"
SCRIPT_DIR="$(dirname "$REAL_PATH")"
DOTFILES="$(cd "$SCRIPT_DIR/../.." && pwd)"
ALLOWLIST="${SCRIPT_DIR}/brief-allowlist.txt"
BRIEF="${DOTFILES}/scripts/brief"

payload="$(cat)"

tool_name="$(printf '%s' "$payload" | jq -r '.tool_name // .toolName // empty' 2>/dev/null)" || exit 0
if [[ "$tool_name" != "Bash" ]]; then
  exit 0
fi

command="$(printf '%s' "$payload" | jq -r '.tool_input.command // .toolInput.command // empty' 2>/dev/null)" || exit 0
if [[ -z "$command" ]]; then
  exit 0
fi

if [[ ! -f "$ALLOWLIST" ]]; then
  exit 0
fi

stripped="${command#"${command%%[![:space:]]*}"}"

matched=""
while IFS= read -r line; do
  line="${line#"${line%%[![:space:]]*}"}"
  line="${line%"${line##*[![:space:]]}"}"
  [[ -z "$line" || "$line" == \#* ]] && continue
  if [[ "$stripped" == "$line" || "$stripped" == "$line "* ]]; then
    matched="$line"
    break
  fi
done < "$ALLOWLIST"

if [[ -z "$matched" ]]; then
  exit 0
fi

label="${matched// /-}"

printf '%s\n' "$command" "$label" | jq -Rn --arg brief "$BRIEF" '
  (input) as $command |
  (input) as $label |
  {
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "allow",
      permissionDecisionReason: "Wrap noisy command with brief",
      updatedInput: {
        command: ("BRIEF_AGENT=claude BRIEF_COLOR=1 " + ($brief | @sh) + " " + ($label | @sh) + " -- /bin/zsh -lc " + ($command | @sh))
      }
    }
  }
'
