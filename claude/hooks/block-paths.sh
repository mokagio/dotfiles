#!/usr/bin/env bash

# Generic Claude Code Read/Bash hook: block tool calls that would read the
# contents of files under any of the configured paths.
#
# Usage in settings.json:
#   {
#     "matcher": "Bash|Read",
#     "hooks": [{
#       "type": "command",
#       "command": "$HOME/.claude/hooks/block-paths.sh .a8c-secrets .gnupg",
#       "timeout": 5
#     }]
#   }
#
# Paths can be passed as separate args or as one space-separated string
# (`.a8c-secrets .gnupg` works either way). Each path is a literal segment
# (`.a8c-secrets`, `.gnupg`, `.ssh/id_rsa`, ...). Regex metacharacters are
# escaped and the match is anchored at `/`, whitespace, or end-of-string,
# so:
#   - `.a8c-secrets` matches `~/.a8c-secrets` and `~/.a8c-secrets/foo`
#   - `.a8c-secrets` does NOT match `~/.a8c-secrets-archive/foo`
#
# TODO: also support reading the path list from a file (one path per line,
# `#` comments and blank lines ignored), e.g.
#   $HOME/.claude/hooks/block-paths.sh --from-file ~/.config/claude/blocked-paths
# Useful for long lists or for sharing the list across machines without
# bloating the settings.json command string.
#
# Matching is applied to:
#   - Read tool: the `file_path` input directly.
#   - Bash tool: only when the segment appears inside a whitespace-
#     delimited token starting with /, ~, or $ — so `jq '... .a8c-secrets
#     ...' f.json` (segment inside a quoted search string, not a path)
#     does not match. Bash also requires the command to invoke a
#     content-reader (cat, head, jq, ...); filename-revealing commands
#     (ls, find, stat, file) are intentionally allowed.
#
# Known limitation: quoted paths like `cat '~/.ssh/id_rsa'` are not
# matched because the token starts with `'` instead of `~`.
#
# Exit code 2 blocks the tool call regardless of permission mode,
# including bypassPermissions ("YOLO") — settings.json deny rules don't
# survive that mode.

set -eu

# Collect paths from args; word-split each arg so a single
# space-separated string (`"a b c"`) is equivalent to multiple args.
paths=()
for arg in "$@"; do
  # Intentional unquoted expansion to split on whitespace.
  for p in $arg; do
    paths+=("$p")
  done
done

# No paths configured — let everything through.
[[ ${#paths[@]} -eq 0 ]] && exit 0

# Escape regex metacharacters in each path and join with | for ERE
# alternation, anchored at a path boundary.
patterns=()
for p in "${paths[@]}"; do
  escaped=$(printf '%s' "$p" | sed -E 's#[][\\.*+?(){}|^$]#\\&#g')
  patterns+=("$escaped")
done
joined=$(IFS='|'; echo "${patterns[*]}")
boundary="($joined)(/|[[:space:]]|\$)"

path_token_prefix='(^|[[:space:]])(/|~|\$)[^[:space:]]*'
reader_cmd_regex='(^|[[:space:]|;&(])(cat|bat|head|tail|less|more|view|nl|tac|column|grep|egrep|fgrep|rg|ag|ack|awk|sed|xxd|hexdump|od|strings|jq|yq)([[:space:]]|$)'

INPUT=$(cat)
TOOL=$(echo "$INPUT" | jq -r '.tool_name // empty')

case "$TOOL" in
  Read)
    FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
    if echo "$FILE_PATH" | grep -qE "$boundary"; then
      echo "Blocked: reads under a configured secret path are forbidden (would leak plaintext)." >&2
      echo "If you need a specific value, ask the user to share it directly." >&2
      exit 2
    fi
    ;;
  Bash)
    COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')
    if echo "$COMMAND" | grep -qE "${path_token_prefix}${boundary}" \
      && echo "$COMMAND" | grep -qE "$reader_cmd_regex"; then
      echo "Blocked: reading file contents under a configured secret path is forbidden." >&2
      echo "If you need a specific value, ask the user to share it directly." >&2
      exit 2
    fi
    ;;
esac
