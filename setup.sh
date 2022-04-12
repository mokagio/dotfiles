#!/bin/bash

set -e

dotfiles=(
  'aliases'
  'editorconfig'
  'gemrc'
  'gitconfig'
  'gitignore'
  'ghci'
  'ideavimrc'
  'lldbinit'
  'liftoffrc'
  'luarocks'
  'tigrc'
  'vimrc'
  'vimrc.plugs'
  'xvimrc'
  'zshrc'
  'zshenv'
  'zshprompt'
)

pwd=`pwd`

# for dot in "${dotfiles[@]}"
# do
#   src="$pwd/$dot" # can't use source, it's a command ;)
#   destination="$HOME/.$dot"

#   if [[ -h "$destination" ]]; then
#     echo "$destination exists already, skipping"
#   else
#     echo "ln -s $pwd/$dot ~/.$dot"
#     ln -s $pwd/$dot ~/.$dot
#   fi
# done

# Link Vim spellfile.
# Not sure how to symlink and entire folder yet
mkdir -p ~/.vim/spell
# Note that you should not use `_` in the file name, see
# https://unix.stackexchange.com/questions/85538/how-can-i-create-my-own-spelling-file-for-vim
vim_spell_path="$pwd/vim/spell/custom-spell.utf-8.add"
if [[ -f $vim_spell_path ]]; then
  # Interestingly, I had to use $HOME here instead of ~, otherwise, ln would
  # fail with "No such file or directory". Why does ~ work above but not here?
  # Is it because there's nested folders in this destination path?
  ln -s "$vim_spell_path" "$HOME/.vim/spell/custom-spell.utf-8.add"
else
  echo "Could not find $vim_spell_path! Aborting."
  exit 1
fi
exit 1

brew bundle
# Some of the tools install via Homebrew might need additional manual steps.
# It would be cool if this could be done as part of the Brefile run
#
# Install fzf useful keybindings and fuzzy completion for ZSH
[ -f ~/.fzf.zshhh ] || $(brew --prefix)/opt/fzf/install
# Bypass gatekeeper for QLColorCode
# https://github.com/anthonygelibert/QLColorCode/issues/84
xattr -cr ~/Library/QuickLook/QLColorCode.qlgenerator

# Install nvm to manage Node's versions
export NVM_DIR="$HOME/.nvm"
if [[ -d "$NVM_DIR" ]]; then
  echo "Looks like you have nvm already setup, skipping"
else
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash
  # Load nvm in the shell running this script in order to install Node with nvm
  # next and avoid warning later on.
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  nvm install node
fi
# Now that you got Node, add Yarn, too
npm install -g yarn

# Install Vim-Plug to manage Vim plugins
# See https://github.com/junegunn/vim-plug/tree/c3b6b7c2971da730d66f6955d5c467db8dae536b#vim
vim_plug_path="$HOME/.vim/autoload/plug.vim"
if [[ -f "$vim_plug_path" ]]; then
  echo "Looks like you already have Vim-Plug installed, skipping"
else
  curl -fLo "$vim_plug_path" --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi

# install system wide gems
bundle install --system

# Hammerspoon window manager
# http://www.hammerspoon.org/
mkdir -p ~/.hammerspoon
ln -s $pwd/hammerspoon_init.lua ~/.hammerspoon/init.lua

# Powerline fonts
powerline_url="https://github.com/powerline/fonts#quick-installation"
echo "You need to install Powerline fonts, to make the most of your terminal prompt and Vim."
echo "I'm going to open the GitHub page for you: $powerline_url"
open "$powerline_url"

# Automattic stuff
#
# pecl is a PHP extensions manager, xdebug is "an extension of PHP to assist
# with debugging and development"
pecl install xdebug
