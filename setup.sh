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
  'mjolnir'
  'vimrc'
  'vimrc.bundles'
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

# install system wide gems
bundle install --system

# install Xcode plugins
fastlane install_xcode_plugins

# install lua plugins for Mjolnir
luarocks install mjolnir.bg.grid
luarocks install mjolnir.application
luarocks install mjolnir.hotkey
