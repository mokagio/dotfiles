#!/usr/bin/env bash

set -euo pipefail

# Don't reopen an app's previous windows when it relaunches.
defaults write NSGlobalDomain NSQuitAlwaysKeepsWindows -bool false

# Expand the Save and Print panels to their detailed view by default. The
# unsuffixed and "2" keys cover apps built against different AppKit versions.
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true
