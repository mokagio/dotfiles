#!/usr/bin/env bash

set -euo pipefail

screenshots_dir="$HOME/Pictures/Screenshots"
mkdir -p "$screenshots_dir"

# Route screen captures here instead of the Desktop.
defaults write com.apple.screencapture location -string "$screenshots_dir"
# Reload the capture service so the new location takes effect.
killall SystemUIServer

# macOS only auto-assigns special icons to known folders (Pictures,
# Downloads, …), so copy the parent Pictures folder's icon onto Screenshots
# so it reads as a Pictures subfolder. swift is guaranteed by setup.sh's
# Xcode CLT requirement.
swift - "$HOME/Pictures" "$screenshots_dir" <<'SWIFT'
import Cocoa
let icon = NSWorkspace.shared.icon(forFile: CommandLine.arguments[1])
NSWorkspace.shared.setIcon(icon, forFile: CommandLine.arguments[2], options: [])
SWIFT
