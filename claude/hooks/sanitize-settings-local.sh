#!/usr/bin/env bash

set -eu

# Cleans up .claude/settings.local.json by removing:
# 1. Entries shadowed by global ~/.claude/settings.json allow rules
# 2. Ad hoc colon-format Bash entries (auto-generated session approvals)
#
# Runs on UserPromptSubmit — fast and idempotent.

command -v jq >/dev/null 2>&1 || exit 0

GLOBAL_SETTINGS="$HOME/.claude/settings.json"

# Read CWD from hook input or fall back to $PWD.
CWD="$PWD"
if ! [ -t 0 ]; then
  INPUT=$(cat)
  HOOK_CWD=$(echo "$INPUT" | jq -r '.cwd // empty' 2>/dev/null || true)
  if [[ -n "$HOOK_CWD" ]]; then
    CWD="$HOOK_CWD"
  fi
fi

# Find project root.
PROJECT_ROOT=$(git -C "$CWD" rev-parse --show-toplevel 2>/dev/null) || exit 0
LOCAL_SETTINGS="$PROJECT_ROOT/.claude/settings.local.json"

[[ -f "$GLOBAL_SETTINGS" ]] || exit 0
[[ -f "$LOCAL_SETTINGS" ]] || exit 0

# Load global allow rules.
global_allows=()
while IFS= read -r rule; do
  [[ -n "$rule" ]] && global_allows+=("$rule")
done < <(jq -r '.permissions.allow // [] | .[]' "$GLOBAL_SETTINGS")

# Load local allow rules.
local_allows=()
while IFS= read -r rule; do
  [[ -n "$rule" ]] && local_allows+=("$rule")
done < <(jq -r '.permissions.allow // [] | .[]' "$LOCAL_SETTINGS")

[[ ${#local_allows[@]} -eq 0 ]] && exit 0

# Normalize colon-format to space-format for comparison.
# Bash(git log:*) → Bash(git log *)
normalize() {
  printf '%s' "$1" | sed 's/:\([^)]*\))$/ \1)/'
}

# Check if a rule is covered by any global allow pattern.
is_covered_by_global() {
  local normalized
  normalized=$(normalize "$1")

  for global in "${global_allows[@]}"; do
    # shellcheck disable=SC2053
    if [[ "$normalized" == $global ]]; then
      return 0
    fi
  done
  return 1
}

# Check if a rule is an auto-generated colon-format Bash entry
# for a simple command (no env vars, no absolute paths).
is_adhoc_bash() {
  local rule="$1"
  # Must be colon-format: Bash(something:*)
  [[ "$rule" =~ ^Bash\(.*:\*\)$ ]] || return 1
  # Extract the command portion before :*)
  local inner="${rule#Bash(}"
  inner="${inner%:\*)}"
  # Keep complex/project-specific entries:
  # - env var assignments (contains =)
  # - absolute paths (starts with /)
  [[ "$inner" =~ = ]] && return 1
  [[ "$inner" =~ ^/ ]] && return 1
  return 0
}

# Collect rules to remove.
to_remove=()
for rule in "${local_allows[@]}"; do
  if is_covered_by_global "$rule"; then
    to_remove+=("$rule")
  elif is_adhoc_bash "$rule"; then
    to_remove+=("$rule")
  fi
done

[[ ${#to_remove[@]} -eq 0 ]] && exit 0

# Build JSON array of rules to remove.
remove_json=$(printf '%s\n' "${to_remove[@]}" | jq -R . | jq -s .)

# Remove identified rules and clean up empty structures.
tmp="${LOCAL_SETTINGS}.tmp"
jq --argjson remove "$remove_json" '
  .permissions.allow |= [.[] | select(. as $r | ($remove | index($r)) == null)]
  | if .permissions.allow == [] then del(.permissions.allow) else . end
  | if .permissions == {} then del(.permissions) else . end
' "$LOCAL_SETTINGS" > "$tmp"
mv "$tmp" "$LOCAL_SETTINGS"

# If the file is now an empty object, remove it entirely.
if jq -e '. == {}' "$LOCAL_SETTINGS" >/dev/null 2>&1; then
  rm -f "$LOCAL_SETTINGS"
fi

exit 0
