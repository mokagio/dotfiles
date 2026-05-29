#!/usr/bin/env bash

set -euo pipefail

# Show hidden files and all file extensions.
defaults write com.apple.finder AppleShowAllFiles -bool true
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true

# clmv = column view.
defaults write com.apple.finder FXPreferredViewStyle -string clmv

# Group folders above files when sorting, in windows and on the Desktop.
defaults write com.apple.finder _FXSortFoldersFirst -bool true
defaults write com.apple.finder _FXSortFoldersFirstOnDesktop -bool true

# SCcf = search the current folder, not the whole Mac.
defaults write com.apple.finder FXDefaultSearchScope -string SCcf

defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# Keep .DS_Store files off network and USB volumes.
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# Unhide ~/Library.
chflags nohidden "$HOME/Library"

# Reload so the changes take effect immediately.
killall Finder
