#!/usr/bin/env bash

set -euo pipefail

screenshots_dir="$HOME/Pictures/Screenshots"
mkdir -p "$screenshots_dir"

# Route screen captures here instead of the Desktop.
defaults write com.apple.screencapture location -string "$screenshots_dir"
# Reload the capture service so the new location takes effect.
killall SystemUIServer

# macOS only auto-assigns special icons to known folders (Downloads,
# Applications, …), so give the screenshots folder the system Screenshot
# app's icon ourselves. swift is guaranteed by setup.sh's Xcode CLT requirement.
icon="/System/Applications/Utilities/Screenshot.app/Contents/Resources/AppIcon.icns"
if [[ -f "$icon" ]]; then
  swift - "$icon" "$screenshots_dir" <<'SWIFT'
import Cocoa
guard let img = NSImage(byReferencingFile: CommandLine.arguments[1]) else { exit(1) }
NSWorkspace.shared.setIcon(img, forFile: CommandLine.arguments[2], options: [])
SWIFT
fi
