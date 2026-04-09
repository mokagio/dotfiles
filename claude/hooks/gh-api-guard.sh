#!/usr/bin/env bash

set -eu

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# Only inspect gh api calls (bare gh or full path)
if ! echo "$COMMAND" | grep -qE '(^|\s|/)gh\s+api\b'; then
  exit 0
fi

ask() {
  jq -n --arg reason "$1" '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "ask",
      reason: $reason
    }
  }'
  exit 0
}

# Safe PR metadata endpoints (labels, milestones, PR body/title) — let through without prompting
if echo "$COMMAND" | grep -qE 'repos/[^/]+/[^/]+/issues/[0-9]+/labels\b'; then
  exit 0
fi
if echo "$COMMAND" | grep -qE 'repos/[^/]+/[^/]+/issues/[0-9]+\b.*-f\s+milestone='; then
  exit 0
fi
if echo "$COMMAND" | grep -qE 'repos/[^/]+/[^/]+/pulls/[0-9]+\b.*-f\s+body='; then
  exit 0
fi
if echo "$COMMAND" | grep -qE 'repos/[^/]+/[^/]+/pulls/[0-9]+\b.*-f\s+title='; then
  exit 0
fi

# GraphQL: mutations are writes, queries are reads
if echo "$COMMAND" | grep -qE '\bgraphql\b'; then
  if echo "$COMMAND" | grep -qiE '\bmutation\b'; then
    ask "gh api: GraphQL mutation detected"
  fi
  exit 0
fi

# Detect explicit GET — field flags and --input are safe with GET
EXPLICIT_GET=false
if echo "$COMMAND" | grep -qE -- '\s(-X|--method)\s+GET\b'; then
  EXPLICIT_GET=true
fi

# Explicit write method (-X / --method)
if echo "$COMMAND" | grep -qE -- '\s(-X|--method)\s+(POST|PUT|PATCH|DELETE)\b'; then
  ask "gh api: explicit write method"
fi

if [ "$EXPLICIT_GET" = false ]; then
  # Field flags imply POST (-f / -F / --field / --raw-field)
  if echo "$COMMAND" | grep -qE -- '\s(-f|-F|--field|--raw-field)[ =]'; then
    ask "gh api: field flags imply POST"
  fi

  # Body from file implies POST
  if echo "$COMMAND" | grep -qE -- '\s--input[ =]'; then
    ask "gh api: --input implies POST"
  fi
fi

# No write signals — pass through to normal permission rules
exit 0
