#
# This Brewfile contains only the *must have* programs and apps. Everything
# that isn't a must is commented, so you can remember about it, but don't have
# to spend time installing it.
#

# The shell of choice. This is actually the default in macOS 10.15, but it
# doesn't hurt dto install it with Homebrew, does it?
brew 'zsh'
# Zsh package manager
brew 'antigen'
brew 'git'
# ruby version manager
brew 'rbenv'
brew 'ruby-build'
brew 'vim'
brew 'node' # Is this necessary when using nvm?
brew 'yarn'
brew 'python'
brew 'shellcheck'
# to jump between folders without going through the filesystem hierarchy
brew 'autojump'
brew 'lua'
# hub is a tool to work with GitHub from the command line
brew 'hub'
# this is actually called via `gh` and is _another_ tool to work with GitHub
# from the command line
brew 'github/gh/gh'
# EditorConfig is a tool to keep coding styles consistent across IDEs
brew 'editorconfig'
# send user notifcations from the terminal
brew 'terminal-notifier'
# xcodebuild autocompletions
brew 'keith/formulae/zsh-xcode-completions'
# Git Large File System support
brew 'git-lfs'
# better cat
brew 'bat'
# GPG to sign stuff (required for Automattic, but just cool in general, e.g.
# GitHub shows "Verified") and PIN entry to make unlocking easier
brew 'pinentry-mac'
brew 'gpg'
# Tool that takes any text as input and interactively fuzzy search through it
brew 'fzf'
# Another search tool, but optimized for searching through code fast
brew 'the_silver_searcher'
# Yet another fast search tool
brew 'ripgrep'
# Handy tool to repeat a command every n seconds
brew 'watch'
# Internet file retriever
brew 'wget'
# RAR archiver (`rar`) and unarchiver (`unrar`)
brew 'rar'
# macOS doesn't have a built-in version of `tree`
brew 'tree'
# Mint is an installer for tools distributed via SPM
brew 'mint'

# Stuff I need for Automattic
brew 'php'
brew 'composer'
brew 'git-crypt'
# This containts GNU core utilities, among which there's realpath whic is used
# in some pre-commit hooks
brew 'coreutils'
# Like sed, but for JSON
brew 'jq'
brew 'imagemagick'
# Tool to manage and create Android App Bundles
brew 'bundletool'
# Sentry is a mobile monitoring tool
brew 'getsentry/tools/sentry-cli'
cask 'android-studio'
cask 'zoom'
# "The simplest way to keep notes"
cask 'simplenote'
# Some simple or demo apps run on Heroku
tap 'heroku/brew'
brew 'heroku'
brew 'awscli'
# Unfortunately, this is a must have as an app, because "Cmd ." doesn't work in
# the browser
cask 'slack'

# Apps

# a Terminal.app replacement
cask 'iterm2'
cask 'google-chrome'
# a Spotlight replacement, plus many automation features
cask 'alfred'
# Window manager configurable via a script
cask 'hammerspoon'
# change the screen temperature according to the time of the day
cask 'flux'
# GTD task manager
cask 'omnifocus'
cask 'dropbox'
cask 'spotify'
# Listen to podcats like a pro
cask 'pocket-casts'
cask 'vlc'
# For those rare occasions when Vim won't do it
cask 'visual-studio-code'
# Tool to remap keys in the macOS keyboard
cask 'karabiner-elements'
# IM clients
cask 'signal'

brew 'mas'
mas 'Spark', id: 1176895641
# mas '1Password', id: 1333542190 –This will install the legacy v7. Where's v8?
mas 'Tadam', id: 531349534
mas 'Toggl', id: 957734279
# Not the sleekies GIF recorder, but has great features such as text annotation
# and export to MP4
mas 'GIF Brewery 3 by Gfycat', id: 1081413713

# Quick Look Plugins

cask 'qlcolorcode'
# view plain text files without a file extension
cask 'qlstephen'
cask 'qlmarkdown'
cask 'quicklook-json'
# view .ipa and .mobileprovision files
cask 'provisionql'

# Calling this last because it asks for the password
# background app that tracks how you spend your time on the computer
cask 'rescuetime'

#
# Stuff beneath here is handy, but not a must have right out the bat. Good to
# remember, thought.
#

#brew 'go'
# imagemagick needs ghostscript to convert pdfs
#brew 'ghostscript'
# ffmpeg is a CLI tool for video editing
#brew 'ffmpeg'
# the Clojure dependency manager and build automation tool
#brew 'leiningen'
# some lldb functions to help debugging from the Xcode console
#brew 'chisel'
#cask 'skype'
# IDE to replace Xcode, with powerful refactoring tools
#cask 'appcode'
# an app that inspects Xcode's projects and highlights issues and possible optimizations
#cask 'fauxpas'
# offline documentation browser
#cask 'dash'
# tool to remap keys, I use it to map Caps Lock to Delete, in Colemak style
#cask 'seil'
# Nintendo 64 emulator
#cask 'sixtyforce'
#cask 'java'
