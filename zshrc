# Executes commands at the start of an interactive session.
# Based on the .zshrc from the prezto project: https://github.com/sorin-ionescu/prezto

# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
else
  echo "\033[1;31mMissing zprezto folder. Have a look inside the zshrc.\033[0m"
fi
echo "\033[1;31mTODO: Make the shell setup independent from zprezto!\033[0m"

# Use vim keybindings
bindkey -v
# Re-enable Ctrl-r to search history (vim keybindning disabled it)
bindkey '^R' history-incremental-search-backward


# autojump configs
[[ -s $(brew --prefix)/etc/profile.d/autojump.sh  ]] && . $(brew --prefix)/etc/profile.d/autojump.sh

# Turn off autocorrect for some commands
# See http://yountlabs.com/blog/2010/11/06/disable-autocorrect-in-zsh/
alias jake='nocorrect jake'
alias leiningen='nocorrect leiningen'

# As reccomended in the bower installer
alias bower='noglob bower'

# zsh powerups folder
path_to_zsh_powerups=~/Developer/mokagio/zsh

# Aliases
if [[ -s "${HOME}/.aliases" ]]; then
  source "${HOME}/.aliases"
else
  echo "\033[1;31mMissing aliases file. Have a look inside the zshrc.\033[0m"
fi
#path_to_aliases_folder=$path_to_zsh_powerups/zsh-moka-aliases
#source $path_to_zsh_powerups/zsh-moka-aliases/zsh_moka_aliases.zsh

alias showFiles='defaults write com.apple.finder AppleShowAllFiles YES; killall Finder /System/Library/CoreServices/Finder.app'
alias hideFiles='defaults write com.apple.finder AppleShowAllFiles NO; killall Finder /System/Library/CoreServices/Finder.app'

# fancy git status on prompt
# note: loading this at the end so all the aliases and imported things are available in there
if [[ -s "${HOME}/.zshprompt" ]]; then
  source "${HOME}/.zshprompt"
else
  echo "\033[1;31mMissing custom prompt file. Have a look inside the zshrc.\033[0m"
fi


# added by travis gem
[ -f /Users/gio/.travis/travis.sh ] && source /Users/gio/.travis/travis.sh

# if there is a local zshrc, load it
LOCAL_ZSHRC="${HOME}/.zshrc.local"
[ -f "$LOCAL_ZSHRC" ] && source "$LOCAL_ZSHRC"

test -e ${HOME}/.iterm2_shell_integration.zsh && source ${HOME}/.iterm2_shell_integration.zsh

# chruby the simplest ruby version manager ever
# https://github.com/postmodern/chruby
source /usr/local/opt/chruby/share/chruby/chruby.sh
# enable chruby auto switch ruby version by looking into .rbuy-versionafile
source /usr/local/opt/chruby/share/chruby/auto.sh

if which swiftenv > /dev/null; then eval "$(swiftenv init -)"; fi

LUNCHY_DIR=$(dirname `gem which lunchy`)/../extras
if [ -f $LUNCHY_DIR/lunchy-completion.zsh  ]; then
	. $LUNCHY_DIR/lunchy-completion.zsh
fi
