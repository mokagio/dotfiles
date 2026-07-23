#!/usr/bin/env bash

# Generic Claude Code Read/Bash hook: block tool calls that touch files under
# any of the configured paths.
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
# escaped. The segment must follow a `/` so it reads as a path component, and
# end at `/`, whitespace, a quote, a shell operator, or end-of-string:
#   - matches `~/.gnupg`, `"$HOME/.a8c-secrets/foo"`, `/Users/x/.a8c-secrets`
#   - does not match `~/.a8c-secrets-archive/foo`
#   - does not match `jq '.a8c-secrets' f.json`, where the segment is a search
#     string rather than a path
#
# Bash calls fail closed: a match blocks unless every verb is filename-only
# (SAFE_VERBS), nothing is redirected anywhere but /dev/null, and `find` is not
# carrying -exec/-delete. The inverse — allowlisting readers like cat and jq —
# leaves every unlisted verb open, which is how `cp`, `printf >`, and `rm`
# reached decrypted plaintext.
#
# This encodes intent; it is not a boundary. Text matching cannot see a path
# built by substitution (`cp "$(a8c-secrets which Secrets.swift)" /tmp`), nor a
# `cd` from an earlier call, since the working directory persists across Bash
# calls and leaves later commands with no literal path in them. For real
# enforcement, deny the subtree in a filesystem sandbox.
#
# Exit code 2 blocks the tool call regardless of permission mode, including
# bypassPermissions ("YOLO") — settings.json deny rules don't survive that mode.

set -eu

SAFE_VERBS='ls|find|stat|file|dirname|basename|readlink|realpath|mkdir|rmdir|cd|pwd|test|which|command|type'

# Collect paths from args; word-split each arg so a single
# space-separated string ("a b c") is equivalent to multiple args.
paths=()
for arg in "$@"; do
  # Intentional unquoted expansion to split on whitespace.
  for p in $arg; do
    paths+=("$p")
  done
done

# No paths configured — let everything through.
[[ ${#paths[@]} -eq 0 ]] && exit 0

patterns=()
for p in "${paths[@]}"; do
  escaped=$(printf '%s' "$p" | sed -E 's#[][\\.*+?(){}|^$]#\\&#g')
  patterns+=("$escaped")
done
joined=$(IFS='|'; echo "${patterns[*]}")

sq=$(printf '\047')
path_regex="/($joined)(/|[[:space:]]|[\"${sq}\`;&|)]|\$)"

deny() {
  echo "Blocked: $1 under a configured secret path." >&2
  echo "Use the tool that owns these files; raw file access is refused." >&2
  echo "If you need a specific value, ask the user to share it directly." >&2
  exit 2
}

INPUT=$(cat)
TOOL=$(echo "$INPUT" | jq -r '.tool_name // empty')

case "$TOOL" in
  Read)
    FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
    if echo "$FILE_PATH" | grep -qE "$path_regex"; then
      deny "reading a file"
    fi
    ;;
  Bash)
    COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')
    if ! echo "$COMMAND" | grep -qE "$path_regex"; then
      exit 0
    fi

    # Only a redirect aimed at the path is a write. Matching any `>` snags
    # ordinary text that happens to mention the path — a heredoc commit message
    # carrying a `Co-Authored-By: name <email>` trailer, for instance.
    if echo "$COMMAND" | grep -qE ">>?[[:space:]]*[^[:space:]]*$path_regex"; then
      deny "redirecting output into a file"
    fi

    if echo "$COMMAND" | grep -qE '(^|[[:space:]])-(exec|execdir|ok|delete)([[:space:]]|$)'; then
      deny "running find -exec/-delete"
    fi

    # Verbs are the tokens opening the command or following a shell separator.
    # An env-var prefix (FOO=bar cmd) is captured as FOO and so fails closed.
    verbs=$(printf '%s' "$COMMAND" \
      | grep -oE '(^|[;&|(]|&&|\|\|)[[:space:]]*[A-Za-z_][A-Za-z0-9_./-]*' \
      | sed -E 's/^[^A-Za-z_]*//')

    if [[ -z "$verbs" ]]; then
      deny "running an unrecognised command"
    fi

    while IFS= read -r verb; do
      [[ -z "$verb" ]] && continue
      if ! echo "${verb##*/}" | grep -qE "^($SAFE_VERBS)$"; then
        deny "running '${verb##*/}'"
      fi
    done <<< "$verbs"
    ;;
esac

exit 0
