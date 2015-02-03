#
# Executes commands at the start of an interactive session.
#
# Authors:
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#

# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# Customize to your needs...

# autojump configs
[[ -s `brew --prefix`/etc/autojump.sh ]] && . `brew --prefix`/etc/autojump.sh

#
# Addition to PATH
#

# Add RVM to PATH for scripting
#PATH=$PATH:$HOME/.rvm/bin
#PATH=$PATH:$HOME/.rvm/gems/ruby-2.0.0-p247/bin

# Add RBENV to PATH
PATH=$HOME/.rbenv/bin:$PATH
eval "$(rbenv init -)"

# Add npm global folder
PATH=$PATH:/usr/local/share/npm/bin/

# Add Postgres.app bins
PATH=$PATH:/Applications/Postgres.app/Contents/MacOS/bin/

# Add personal scripts
# example
PATH=$PATH:$HOME/Scripts/

# OCLint
PATH=$PATH:$HOME/Executables/oclint/bin

#
# Turn off autocorrect for some commands
#
# See http://yountlabs.com/blog/2010/11/06/disable-autocorrect-in-zsh/

alias jake='nocorrect jake'

# As reccomended in the bower installer
alias bower='noglob bower'

# zsh powerups folder
path_to_zsh_powerups=~/Developer/mokagio/zsh

# fancy git status on prompt
source $path_to_zsh_powerups/mokagio-zsh-git-prompt/mokagio-zsh-git-prompt.zsh

# mokagio aliases
path_to_aliases_folder=$path_to_zsh_powerups/zsh-moka-aliases
source $path_to_zsh_powerups/zsh-moka-aliases/zsh_moka_aliases.zsh

alias leiningen='nocorrect leiningen'

source $HOME/.bizzby-aws-keys.zsh

alias showFiles='defaults write com.apple.finder AppleShowAllFiles YES; killall Finder /System/Library/CoreServices/Finder.app'
alias hideFiles='defaults write com.apple.finder AppleShowAllFiles NO; killall Finder /System/Library/CoreServices/Finder.app'

export RBENV_VERSION="2.1.3"

