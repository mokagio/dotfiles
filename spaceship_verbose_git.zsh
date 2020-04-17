#
# See
# https://github.com/denysdovhan/spaceship-prompt/blob/6319158f19a7bb83a8131da7268213cb636f9653/docs/API.md#api
# for more insight on how to build new sections
#
# See
# https://wiki.archlinux.org/index.php/zsh#Colors and
# https://upload.wikimedia.org/wikipedia/commons/1/15/Xterm_256color_chart.svg
# for more colors
#
SPACESHIP_VERBOSE_GIT_SHOW="${SPACESHIP_VERBOSE_GIT=true}"

# PS: to use color codes, use "#ff00ff"
SPACESHIP_VERBOSE_GIT_BRANCH_COLOR="${SPACESHIP_VERBOSE_GIT_BRANCH_COLOR="magenta"}"
SPACESHIP_VERBOSE_GIT_STATUS_PREFIX="${SPACESHIP_VERBOSE_GIT_STATUS_PREFIX=""}"
SPACESHIP_VERBOSE_GIT_STATUS_SUFFIX="${SPACESHIP_VERBOSE_GIT_STATUS_SUFFIX=" "}"
SPACESHIP_VERBOSE_GIT_COLOR="${SPACESHIP_VERBOSE_GIT_COLOR="red"}"

SPACESHIP_VERBOSE_GIT_STATUS_UNTRACKED="${SPACESHIP_VERBOSE_GIT_STATUS_UNTRACKED="?"}"
SPACESHIP_VERBOSE_GIT_STATUS_ADDED="${SPACESHIP_VERBOSE_GIT_STATUS_ADDED="+"}"
SPACESHIP_VERBOSE_GIT_STATUS_ADDED_COLOR="${SPACESHIP_VERBOSE_GIT_STATUS_ADDED_COLOR="red"}"
SPACESHIP_VERBOSE_GIT_STATUS_MODIFIED="${SPACESHIP_VERBOSE_GIT_STATUS_MODIFIED="!"}"
SPACESHIP_VERBOSE_GIT_STATUS_RENAMED="${SPACESHIP_VERBOSE_GIT_STATUS_RENAMED="»"}"
SPACESHIP_VERBOSE_GIT_STATUS_DELETED="${SPACESHIP_VERBOSE_GIT_STATUS_DELETED="✘"}"
SPACESHIP_VERBOSE_GIT_STATUS_STASHED="${SPACESHIP_VERBOSE_GIT_STATUS_STASHED="$"}"
SPACESHIP_VERBOSE_GIT_STATUS_STASHED_COLOR="${SPACESHIP_VERBOSE_GIT_STATUS_STASHED_COLOR="red"}"
SPACESHIP_VERBOSE_GIT_STATUS_UNMERGED="${SPACESHIP_VERBOSE_GIT_STATUS_UNMERGED="="}"
SPACESHIP_VERBOSE_GIT_STATUS_AHEAD="${SPACESHIP_VERBOSE_GIT_STATUS_AHEAD="⬆"}"
SPACESHIP_VERBOSE_GIT_STATUS_AHEAD_COLOR="${SPACESHIP_VERBOSE_GIT_STATUS_AHEAD_COLOR="red"}"
SPACESHIP_VERBOSE_GIT_STATUS_BEHIND="${SPACESHIP_VERBOSE_GIT_STATUS_BEHIND="⬇"}"
SPACESHIP_VERBOSE_GIT_STATUS_BEHIND_COLOR="${SPACESHIP_VERBOSE_GIT_STATUS_BEHIND_COLOR="red"}"
SPACESHIP_VERBOSE_GIT_STATUS_DIVERGED="${SPACESHIP_VERBOSE_GIT_STATUS_DIVERGED="⇕"}"

parse_git_branch() {
  (git symbolic-ref -q HEAD || git name-rev --name-only --no-undefined --always HEAD) 2> /dev/null
}

spaceship_verbose_git() {
  [[ $SPACESHIP_VERBOSE_GIT_SHOW == false ]] && return

  spaceship::exists git || return
  spaceship::is_git || return

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
    git_status=$(spaceship::section \
      $SPACESHIP_VERBOSE_GIT_STATUS_ADDED_COLOR \
      "" \
      "$staged_count$SPACESHIP_VERBOSE_GIT_STATUS_ADDED$separator$git_status" \
      "")
    separator=$separator_value
  fi

  # Check for modified files
  local modified_count=$(git diff --name-only 2> /dev/null | wc -l | tr -d ' ')
  if [[ $modified_count -gt 0  ]]; then
    git_status="$modified_count$SPACESHIP_VERBOSE_GIT_STATUS_MODIFIED$separator$git_status"
    separator=$separator_value
  fi

  # Check for renamed files
  local renamed_count=$(echo "$INDEX" | command grep '^R[ MD] ' &> /dev/null | wc -l | tr -d ' ')
  if [[ $renamed_count -gt 0 ]]; then
    git_status="$renamed_count$SPACESHIP_VERBOSE_GIT_STATUS_RENAMED$separator$git_status"
    separator=$separator_value
  fi

  # Check for deleted files
  # I'm not sure if I got the Regex to meaning correct...
  local deleted_count_staged=$(echo "$INDEX" | command grep '^[MARCDU ]D ' &> /dev/null | wc -l | tr -d ' ')
  local deleted_count_not_staged=$(echo "$INDEX" | command grep '^D[ UM] ' &> /dev/null | wc -l | tr -d ' ')
  local deleted_count=$(expr $deleted_count_staged + $deleted_count_not_staged)
  if [[ $deleted_count -gt 0 ]]; then
    git_status="$deleted_count$SPACESHIP_VERBOSE_GIT_STATUS_DELETED$separator$git_status"
    separator=$separator_value
  fi

  # TODO! Switch back to using the same commands as the prompt code. Otherwise,
  # it might happen that a deleted file also counts in the staged ones... I
  # wonder if that's actually due to how deleted are counted... 🤔

  # Check for stashes
  local stash_count=$(command git rev-parse --verify refs/stash >/dev/null 2>&1 | wc -l | tr -d ' ')
  if [[ $stash_count -gt 0 ]]; then
    git_status=$(spaceship::section \
      $SPACESHIP_VERBOSE_GIT_STATUS_STASHED_COLOR \
      "" \
      "$stash_count$SPACESHIP_VERBOSE_GIT_STATUS_STASHED$separator$git_status" \
      "")
    separator=$separator_value
  fi

  # Check for unmerged files
  #
  # Not sure what to do here... It might be too much to show the count for each, right?
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

  # Gonna check ahead/behind now
  local currentbranch=$(expr $(git symbolic-ref -q HEAD) : 'refs/heads/\(.*\)')

  # look up this branch in the configuration
  local remote=$(git config branch.$currentbranch.remote)
  local remote_ref=$(git config branch.$currentbranch.merge)

  if [[ -n $remote ]]; then
    # convert the remote ref into the tracking ref... this is a hack
    local remote_branch=$(expr $remote_ref : 'refs/heads/\(.*\)')
    local tracking_branch=refs/remotes/$remote/$remote_branch

    # now $tracking_branch should be the local ref tracking HEAD
    local ahead_count=$(git rev-list $tracking_branch..HEAD | wc -l | tr -d ' ')
    local behind_count=$(git rev-list HEAD..$tracking_branch | wc -l | tr -d ' ')

    if [[ $ahead_count -gt 0 ]]; then
      git_status=$(spaceship::section \
        $SPACESHIP_VERBOSE_GIT_STATUS_AHEAD_COLOR \
        "" \
        "$ahead_count$SPACESHIP_VERBOSE_GIT_STATUS_AHEAD$separator$git_status" \
        "")
      separator=$separator_value
    fi
    if [[ $behind_count -gt 0 ]]; then
      git_status=$(spaceship::section \
        $SPACESHIP_VERBOSE_GIT_STATUS_BEHIND_COLOR \
        "" \
        "$ahead_count$SPACESHIP_VERBOSE_GIT_STATUS_BEHIND$separator$git_status" \
        "")
      separator=$separator_value
    fi
  fi
  # Notice that unlike the other prompt, we don't have a dedicated symbol for
  # when we're diverging from the remote. Seeing both ahead and behind symbols
  # is enough for me

  # TODO: move all the strings to configs
  local branch=$(spaceship::section \
    "$SPACESHIP_VERBOSE_GIT_BRANCH_COLOR" \
    " ${git_branch#(refs/heads/|tags/)}")

  local status_begin=$(spaceship::section \
    "$SPACESHIP_VERBOSE_GIT_COLOR" \
    "[")
  local status_end=$(spaceship::section \
    "$SPACESHIP_VERBOSE_GIT_COLOR" \
    "]")

  local section="$SPACESHIP_VERBOSE_GIT_STATUS_PREFIX"
  section+=$branch
  section+=" "
  section+=$status_begin
  section+=$git_status
  section+=$status_end
  section+=$SPACESHIP_VERBOSE_GIT_STATUS_SUFFIX

  echo -n "$section"
}
