#!/usr/bin/env bash

set -euo pipefail

# Dock behavior
defaults write com.apple.dock autohide -bool true
# No delay before the Dock slides in on hover.
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock autohide-time-modifier -float 0.4
# No bouncing icon while an app launches.
defaults write com.apple.dock launchanim -bool false
# Keep Spaces in a fixed order.
defaults write com.apple.dock mru-spaces -bool false

# Dock appearance
defaults write com.apple.dock tilesize -int 30
defaults write com.apple.dock magnification -bool false

# Dock contents
defaults write com.apple.dock show-recents -bool false

# Reload so the changes take effect immediately.
killall Dock
