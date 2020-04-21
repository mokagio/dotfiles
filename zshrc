# Executes commands at the start of an interactive session.

# ZSH Plugin manager
source /usr/local/share/antigen/antigen.zsh

antigen use prezto

# When you try to use a command that is not available locally, searches the
# package manager for a package offering that command and suggests the proper
# install command.
antigen bundle command-not-found
antigen bundle colored-man-pages
# A bunch of handy aliases. See:
# https://github.com/sorin-ionescu/prezto/tree/95ff0360aeef951111c5ca6a80939e9329ddb434/modules/utility
antigen bundle utility
# Syntax highlighting (commands are one color, text in quotes is another, etc.)
antigen bundle zsh-users/zsh-syntax-highlighting
antigen bundle zsh-users/zsh-autosuggestions
# Better completions
antigen bundle zsh-users/zsh-completions
# This makes it so that tab completions are case insensitive
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z} m:=_ m:=- m:=.'

# "open Vim and hit Crtl-Z. Now you don't need anymore hit fg, but only Crtl-Z
# again"
antigen bundle alexrochas/zsh-vim-crtl-z
zle -N fancy-ctrl-z
bindkey '^Z' fancy-ctrl-z

# You can find more modules for prezto at
# https://github.com/sorin-ionescu/prezto/tree/master/modules

antigen theme denysdovhan/spaceship-prompt

antigen apply

# Spaceship prompt settings
# https://github.com/denysdovhan/spaceship-prompt/blob/6319158f19a7bb83a8131da7268213cb636f9653/docs/Options.md
#
# This will split the prompt from the user input in two lines,
# which is handy when the prompt is long because of a long branch
# name and/or multiple versions being listed
SPACESHIP_PROMPT_SEPARATE_LINE=true
# I don't like how the prompt says "via 💎 v2.3.0"
SPACESHIP_RUBY_PREFIX=''
SPACESHIP_TIME_SHOW=true
SPACESHIP_VI_MODE_SHOW=false # don't need to know the Vi mode I'm in
SPACESHIP_GIT_PREFIX=''

# Use vim keybindings
bindkey -v
# Re-enable Ctrl-r to search history (vim keybindning disabled it)
bindkey '^R' history-incremental-search-backward
# When in normal mode, press v to edit the command in the $VISUAL editor
autoload -z edit-command-line
zle -N edit-command-line
bindkey -M vicmd v edit-command-line

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
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
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

# Useful keybindings and fuzzy completion for fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
