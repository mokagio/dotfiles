#!/bin/bash

dotfiles=(
  'aliases'
  'gitconfig'
  'gitignore'
  'ghci'
  'ideavimrc'
  'lldbinit'
  'liftoffrc'
  'luarocks'
  'vimrc'
  'vimrc.plugs'
  'xvimrc'
  'zshrc'
  'zshenv'
  'zshprompt'
)

pwd=`pwd`

for dot in "${dotfiles[@]}"
do
  echo "ln -s $pwd/$dot ~/.$dot"
  ln -s $pwd/$dot ~/.$dot
done

# Link Vim spellfile.
# Not sure how to symlink and entire folder yet
mkdir -p ~/.vim/spell
# Note that you should not use `_` in the file name, see
# https://unix.stackexchange.com/questions/85538/how-can-i-create-my-own-spelling-file-for-vim
ln -s $pwd/vim/spell/custom-spell.utf-8.add ~/.vim/spell/custom-spell.utf-8.add

# link bin folder
ln -s $pwd/bin/ ~/bin

brew tap Homebrew/bundle
brew bundle

# Install nvm to manage Node's versions
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash
# Load nvm in the shell running this script in order to install Node with nvm
# next and avoid warning later on.
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
nvm install node

# Install Vim-Plug to manage Vim plugins
# See https://github.com/junegunn/vim-plug/tree/c3b6b7c2971da730d66f6955d5c467db8dae536b#vim
curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# install system wide gems
bundle install --system

# Hammerspoon window manager
# http://www.hammerspoon.org/
mkdir -p ~/.hammerspoon
ln -s $pwd/hammerspoon_init.lua ~/.hammerspoon/init.lua
