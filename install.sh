#!/bin/bash

# Inspired by
# https://github.com/Homebrew/install/blob/750f6bd7d9ce63d9b47a5f3930d9408577c1c9ce/install.sh

set -eu

UNAME_MACHINE="$(uname -m)"
if [[ "$UNAME_MACHINE" == "arm64" ]]; then
  # On ARM macOS, Homebrew goes in /opt/homebrew
  HOMEBREW_PREFIX="/opt/homebrew"
else
  # On Intel macOS, Homebrew goes in /usr/local
  HOMEBREW_PREFIX="/usr/local"
fi

# TODO: it would be nice to check for Xcode and/or its command line tools

# Setup Homebrew
HOMEBREW_BIN=$HOMEBREW_PREFIX/bin/brew
if [[ -f $HOMEBREW_BIN ]]&> /dev/null; then
  brew update
else
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Export Homebrew to the PATH so it's available to the setup script
export PATH = $PATH:$HOMEBREW_BIN

pushd ~

# Get the dotfiles repo
yes | git clone git@github.com:mokagio/dotfiles.git ~/.dotfiles
cd ~/.dotfiles

# Run the setup script
./setup.sh

echo "✅ Basic setup done."
echo "Next steps for you:"
echo ""
echo "- Open and configure Dropbox, as it contains the config folders for other apps"
echo "- Open Vim and run :PlugInstall"
echo "- Open and configure 1Password"
echo ""
echo ""
echo "Checkout the README for extra info and troubleshooting: https://github.com/mokagio/dotfiles#dotfiles"

popd
