#!/usr/bin/env bash

set -euo pipefail

# Stop hook: block when the final assistant message truncated a URL inside a
# markdown link — e.g. `[text](...)`, `[text](…)`, or an ellipsis anywhere in
# the link destination `[text](https://…)`. Forces a re-post with the full URL.
#
# Catch-and-correct, not prevention: the bad message is already on screen when
# this fires; blocking makes the model re-emit the link with its real
# destination in the same turn.

input="$(cat)"

# Avoid an infinite block loop: if we are already inside a stop-hook
# continuation, let this one through.
if [ "$(printf '%s' "$input" | jq -r '.stop_hook_active // false')" = "true" ]; then
  exit 0
fi

transcript="$(printf '%s' "$input" | jq -r '.transcript_path // empty')"
[ -z "$transcript" ] || [ ! -f "$transcript" ] && exit 0

# Concatenated text of the last assistant turn.
last_text="$(jq -rs '
  [ .[] | select(.type == "assistant") ] | last
  | (.message.content // [])
  | map(select(.type == "text") | .text)
  | join("\n")
' "$transcript" 2>/dev/null || true)"

[ -z "$last_text" ] && exit 0

# Strip fenced code blocks and inline code spans before matching. A link inside
# backticks renders as literal text, not a clickable link, so truncation there
# is harmless — and it lets a message discuss this very pattern without tripping
# the hook on itself.
scrubbed="$(printf '%s' "$last_text" \
  | awk 'BEGIN{f=0} /^[[:space:]]*```/{f=!f; next} !f' \
  | sed 's/`[^`]*`//g')"

# A markdown link destination containing "..." or "…".
if printf '%s' "$scrubbed" | grep -Eq '\]\([^)]*(\.\.\.|…)[^)]*\)'; then
  jq -n '{
    decision: "block",
    reason: "Your last message truncated a URL inside a markdown link (an \"...\"/\"…\" in the link destination). Re-post the link with its complete destination URL — never abbreviate URLs. If you do not have the full URL, print the link text without markdown link syntax instead of a placeholder."
  }'
  exit 0
fi

exit 0
