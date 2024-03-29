#!/bin/bash

# Reload zshrc
alias sss='source ~/.zshrc'

# Forget Me Not Task Manager
alias tl='fmn list'
alias ta='fmn add'
alias td='fmn done'

# Misc
alias t='tig'
alias k9='kill -9'

# Navigation
alias ~='cd ~'
alias o='open'

# git
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
git_log_formatted() {
  GLG_FORMAT_SHA_SHORT='%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)%an%Creset'
  GLG_FORMAT_SHA_LONG='%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)%an%Creset - %Cred%H %C(yellow)(%h)%Creset'
  # This is here just so we don't get unused warnings for the other mode definition
  GLG_MODE='long'
  if [[ $GLG_MODE == 'long' ]]; then
    GLG_FORMAT=$GLG_FORMAT_SHA_LONG
  else
    GLG_FORMAT=$GLG_FORMAT_SHA_SHORT
  fi

  git log \
    --graph \
    --pretty=format:"$GLG_FORMAT" \
    --abbrev-commit
}
alias glg=git_log_formatted

# see above + only show commits made in the the current branch
alias glgf='glg --first-parent'
# I make this typo from time to time on Colemak
alias gjg='glg'

# Hub is a CLI client for the GitHub APIs
# https://github.com/github/hub
alias gpr='hub pull-request --draft'
alias grp=gpr
alias grpn='hub pull-request'
alias cpr='hub pr checkout' # usage `cpr <PR id>`
alias hb='hub browse' # open GitHub for the current repo and branch combo

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
alias gfl='nocorrect git flow'
alias gff='nocorrect git flow feature'
alias gffs='nocorrect git flow feature start'
alias g3f='nocorrect git flow feature finish'

# iOS & OS X development
alias xco='[[ -f Project.swift ]] && tuist generate || open -a Xcode .'
alias xbo='open -a /Applications/Xcode-beta.app .'
alias aco='open -a AppCode .'
alias rmd='rm -rf DerviedData'

alias pii='nocorrect pod install'
alias pi='nocorrect pod install && xco'
# --repo-update is useful to avoid the occasional resolution dependency failure
# in my "day" job at Automattic
alias bpi='bundle exec pod install --repo-update'
alias bip='bpi' # for typos

# Ruby gem to find unused Objective-C imports, and eventually delete them
# https://github.com/dblock/fui
alias fui='nocorrect fui'

# Note! this assumes you have xctool available in your path
# and the .xctoolargs in the current working directory
alias xt='xctool test'
alias ..='cd ..'

# Ruby
alias r='ruby'
alias rr='rake'
alias b='bundle install'
alias bu='bundle update'
alias be='bundle exec'
alias br='bundle exec rake'
alias ber='bundle exec ruby'

# JavaScript & TypeScript
alias nmp='npm'
alias ya='yarn'
alias yt='yarn test'

# Android
alias a='open -a Android\ Studio'

# Apps
alias chrome='open -a Google\ Chrome'
alias m='open -a MacDown'
alias v='vim'
alias ao='open -a /Applications/Android\ Studio.app'

# Vim Wiki & Zettlekasen
#
# At somepoint, you might get a Ruby executable called ww, which, as far as I
# can tell, has to do with building web apps with Rack and Sinatar, and also
# seems pretty old. Seems pretty safe to override this.
# https://rubygems.org/gems/ww
# Using ww because that's the same leader command to bring up the wiki.
if [[ -d $VIMWIKI_HOME ]]; then # Note that VIMWIKI_HOME should be define in the .zshrc.local
  alias ww='git -C $VIMWIKI_HOME pull || true && vim -c VimwikiIndex'
  alias wr='vim $(find $VIMWIKI_HOME/writing-business -type f -not -path "*/\.*" | shuf -n 1)'
  alias tc='pushd $VIMWIKI_HOME && ./track_changes && popd'
else
  # This is the one most likely to run, the others are secondary and it would
  # be redundant to do the same for them, too.
  alias ww='echo "Could not find VIMWIKI_HOME in the environment."; false'
fi

alias cask='brew cask'

# Utils
# (You can download the "Lee" voice from the Voice Utility app)
alias sey="say -v Oliver \"Joe, I've completed the task you gave me\""

# Carthage
# using tu because cu is already taken by a system command
alias tu='carthage update --no-build'
alias tub='carthage update --build'

# Fastlane
alias f='fastlane'
alias bf='bundle exec fastlane'

# Update any software installed via Homebrew
# fd = fresh drink
alias fd='brew update && brew upgrade'

alias pb='pbcopy'

# A cat with syntax highlighting and Git support
# https://github.com/sharkdp/bat
alias cat='bat --style="plain,header,grid"'

# GNU's wc is better than the macOS one, e.g. it has the -L option to find the
# longest line in a file
if type gwc > /dev/null; then
  alias wc=gwc
fi

alias md=mkdir

mkdir_and_cd() {
  mkdir "$1" && cd "$1" || exit 1
}
alias mc=mkdir_and_cd

alias haed=head

alias myip="ifconfig | grep 'inet ' | grep --invert-match 127 | cut -d' ' -f2"

# React Native
alias rn="npx react-native"
alias rni="npx react-native run-ios"

# Common typos I make
alias vm=mv
alias crul=curl

alias mp='vim -c Goyo ~/Dropbox/writing/morning-pages/$(date "+%Y-%m-%d-%H%M").md'
# `np` is already taken by another custom script
alias npg='vim -c Goyo ~/Dropbox/writing/night-pages/$(date "+%Y-%m-%d-%H%M").md'
# last-night-questions
alias lnq='cat "$(ls -1rt ~/Dropbox/writing/night-pages/*.md | tail -n1)"'

# Use this in a Pod libray repo to check if the version is
# stable or beta and whether a new release is required
alias check_pod_version='gh trunk && gl && cat *.podspec | grep version'

# This might be better as a scripts, to be fair
#
# Use like: cat file.yml | ymlparse
alias ymlparse="ruby -ryaml -e 'puts YAML::load(STDIN.read)'"
