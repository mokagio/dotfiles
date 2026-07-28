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

# Pin spelling & grammar to US English. "Automatic by Language" detection
# falls back to the first AppleLanguages entry (en-AU) on short text, so it's
# not enough to set the preferred language — automatic must also be off.
# Takes effect after a logout/login; the text-input daemon caches these.
defaults write -g NSPreferredSpellServerLanguage -string "en"
defaults write -g NSSpellCheckerAutomaticLanguageIdentificationEnabled -bool false
defaults write -g KB_SpellingLanguage '{ "KB_SpellingLanguageIsAutomatic" = 0; "KB_SpellingLanguage" = "en"; }'
