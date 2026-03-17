#!/bin/bash

if [[ -z "$DOTFILES_HOME" ]]; then
  printf "\033[1;31mDOTFILES_HOME is not defined. Please set it before sourcing aliases.\033[0m\n" >&2
fi

# Reload zshrc
alias sss='source ~/.zshrc'

# Forget Me Not Task Manager
alias tl='fmn list'
alias ta='fmn add'
alias td='fmn done'
# Joseph "assistant"
alias jj='joseph'

# Misc
alias t='tig'
alias k9='kill -9'

# GitHub CLI (replaces hub, which is deprecated)
alias gpr='gh pr create --draft'
alias grp=gpr
alias grpn='gh pr create'
alias cpr='gh pr checkout' # usage `cpr <PR id>`
alias hb='gh browse' # open GitHub for the current repo and branch combo

# iOS & OS X development
alias xco='[[ -f Project.swift ]] && tuist generate || open -a Xcode .'
alias xbo='open -a /Applications/Xcode-beta.app .'
alias rmd='rm -rf DerviedData'

# Ruby gem to find unused Objective-C imports, and eventually delete them
# https://github.com/dblock/fui
alias fui='nocorrect fui'

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
alias ast='open -a Android\ Studio'

# Apps
alias chrome='open -a Google\ Chrome'
alias v='nvim'
alias ao='open -a /Applications/Android\ Studio.app'

# Vim Wiki & Zettlekasen
#
# At somepoint, you might get a Ruby executable called ww, which, as far as I
# can tell, has to do with building web apps with Rack and Sinatar, and also
# seems pretty old. Seems pretty safe to override this.
# https://rubygems.org/gems/ww
# Using ww because that's the same leader command to bring up the wiki.
if [[ -d $VIMWIKI_HOME ]]; then # Note that VIMWIKI_HOME should be define in the .zshrc.local
  alias wr='$EDITOR $(find $VIMWIKI_HOME/zettelkasten -type f -not -path "*/\.*" | shuf -n 1)'
  alias tc='pushd $VIMWIKI_HOME && ./bin/track_changes && popd'
  alias ww='pushd $VIMWIKI_HOME && ./bin/fetch_if_stale && $EDITOR -c VimwikiIndex; ./bin/track_changes; popd'
else
  # This is the one most likely to run, the others are secondary and it would
  # be redundant to do the same for them, too.
  alias ww='echo "Could not find VIMWIKI_HOME in the environment."; false'
fi

alias wlg='vim $HOME/Dropbox/.worklog_wiki/index.md'

# Utils
# (You can download the "Lee" voice from the Voice Utility app)
alias sey="say -v Oliver \"Joe, I've completed the task you gave me\""

# Fastlane
alias f='fastlane'
alias bf='bundle exec fastlane'

# Update any software installed via Homebrew
# fd = fresh drink
alias fd='brew update && brew upgrade'

alias pb='pbcopy'

# Modern ls with git awareness
# https://github.com/eza-community/eza
alias ls='eza'
alias ll='eza -l --git'
alias la='eza -la --git'
alias lt='eza --tree --level=2'

# A cat with syntax highlighting and Git support
# https://github.com/sharkdp/bat
alias cat='bat --style="plain,header,grid"'
# Keep the original cat around
alias oldcat='/bin/cat'

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

# This might be better as a scripts, to be fair
#
# Use like: cat file.yml | ymlparse
alias ymlparse="ruby -ryaml -e 'puts YAML::load(STDIN.read, aliases: true)'"
alias yamlparse=ymlparse

alias cl='claude'
alias cld='claude --dangerously-skip-permissions'
alias /cld='cld'
