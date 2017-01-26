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

# link bin folder
ln -s $pwd/bin ~/bin

# install system wide gems
bundle install --system

# install Xcode plugins
fastlane install_xcode_plugins
