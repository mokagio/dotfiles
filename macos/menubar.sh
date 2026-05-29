#!/usr/bin/env bash

set -euo pipefail

# Menu bar clock: digital, day of week + AM/PM, no date.
defaults write com.apple.menuextra.clock IsAnalog -bool false
defaults write com.apple.menuextra.clock ShowDate -int 0
defaults write com.apple.menuextra.clock ShowDayOfWeek -bool true
defaults write com.apple.menuextra.clock ShowAMPM -bool true
defaults write com.apple.menuextra.clock FlashDateSeparators -bool false

# Hide the input-source (keyboard layout) picker from the menu bar.
defaults write com.apple.TextInputMenu visible -bool false

# The menu bar is drawn by these two; restart so the changes apply. On recent
# macOS some menu bar items only fully settle after a re-login.
killall SystemUIServer
killall ControlCenter
