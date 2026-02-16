#!/usr/bin/env bash

set -eu

# Symlink $1 to $2 if $2 doesn't already exist
link() {
  if [[ -h "$2" ]]; then
    echo "$2 exists already, skipping"
  else
    echo "Will run: ln -s $1 $2"
    ln -s "$1" "$2"
  fi
}

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
  'vimrc.zettelkasten'
  'vimrc.plugs'
  'xvimrc'
  'zshrc'
  'zshenv'
  'zshprompt'
)

pwd="$(cd "$(dirname "$0")" && pwd)"

for dot in "${dotfiles[@]}"
do
  destination="$HOME/.$dot"

  link "$pwd/$dot" "$destination"
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
  link "$vim_spell_path" "$destination"
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
  link "$neovim_init" "$destination"
else
  echo "Could not find $neovim_init! Aborting."
  exit 1
fi

if ! brew bundle; then
  printf "\033[1;31mbrew bundle finished with errors. Some formulae may not have installed.\033[0m\n"
  printf "\033[1;31mRun 'brew bundle' manually to retry.\033[0m\n"
fi
# Some of the tools installed via Homebrew might need additional manual steps.
#
# Install fzf useful keybindings and fuzzy completion for ZSH
if [[ ! -f ~/.fzf.zsh ]] && command -v brew &>/dev/null; then
  fzf_install="$(brew --prefix)/opt/fzf/install"
  if [[ -f "$fzf_install" ]]; then
    "$fzf_install"
  fi
fi
# Bypass gatekeeper for QLColorCode
# https://github.com/anthonygelibert/QLColorCode/issues/84
qlcolorcode_path="$HOME/Library/QuickLook/QLColorCode.qlgenerator"
if [[ -d "$qlcolorcode_path" ]]; then
  xattr -cr "$qlcolorcode_path"
fi

# Install latest Node via fnm (installed via Brewfile)
if command -v fnm &>/dev/null; then
  eval "$(fnm env)"
  fnm install --lts
  echo "Node $(node --version) installed via fnm"
else
  printf "\033[1;31mfnm not found, skipping Node setup.\033[0m\n"
fi

# Install Vim-Plug to manage Vim plugins
# See https://github.com/junegunn/vim-plug/tree/c3b6b7c2971da730d66f6955d5c467db8dae536b#vim
plug_url="https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
vim_plug_path="$HOME/.vim/autoload/plug.vim"
if [[ -f "$vim_plug_path" ]]; then
  echo "Looks like you already have Vim-Plug installed for Vim, skipping"
else
  curl -fLo "$vim_plug_path" --create-dirs "$plug_url"
fi
nvim_plug_path="$HOME/.local/share/nvim/site/autoload/plug.vim"
if [[ -f "$nvim_plug_path" ]]; then
  echo "Looks like you already have Vim-Plug installed for Neovim, skipping"
else
  curl -fLo "$nvim_plug_path" --create-dirs "$plug_url"
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
link "$pwd/hammerspoon_init.lua" "$HOME/.hammerspoon/init.lua"

# Powerline fonts
if ls "$HOME/Library/Fonts/"*owerline* &>/dev/null; then
  echo "Powerline fonts already installed, skipping"
else
  echo "Installing Powerline fonts..."
  powerline_tmp=$(mktemp -d)
  git clone https://github.com/powerline/fonts.git --depth=1 "$powerline_tmp"
  echo "Running Powerline font installer..."
  "$powerline_tmp/install.sh"
  rm -rf "$powerline_tmp"
  echo "Powerline fonts installed"
fi

# Claude Code
mkdir -p ~/.claude
for f in claude/settings.json claude/CLAUDE.md claude/statusline.sh; do
  link "$pwd/$f" "$HOME/.${f}"
done
# AGENTS.md at XDG-standard location, included via @~/.config/agents/AGENTS.md
mkdir -p ~/.config/agents
link "$pwd/agents/AGENTS.md" "$HOME/.config/agents/AGENTS.md"
link "$pwd/claude/hooks" "$HOME/.claude/hooks"

# Automattic stuff
#
# pecl is a PHP extensions manager, xdebug is "an extension of PHP to assist
# with debugging and development"
if ! pecl install xdebug > /dev/null 2>&1; then
  printf "\033[1;31mpecl install xdebug failed. Run it manually to retry.\033[0m\n"
fi
