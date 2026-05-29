#!/usr/bin/env bash

set -euo pipefail

# Apps to open at login. Names match the .app bundle and the login-item label.
login_apps=(
  Dropbox
  Gitify
  RescueTime
  "Alfred 5"
  BetterDisplay
  Hammerspoon
  Flux
)

find_app() {
  local name=$1 dir
  for dir in /Applications "$HOME/Applications" /System/Applications; do
    if [[ -d "$dir/$name.app" ]]; then
      printf '%s\n' "$dir/$name.app"
      return 0
    fi
  done
  return 1
}

# Adding a login item needs Automation permission to control System Events;
# the first run prompts for it. Apps not installed are skipped so a missing
# cask doesn't abort the run, and existing items are left as-is (additive).
for name in "${login_apps[@]}"; do
  if ! path=$(find_app "$name"); then
    printf 'Skipping %s — not installed.\n' "$name"
    continue
  fi
  if [[ "$(osascript -e "tell application \"System Events\" to exists login item \"$name\"")" == true ]]; then
    continue
  fi
  # hidden:true is best-effort: macOS 13+ ignores it for login items (the
  # per-item Hide toggle was removed), but it is harmless and honored on
  # older systems.
  osascript -e "tell application \"System Events\" to make login item at end with properties {path:\"$path\", hidden:true}" >/dev/null
  printf 'Added %s to login items.\n' "$name"
done
