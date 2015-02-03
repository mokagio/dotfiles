#!/bin/bash

dotfiles=('vimrc' 'vimrc.bundles' 'xvimrc' 'zshrc' 'zshenv')

pwd=`pwd`

for dot in "${dotfiles[@]}"
do
  echo "ln -s $pwd/$dot ~/.$dot"
  ln -s $pwd/$dot ~/.$dot
done

