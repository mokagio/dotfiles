# Tab completion for `git worktree-delete <name>`.
#
# git's zsh completion wrapper (_git) dispatches `git <cmd>` to a function
# named `_git_<cmd_with_hyphens_to_underscores>`. For `git worktree-delete`
# it looks up `_git_worktree_delete`. The function runs under ksh emulation,
# so avoid zsh-specific syntax and use __gitcomp to feed candidates.

_git_worktree_delete() {
  local repo repo_name wt_root legacy_root names
  repo=$(git rev-parse --show-toplevel 2>/dev/null) || return
  repo_name=$(basename "$repo")
  wt_root="$HOME/Developer/git-worktrees/$repo_name"
  legacy_root="$repo/.git-worktrees"
  if [ -d "$wt_root" ]; then
    names=$(cd "$wt_root" && find . -mindepth 1 -maxdepth 1 -type d 2>/dev/null \
      | sed 's|^\./||' | tr '\n' ' ')
  elif [ -d "$legacy_root" ]; then
    names=$(cd "$legacy_root" && find . -mindepth 1 -maxdepth 1 -type d 2>/dev/null \
      | sed 's|^\./||' | tr '\n' ' ')
  else
    return
  fi
  __gitcomp "$names"
}
