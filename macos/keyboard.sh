#!/usr/bin/env bash

set -euo pipefail

# Hold a key to repeat it instead of popping the accent picker, so j/k/h/l
# autorepeat in Vim and code editors.
defaults write -g ApplePressAndHoldEnabled -bool false

defaults write -g KeyRepeat -int 2
defaults write -g InitialKeyRepeat -int 15

# Full keyboard access: Tab moves between every control in a dialog, not
# just text fields and lists.
defaults write -g AppleKeyboardUIMode -int 3

# Disable smart-text substitutions so macOS stops mangling code & Markdown
# with curly quotes, em dashes, autocapitalization, and the like.
defaults write -g NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write -g NSAutomaticDashSubstitutionEnabled -bool false
defaults write -g NSAutomaticCapitalizationEnabled -bool false
defaults write -g NSAutomaticPeriodSubstitutionEnabled -bool false
defaults write -g NSAutomaticSpellingCorrectionEnabled -bool false
