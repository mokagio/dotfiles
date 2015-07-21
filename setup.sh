#!/bin/bash

dotfiles=(
  'aliases'
  'gitconfig'
  'gitignore'
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

# install lua plugins for Mjolnir
luarocks install mjolnir.bg.grid
luarocks install mjolnir.application
luarocks install mjolnir.hotkey
