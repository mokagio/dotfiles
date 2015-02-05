# Executes commands at the start of an interactive session.
# Based on the .zshrc from the prezto project: https://github.com/sorin-ionescu/prezto

# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
else
  echo "\033[1;31mMissing zprezto folder. Have a look inside the zshrc.\033[0m"
fi
echo "\033[1;31mTODO: Make the shell setup independent from zprezto!\033[0m"

# autojump configs
[[ -s `brew --prefix`/etc/autojump.sh ]] && . `brew --prefix`/etc/autojump.sh

# Turn off autocorrect for some commands
# See http://yountlabs.com/blog/2010/11/06/disable-autocorrect-in-zsh/
alias jake='nocorrect jake'
alias leiningen='nocorrect leiningen'

# As reccomended in the bower installer
alias bower='noglob bower'

# zsh powerups folder
path_to_zsh_powerups=~/Developer/mokagio/zsh

# fancy git status on prompt
if [[ -s "${HOME}/.zshprompt" ]]; then
  source "${HOME}/.zshprompt"
else
  echo "\033[1;31mMissing custom prompt file. Have a look inside the zshrc.\033[0m"
fi

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

