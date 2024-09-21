#!/bin/bash

#
# Aliases for Git only.
# See aliases.sh for other commands.
#

alias g='git'
alias gb='git branch'
alias gs='nocorrect git status --short'
alias ga='nocorrect git add'
# This used to be
#
#   alias gaa='nocorrect git add --all'
#
# but I fucked up enought time by adding all files and pushing that I've
# finally decided to stop myself from doing that.
gaa_message="Do not commit files like that you idiot!"
alias gaa='echo "$gaa_message" && say "$gaa_message"'
alias gc='nocorrect git commit'
alias gcm='nocorrect git commit -m'
alias gcn='git commit --amend --no-edit'
alias gp='nocorrect git push'
alias gpu='nocorrect git push -u'
alias gl='nocorrect git pull'
# Warning: This will conflict with GitHub's CLI binary, gh
alias gh='git checkout'
alias ghp='git checkout -p'
alias gh.='git checkout .'
alias gh-='git checkout -'
# gh is actually the name of GitHub's CLI, but I got 5 years of muscle memory
# using gh as my checkout alias, so here's an alias for GitHub's gh
alias ghb='/usr/local/bin/gh'
alias gnb='git checkout -b'
alias gd='git diff'
alias gdc='git diff --cached'
alias gm='git merge'
alias gr='git rebase'
alias gf='git fetch'
# At iflix, the base branch was always master, in the Automattic mobile
# division it's develop. I wonder if there's a way to read what the base branch
# is from somewhere...
alias gfr='git fetch && git rebase origin/trunk'
alias gfrm='git fetch && git rebase origin/master'
alias gt='git tag'
# merge by always making a new commit (--no-ff) and open editor for the commit message (-e)
alias gmm='git merge --no-ff -e'
alias gsp='git submodule foreach git pull'
alias gsu='git submodule update'
alias gcp='git cherry-pick'
alias glgr='git log --oneline --reverse'
alias grbc='git rebase --continue'
alias gsh='git show head'

# See https://coderwall.com/p/euwpig
GLG_FORMAT_SHA_SHORT='%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)%an%Creset'
GLG_FORMAT_SHA_LONG='%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)%an%Creset - %Cred%H %C(yellow)(%h)%Creset'
# This is here just so we don't get unused warnings for the other mode definition
GLG_MODE='long'
if [[ $GLG_MODE == 'long' ]]; then
  GLG_FORMAT=$GLG_FORMAT_SHA_LONG
else
  GLG_FORMAT=$GLG_FORMAT_SHA_SHORT
fi

alias glg='git log --graph --pretty=format:"$GLG_FORMAT" --abbrev-commit'

# see above + only show commits made in the the current branch
alias glgf='glg --first-parent'
# I make this typo from time to time on Colemak
alias gjg='glg'

# Stay safe when git commit -a
safe_command() {
	message=$1
	shift 1
	printf "%s\n" "$message"; printf "\e[0;33;49mAre you sure? (y/n) \e[0m"; read -r ANSWER; if [ "$ANSWER" = y ]; then "$@"; fi;
}
message='\e[0;33;49mYou are about to perform a git commit all.\e[0m'
# no correct doesn't work here... why?
gca_cmd='git commit -a'
gcam_cmd='git commit -a -m'
alias gca='safe_command "$message" $gca_cmd'
alias gcam='safe_command "$message" $gcam_cmd'
alias gri="git rebase --interactive"
alias gir=gri
alias gpt="git push; git push --tags"
alias gap="git add -p"
alias gchp="git checkout -p"
# List the 10 most recent branches
alias grb="git branch --sort=committerdate | tail -10 | more"
# Custom script to interactively stash files
# TODO: this needs to be parametric, can't depend on an hardcoded path
alias gsa='ruby $DOTFILES_HOME/scripts/interactive-stage.rb'

# Git-Flow aliases
# https://github.com/nvie/gitflow
CMD=git-flow
if command -v $CMD &>/dev/null; then
  alias gfl='nocorrect git flow'
  alias gff='nocorrect git flow feature'
  alias gffs='nocorrect git flow feature start'
  alias g3f='nocorrect git flow feature finish'
else
  echo "$CMD not found. Dedicated aliases skipped."
fi
