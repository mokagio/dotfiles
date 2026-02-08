#!/bin/bash
input=$(cat)

model=$(echo "$input" | jq -r '.model.display_name // "?"')
pct=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
dir=$(echo "$input" | jq -r '.workspace.current_dir // ""')

# Git branch + worktree indicator
if [ -n "$dir" ] && [ -d "$dir" ]; then
  branch=$(git -C "$dir" branch --show-current 2>/dev/null)
  if [ -n "$branch" ]; then
    git_common=$(git -C "$dir" rev-parse --git-common-dir 2>/dev/null)
    git_dir=$(git -C "$dir" rev-parse --git-dir 2>/dev/null)
    if [ "$git_common" != "$git_dir" ]; then
      git_info="$branch (worktree)"
    else
      git_info="$branch"
    fi
  fi
fi

# For other symbols, see
# https://www.alt-codes.net/bullet_alt_codes.php
#
# Unicode &#8226;
separator='•'

echo "$model $separator ${pct}% context $separator ${git_info:-}"
