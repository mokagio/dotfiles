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
# arrangement=2 (Date Added), displayas=0 (Stack), showas=1 (Fan).
dock_stack() { # folder
  cat <<PLIST
<dict>
  <key>tile-data</key><dict>
    <key>file-data</key><dict>
      <key>_CFURLString</key><string>file://$1/</string>
      <key>_CFURLStringType</key><integer>15</integer>
    </dict>
    <key>file-type</key><integer>2</integer>
    <key>arrangement</key><integer>2</integer>
    <key>displayas</key><integer>0</integer>
    <key>showas</key><integer>1</integer>
  </dict>
  <key>tile-type</key><string>directory-tile</string>
</dict>
PLIST
}

stack_folders=(
  "$HOME/Downloads"
  "$HOME/Pictures/Screenshots"
)

# A stack pointing at a missing folder renders broken, and this can run
# before screenshots.sh has created ~/Pictures/Screenshots, so ensure the
# targets exist first.
mkdir -p "${stack_folders[@]}"

stack_tiles=()
for folder in "${stack_folders[@]}"; do
  stack_tiles+=("$(dock_stack "$folder")")
done
defaults write com.apple.dock persistent-others -array "${stack_tiles[@]}"

# Disable every hot corner (corner action 1 = no-op, modifier 0 = no key).
for corner in tl tr bl br; do
  defaults write com.apple.dock "wvous-$corner-corner" -int 1
  defaults write com.apple.dock "wvous-$corner-modifier" -int 0
done

# Reload so the changes take effect immediately.
killall Dock
