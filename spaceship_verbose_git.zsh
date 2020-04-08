#
# See
# https://github.com/denysdovhan/spaceship-prompt/blob/6319158f19a7bb83a8131da7268213cb636f9653/docs/API.md#api
# for more insight on how to build new sections
#
SPACESHIP_VERBOSE_GIT_SHOW="${SPACESHIP_VERBOSE_GIT=true}"
SPACESHIP_VERBOSE_GIT_PREFIX="${SPACESHIP_VERBOSE_GIT_PREFIX="_"}"
SPACESHIP_VERBOSE_GIT_SUFFIX="${SPACESHIP_VERBOSE_GIT_SUFFIX="_"}"
SPACESHIP_VERBOSE_GIT_COLOR="${SPACESHIP_VERBOSE_GIT_COLOR="orange"}"

SPACESHIP_VERBOSE_GIT_STATUS_UNTRACKED="${SPACESHIP_VERBOSE_GIT_STATUS_UNTRACKED="?"}"
SPACESHIP_VERBOSE_GIT_STATUS_ADDED="${SPACESHIP_VERBOSE_GIT_STATUS_ADDED="+"}"
SPACESHIP_VERBOSE_GIT_STATUS_MODIFIED="${SPACESHIP_VERBOSE_GIT_STATUS_MODIFIED="!"}"
SPACESHIP_VERBOSE_GIT_STATUS_RENAMED="${SPACESHIP_VERBOSE_GIT_STATUS_RENAMED="»"}"
SPACESHIP_VERBOSE_GIT_STATUS_DELETED="${SPACESHIP_VERBOSE_GIT_STATUS_DELETED="✘"}"
SPACESHIP_VERBOSE_GIT_STATUS_STASHED="${SPACESHIP_VERBOSE_GIT_STATUS_STASHED="$"}"
SPACESHIP_VERBOSE_GIT_STATUS_UNMERGED="${SPACESHIP_VERBOSE_GIT_STATUS_UNMERGED="="}"
SPACESHIP_VERBOSE_GIT_STATUS_AHEAD="${SPACESHIP_VERBOSE_GIT_STATUS_AHEAD="⇡"}"
SPACESHIP_VERBOSE_GIT_STATUS_BEHIND="${SPACESHIP_VERBOSE_GIT_STATUS_BEHIND="⇣"}"
SPACESHIP_VERBOSE_GIT_STATUS_DIVERGED="${SPACESHIP_VERBOSE_GIT_STATUS_DIVERGED="⇕"}"

parse_git_branch() {
  (git symbolic-ref -q HEAD || git name-rev --name-only --no-undefined --always HEAD) 2> /dev/null
}

spaceship_verbose_git() {
  [[ $SPACESHIP_VERBOSE_GIT_SHOW == false ]] && return

  spaceship::exists git || return

  local git_branch="$(parse_git_branch)"
  local git_folder="$(git rev-parse --git-dir 2> /dev/null)"

  # See
  # https://github.com/denysdovhan/spaceship-prompt/blob/6319158f19a7bb83a8131da7268213cb636f9653/sections/git_status.zsh
  local INDEX git_status=""

  INDEX=$(command git status --porcelain -b 2> /dev/null)

  # This is a bit dumb, but rather than having a flag for whether to add a
  # space, or compute it every time, we can just set the separator to something
  # once it's needed, and add it everywhere.
  local separator_value=' '
  local separator=''

  # Check for untracked files
  local untracked_count=$(git ls-files --other --exclude-standard 2> /dev/null | wc -l | tr -d ' ')
  if [[ $untracked_count -gt 0 ]]; then
    git_status="$untracked_count$SPACESHIP_VERBOSE_GIT_STATUS_UNTRACKED$git_status"
    separator=$separator_value
  fi

  # Check for staged files
  local staged_count=$(git diff --cached --name-only 2> /dev/null | wc -l | tr -d ' ')
  if [[ $staged_count -gt 0 ]]; then
    # This is what I've been doing so far
    #git_status="$staged_count$SPACESHIP_VERBOSE_GIT_STATUS_ADDED$separator$git_status"
    #separator=$separator_value

    # This is what I could be doing, to have all sorts of colors for the
    # different Git info
    local t=$(spaceship::section \
      "blue" \
      "_" \
      "$staged_count$SPACESHIP_VERBOSE_GIT_STATUS_ADDED" \
      "_")
    git_status=$t$git_status
  fi

  # Check for modified files
  local modified_count=$(git diff --name-only 2> /dev/null | wc -l | tr -d ' ')
  if [[ $modified_count -gt 0  ]]; then
    git_status="$modified_count$SPACESHIP_VERBOSE_GIT_STATUS_MODIFIED$separator$git_status"
    separator=$separator_value
  fi

  # Check for renamed files
  if $(echo "$INDEX" | command grep '^R[ MD] ' &> /dev/null); then
    git_status="$SPACESHIP_VERBOSE_GIT_STATUS_RENAMED$git_status"
    separator=$separator_value
  fi

  # Check for deleted files
  if $(echo "$INDEX" | command grep '^[MARCDU ]D ' &> /dev/null); then
    git_status="$SPACESHIP_VERBOSE_GIT_STATUS_DELETED$separator$git_status"
    separator=$separator_value
  elif $(echo "$INDEX" | command grep '^D[ UM] ' &> /dev/null); then
    git_status="$SPACESHIP_VERBOSE_GIT_STATUS_DELETED$separator$git_status"
    separator=$separator_value
  fi

  # Check for stashes
  if $(command git rev-parse --verify refs/stash >/dev/null 2>&1); then
    git_status="$SPACESHIP_VERBOSE_GIT_STATUS_STASHED$separator$git_status"
    separator=$separator_value
  fi

  # Check for unmerged files
  if $(echo "$INDEX" | command grep '^U[UDA] ' &> /dev/null); then
    git_status="$SPACESHIP_VERBOSE_GIT_STATUS_UNMERGED$separator$git_status"
    separator=$separator_value
  elif $(echo "$INDEX" | command grep '^AA ' &> /dev/null); then
    git_status="$SPACESHIP_VERBOSE_GIT_STATUS_UNMERGED$separator$git_status"
    separator=$separator_value
  elif $(echo "$INDEX" | command grep '^DD ' &> /dev/null); then
    git_status="$SPACESHIP_VERBOSE_GIT_STATUS_UNMERGED$separator$git_status"
    separator=$separator_value
  elif $(echo "$INDEX" | command grep '^[DA]U ' &> /dev/null); then
    git_status="$SPACESHIP_VERBOSE_GIT_STATUS_UNMERGED$separator$git_status"
    separator=$separator_value
  fi

  # Check whether branch is ahead
  local is_ahead=false
  if $(echo "$INDEX" | command grep '^## [^ ]\+ .*ahead' &> /dev/null); then
    is_ahead=true
  fi

  # Check whether branch is behind
  local is_behind=false
  if $(echo "$INDEX" | command grep '^## [^ ]\+ .*behind' &> /dev/null); then
    is_behind=true
  fi

  # Check wheather branch has diverged
  if [[ "$is_ahead" == true && "$is_behind" == true ]]; then
    git_status="$SPACESHIP_VERBOSE_GIT_STATUS_DIVERGED$git_status"
  else
    [[ "$is_ahead" == true ]] && git_status="$SPACESHIP_VERBOSE_GIT_STATUS_AHEAD$git_status"
    [[ "$is_behind" == true ]] && git_status="$SPACESHIP_VERBOSE_GIT_STATUS_BEHIND$git_status"
  fi

  local _git_status=""
  if [[ -n $git_status ]]; then
    _git_status="($git_status)"
  fi

  # TODO: move all the strings to configs
  spaceship::section \
    "$SPACESHIP_VERBOSE_GIT_COLOR" \
    "$SPACESHIP_VERBOSE_GIT_PREFIX" \
    "${git_branch#(refs/heads/|tags/)} $_git_status" \
    "$SPACESHIP_VERBOSE_GIT_SUFFIX"
} # why isn't this aligned properly if I ask Vim to align it?
