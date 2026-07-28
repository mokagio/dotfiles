#!/usr/bin/env bash

set -euo pipefail

paths=()
for arg in "$@"; do
  for path in $arg; do
    paths+=("${path%/}")
  done
done

if [[ ${#paths[@]} -eq 0 ]]; then
  exit 0
fi

input=$(cat)

tool=$(jq -r '.tool_name // .toolName // .tool // .name // empty' <<<"$input" 2>/dev/null || true)
if [[ "$tool" == "Bash" || "$tool" == "bash" ]]; then
  haystack=$(jq -r '.tool_input.command // .arguments.command // .args.command // .command // empty' <<<"$input" 2>/dev/null || true)
else
  haystack=$(jq -c . <<<"$input" 2>/dev/null || printf '%s' "$input")
fi

escape_regex() {
  printf '%s' "$1" | sed -E 's#[][\\.*+?(){}|^$]#\\&#g'
}

patterns=()
tilde_home='~'
literal_home="\$HOME"
for path in "${paths[@]}"; do
  candidates=()
  case "$path" in
    /*)
      candidates+=("$path")
      ;;
    [~]/*)
      without_home="${path#~/}"
      candidates+=("$path" "$HOME/$without_home" "$literal_home/$without_home")
      ;;
    "\$HOME/"*)
      without_home="${path#\$HOME/}"
      candidates+=("$path" "$HOME/$without_home" "$tilde_home/$without_home")
      ;;
    *)
      candidates+=("$tilde_home/$path" "$HOME/$path" "$literal_home/$path")
      ;;
  esac

  for candidate in "${candidates[@]}"; do
    patterns+=("$(escape_regex "$candidate")")
  done
done

joined=$(IFS='|'; printf '%s' "${patterns[*]}")
boundary="(^|[^[:alnum:]_.-])($joined)(/|[^[:alnum:]_.-]|$)"

if grep -qE "$boundary" <<<"$haystack"; then
  printf '%s\n' "Blocked: access to configured secret paths is forbidden." >&2
  printf '%s\n' "If you need a specific value, ask the user to share it directly." >&2
  exit 2
fi
