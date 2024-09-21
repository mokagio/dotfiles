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

# Git
GIT_ALIASES_PATH="$(dirname "${BASH_SOURCE[0]}")/aliases.git.sh"
if [[ -f "$GIT_ALIASES_PATH" ]]; then
  # shellcheck disable=SC1090
  source "$GIT_ALIASES_PATH"
else
  echo "Could not find Git aliases at $GIT_ALIASES_PATH"
fi

# Hub is a CLI client for the GitHub APIs
# https://github.com/github/hub
alias gpr='hub pull-request --draft'
alias grp=gpr
alias grpn='hub pull-request'
alias cpr='hub pr checkout' # usage `cpr <PR id>`
alias hb='hub browse' # open GitHub for the current repo and branch combo

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
alias ymlparse="ruby -ryaml -e 'puts YAML::load(STDIN.read, aliases: true)'"
alias yamlparse=ymlparse
