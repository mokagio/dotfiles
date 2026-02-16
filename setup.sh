#!/usr/bin/env bash

set -eu

dotfiles=(
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
  'vimrc.zettlekasten'
  'vimrc.plugs'
  'xvimrc'
  'zshrc'
  'zshenv'
  'zshprompt'
)

pwd=$(pwd)

for dot in "${dotfiles[@]}"
do
  destination="$HOME/.$dot"

  if [[ -h "$destination" ]]; then
    echo "$destination exists already, skipping"
  else
    echo "Will run: ln -s $pwd/$dot $HOME/.$dot"
    ln -s "$pwd/$dot" "$HOME/.$dot"
  fi
done

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
  destination="$HOME/.vim/spell/custom-spell.utf-8.add"
  # TODO: This logic is duplicated from above. Extract it in a function
  if [[ -h $destination ]]; then
    echo "$destination exists already, skipping"
  else
    echo "Will run: ln -s $vim_spell_path $destination"
    ln -s "$vim_spell_path" "$destination"
  fi
else
  echo "Could not find $vim_spell_path! Aborting."
  exit 1
fi

# NeoVim
neovim_root=~/.config/nvim
neovim_init="$pwd/neovim_init.vim"
mkdir -p "$neovim_root"
if [[ -f $neovim_init ]]; then
  destination="$neovim_root/init.vim"
  if [[ -h $destination ]]; then
    echo "$destination exists already, skipping."
  else
    echo "Will run: ln -s $neovim_init $destination"
    ln -s "$neovim_init" "$destination"
  fi
else
  echo "Could not find $neovim_init! Aborting."
  exit 1
fi

if ! brew bundle; then
  printf "\033[1;31mbrew bundle finished with errors. Some formulae may not have installed.\033[0m\n"
  printf "\033[1;31mRun 'brew bundle' manually to retry.\033[0m\n"
fi
# Some of the tools install via Homebrew might need additional manual steps.
# It would be cool if this could be done as part of the Brefile run
#
# Install fzf useful keybindings and fuzzy completion for ZSH
[[ -f ~/.fzf.zsh ]] || "$(brew --prefix)/opt/fzf/install"
# Bypass gatekeeper for QLColorCode
# https://github.com/anthonygelibert/QLColorCode/issues/84
xattr -cr ~/Library/QuickLook/QLColorCode.qlgenerator

# TODO: Have switched to fnm
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

# Install Vim-Plug to manage Vim plugins
# See https://github.com/junegunn/vim-plug/tree/c3b6b7c2971da730d66f6955d5c467db8dae536b#vim
vim_plug_path="$HOME/.vim/autoload/plug.vim"
if [[ -f "$vim_plug_path" ]]; then
  echo "Looks like you already have Vim-Plug installed, skipping"
else
  curl -fLo "$vim_plug_path" --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi

# Install Vim and Neovim plugins
vim --not-a-term +PlugInstall +qall
if command -v nvim &>/dev/null; then
  nvim --headless +PlugInstall +qall
fi

# Install latest Ruby and system wide gems
if command -v rbenv &>/dev/null; then
  latest_ruby=$(rbenv install -l | grep -v - | tail -1)
  rbenv install --skip-existing "$latest_ruby"
  rbenv global "$latest_ruby"
  gem install bundler
  if ! bundle install; then
    printf "\033[1;31mbundle install failed. Run it manually to retry.\033[0m\n"
  fi
else
  printf "\033[1;31mrbenv not found, skipping Ruby setup.\033[0m\n"
fi

# Hammerspoon window manager
# http://www.hammerspoon.org/
mkdir -p ~/.hammerspoon
destination="$HOME/.hammerspoon/init.lua"
if [[ -h "$destination" ]]; then
  echo "$destination exists already, skipping"
else
  echo "Will run: ln -s $pwd/hammerspoon_init.lua $destination"
  ln -s "$pwd/hammerspoon_init.lua" "$destination"
fi

# Powerline fonts
powerline_url="https://github.com/powerline/fonts#quick-installation"
echo "You need to install Powerline fonts, to make the most of your terminal prompt and Vim."
echo "I'm going to open the GitHub page for you: $powerline_url"
open "$powerline_url"

# Claude Code
mkdir -p ~/.claude
for f in claude/settings.json claude/CLAUDE.md claude/statusline.sh; do
  destination="$HOME/.${f}"
  if [[ -h "$destination" ]]; then
    echo "$destination exists already, skipping"
  else
    echo "Will run: ln -s $pwd/$f $destination"
    ln -s "$pwd/$f" "$destination"
  fi
done
if [[ -h "$HOME/.claude/hooks" ]]; then
  echo "$HOME/.claude/hooks exists already, skipping"
else
  echo "Will run: ln -s $pwd/claude/hooks $HOME/.claude/hooks"
  ln -s "$pwd/claude/hooks" "$HOME/.claude/hooks"
fi

# Automattic stuff
#
# pecl is a PHP extensions manager, xdebug is "an extension of PHP to assist
# with debugging and development"
pecl install xdebug
