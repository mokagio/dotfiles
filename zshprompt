# Originally inspired by https://gist.github.com/1712320

setopt prompt_subst
autoload -U colors && colors # Enable colors in prompt

# Modify the colors and symbols in these variables as desired.
GIT_PROMPT_PREFIX="%{$fg[green]%}(%{$reset_color%}"
GIT_PROMPT_SUFFIX="%{$fg[green]%})%{$reset_color%}"
GIT_PROMPT_AHEAD="%{$fg[red]%}ANUM%{$reset_color%}"
GIT_PROMPT_BEHIND="%{$fg[cyan]%}BNUM%{$reset_color%}"
GIT_PROMPT_MERGING="%{$fg_bold[magenta]%}⚡︎%{$reset_color%}"
GIT_PROMPT_UNTRACKED="%{$fg_bold[red]%}●%{$reset_color%}"
GIT_PROMPT_MODIFIED="%{$fg_bold[yellow]%}●%{$reset_color%}"
GIT_PROMPT_STAGED="%{$fg_bold[green]%}●%{$reset_color%}"

# Show Git branch/tag, or name-rev if on detached head
parse_git_branch() {
  (git symbolic-ref -q HEAD || git name-rev --name-only --no-undefined --always HEAD) 2> /dev/null
}

# Show different symbols as appropriate for various Git repository states
parse_git_state() {

  # Compose this value via multiple conditional appends.
  local GIT_STATE=""
  local SHOULD_INSERT_SPACE=0

  # local NUM_AHEAD="$(git log --oneline @{u}.. 2> /dev/null | wc -l | tr -d ' ')"
  # if [ "$NUM_AHEAD" -gt 0 ]; then
  #   GIT_STATE=$GIT_STATE${GIT_PROMPT_AHEAD//NUM/$NUM_AHEAD}
  # fi

  # local NUM_BEHIND="$(git log --oneline ..@{u} 2> /dev/null | wc -l | tr -d ' ')"
  # if [ "$NUM_BEHIND" -gt 0 ]; then
  #   GIT_STATE=$GIT_STATE${GIT_PROMPT_BEHIND//NUM/$NUM_BEHIND}
  # fi

  local GIT_DIR="$(git rev-parse --git-dir 2> /dev/null)"

  # Check that everything's fine in the git dir
  # http://stackoverflow.com/questions/12267912/git-fatal-ambiguous-argument-head-unknown-revision-or-path-not-in-the-workin
  if [ $? -ne 0 ] || [ -z "$GIT_DIR" ]; then
      return
  fi

  if [ -n $GIT_DIR ] && test -r $GIT_DIR/MERGE_HEAD; then
    GIT_STATE=$GIT_STATE$GIT_PROMPT_MERGING

    # http://stackoverflow.com/questions/3065650/whats-the-simplest-way-to-git-a-list-of-conflicted-files
    local CONFLICT_COUNT="$(git diff --name-only --diff-filter=U | wc -l | tr -d ' ')"
    if [[ CONFLICT_COUNT -gt 0 ]]; then
      GIT_STATE=$GIT_STATE$CONFLICT_COUNT
    fi

    SHOULD_INSERT_SPACE=1
  fi

  local UNTRACKED_COUNT="$(git ls-files --other --exclude-standard | wc -l | tr -d ' ')"  
  if [[ UNTRACKED_COUNT -gt 0 ]]; then
    if [[ $SHOULD_INSERT_SPACE == 1 ]]; then
      GIT_STATE="$GIT_STATE "
      SHOULD_INSERT_SPACE=0
    fi
    GIT_STATE="$GIT_STATE$GIT_PROMPT_UNTRACKED%{$fg[red]%}$UNTRACKED_COUNT%{$reset_color%}"
    SHOULD_INSERT_SPACE=1
  fi

  local MODIFIED="$(git diff --name-only | wc -l | tr -d ' ')"
  # if ! git diff --quiet 2> /dev/null; then
  if [[ $MODIFIED -gt 0 ]]; then
    if [[ $SHOULD_INSERT_SPACE == 1 ]]; then
      GIT_STATE="$GIT_STATE "
      SHOULD_INSERT_SPACE=0
    fi
    GIT_STATE=$GIT_STATE$GIT_PROMPT_MODIFIED$MODIFIED
    SHOULD_INSERT_SPACE=1
  fi

  local STAGED="$(git diff --cached --name-only | wc -l | tr -d ' ')"
  # if ! git diff --cached --quiet 2> /dev/null; then
  if [[ $STAGED -gt 0 ]]; then
    if [[ $SHOULD_INSERT_SPACE == 1 ]]; then
      GIT_STATE="$GIT_STATE "
      SHOULD_INSERT_SPACE=0
    fi
    GIT_STATE=$GIT_STATE$GIT_PROMPT_STAGED
    GIT_STATE="$GIT_STATE%{$fg[green]%}$STAGED%{$reset_color%}"
  fi

  if [[ -n $GIT_STATE ]]; then
    echo " $GIT_STATE"
  fi

}

# See http://stackoverflow.com/questions/2969214/git-programmatically-know-by-how-much-the-branch-is-ahead-behind-a-remote-branc
parse_git_ahead() {

  local AHEAD=""

  # work out the current branch name
  currentbranch=$(expr $(git symbolic-ref HEAD) : 'refs/heads/\(.*\)')
  [ -n "$currentbranch" ] || die "You don't seem to be on a branch"

  # look up this branch in the configuration
  remote=$(git config branch.$currentbranch.remote)
  remote_ref=$(git config branch.$currentbranch.merge)

  if [[ -n $remote ]]; then
    # convert the remote ref into the tracking ref... this is a hack
    remote_branch=$(expr $remote_ref : 'refs/heads/\(.*\)')
    tracking_branch=refs/remotes/$remote/$remote_branch

    # now $tracking_branch should be the local ref tracking HEAD
    ahead=$(git rev-list $tracking_branch..HEAD | wc -l | tr -d ' ')
    behind=$(git rev-list HEAD..$tracking_branch | wc -l | tr -d ' ')

    if [[ $ahead -gt 0 ]]; then
      AHEAD="⬆ $ahead"
    fi

    if [[ $behind -gt 0 ]]; then
      if [[ $ahead -gt 0 ]]; then
        AHEAD=$AHEAD" "
      fi      
      AHEAD=$AHEAD"⬇ $behind"
    fi
  fi

  if [[ -n $AHEAD ]]; then
    echo " $AHEAD"
  fi

}

# If inside a Git repository, print its branch and state
git_prompt_string() {
  local git_where="$(parse_git_branch)"
  [ -n "$git_where" ] && echo " $GIT_PROMPT_PREFIX%{$fg[yellow]%}${git_where#(refs/heads/|tags/)}$(parse_git_ahead)$(parse_git_state)$GIT_PROMPT_SUFFIX"
}

PROMPT='%F{cyan}${_prompt_sorin_pwd}%f%(!. %B%F{red}#%f%b.)$(git_prompt_string)${editor_info[keymap]} '