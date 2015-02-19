#!/bin/bash

dotfiles=(
  'aliases'
  'gitconfig'
  'gitignore'
  'lldbinit'
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

