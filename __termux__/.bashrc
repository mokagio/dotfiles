export DOTFILES_HOME=$HOME/dotfiles
export VIMWIKI_HOME=$HOME/zettelkasten

export GIT_EDITOR=$(which nvim)

alias v=nvim

alias ww="nvim $VIMWIKI_HOME/zettelkasten/index.md"

source $HOME/dotfiles/aliases.git.sh
source $HOME/dotfiles/aliases.navigation.sh
