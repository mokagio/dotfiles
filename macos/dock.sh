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

# Dock folder stacks (persistent-others). Writing the array replaces every
# stack, so list each one we want. The Trash is a built-in Dock element, not
# part of this array, so it stays put. The GUID and bookmark blob macOS adds
# per tile are regenerated from _CFURLString on reload, so we omit them.
dock_stack() { # path arrangement displayas showas
  cat <<PLIST
<dict>
  <key>tile-data</key><dict>
    <key>file-data</key><dict>
      <key>_CFURLString</key><string>file://$1</string>
      <key>_CFURLStringType</key><integer>15</integer>
    </dict>
    <key>file-type</key><integer>2</integer>
    <key>arrangement</key><integer>$2</integer>
    <key>displayas</key><integer>$3</integer>
    <key>showas</key><integer>$4</integer>
  </dict>
  <key>tile-type</key><string>directory-tile</string>
</dict>
PLIST
}

# A stack pointing at a missing folder renders broken, and this can run
# before screenshots.sh has created ~/Pictures/Screenshots, so ensure the
# targets exist first.
mkdir -p "$HOME/Downloads" "$HOME/Pictures/Screenshots"

# arrangement=2 (Date Added), displayas=0 (Stack), showas=1 (Fan).
defaults write com.apple.dock persistent-others -array \
  "$(dock_stack "$HOME/Downloads/" 2 0 1)" \
  "$(dock_stack "$HOME/Pictures/Screenshots/" 2 0 1)"

# Reload so the changes take effect immediately.
killall Dock
