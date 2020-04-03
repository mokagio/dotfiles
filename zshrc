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

# Ruby environment management setup
eval "$(rbenv init -)"

if which swiftenv > /dev/null; then eval "$(swiftenv init -)"; fi

if gem which lunchy &> /dev/null; then
  LUNCHY_DIR=$(dirname `gem which lunchy`)/../extras
  if [ -f $LUNCHY_DIR/lunchy-completion.zsh  ]; then
    . $LUNCHY_DIR/lunchy-completion.zsh
  fi
fi

export NVM_DIR="$HOME/.nvm"
# This loads nvm
[ -s "/usr/local/opt/nvm/nvm.sh" ] && . "/usr/local/opt/nvm/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
                                                                    # does it work with ZSH too?
# This automactically calls nvm use when going in a folder with an .nvmrc
autoload -U add-zsh-hook
load-nvmrc() {
  local node_version="$(nvm version)"
  local nvmrc_path="$(nvm_find_nvmrc)"

  if [ -n "$nvmrc_path" ]; then
    local nvmrc_node_version=$(nvm version "$(cat "${nvmrc_path}")")

    if [ "$nvmrc_node_version" = "N/A" ]; then
      nvm install
    elif [ "$nvmrc_node_version" != "$node_version" ]; then
      nvm use
    fi
  elif [ "$node_version" != "$(nvm version default)" ]; then
    echo "Reverting to nvm default version"
    nvm use default
  fi
}
add-zsh-hook chpwd load-nvmrc
load-nvmrc

# Autosuggestions via https://github.com/zsh-users/zsh-autosuggestions
source /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# Convert an input `.md` file to HTML and paste it to the clipboard.
# I use this everytime I work on a newsletter or other text content to paste
# into an HTML editor.
md2html() {
  if [[ -z "$1" ]]; then
    # `printf` will not add a newline at the end of the printed output
    printf "Missing path to .md file to convert to HTML"
    # return something that's not 0 so the consumer knows there's been an
    # error.
    return 1
  fi

  pandoc --from gfm --to html --standalone $1 | pbcopy
}

# Fastlane autocompletion
# https://docs.fastlane.tools/faqs/#enable-tab-auto-complete-for-fastlane-lane-names
. ~/.fastlane/completions/completion.sh
