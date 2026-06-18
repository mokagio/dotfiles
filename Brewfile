#
# This Brewfile contains only the *must have* programs and apps.
# Everything that isn't a must is commented, so you can
# remember about it, but don't have to spend time
# installing it.
#

# The shell of choice. This is actually the default in macOS 10.15, but it
# doesn't hurt to install it with Homebrew, does it?
brew 'zsh'
# Zsh plugins (direct sourcing)
brew 'zsh-syntax-highlighting'
brew 'zsh-autosuggestions'
brew 'zsh-completions'
# Shell tools
#
# Custom promt
brew 'starship'
# Fast folder jump - Replaces autojump
brew 'zoxide'
# Polyglot version manager — manages Ruby, Node, and other runtimes
brew 'mise'
brew 'git'
brew 'vim'
brew 'neovim'
brew 'yarn'
brew 'python'
brew 'bash-language-server'
brew 'shellcheck'
# Bash test framework
brew 'bats-core'
brew 'lua'
# GitHub CLI
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
# Takes any text as input and interactively fuzzy search through it
brew 'fzf'
# Fast search tool optimized for searching through code
brew 'ripgrep'
# Handy tool to repeat a command every n seconds
brew 'watch'
# Internet file retriever
brew 'wget'
# Extract RAR (and many other) archives
#
# Once upon a time, there was a `rar` formula, but it's no longer available.
# Anyway one rarely needs do archive in RAR these days.
brew 'unar'
# Modern ls replacement with git awareness, tree view, icons
brew 'eza'
# Syntax-highlighted pager for git diffs
brew 'git-delta'
# Fast find alternative, respects .gitignore
brew 'fd'
# macOS doesn't have a built-in version of `tree`
brew 'tree'
# Mint is an installer for tools distributed via SPM
brew 'mint'
# Git visualizer useful to look through diffs
brew 'tig'
# This containts GNU core utilities, among which there's realpath whic is used
# in some pre-commit hooks
brew 'coreutils'
# Like sed, but for JSON
brew 'jq'
brew 'imagemagick'
# Tool to manage and create Android App Bundles
brew 'bundletool'
brew 'awscli'
cask 'android-studio'

# Stuff I need for Automattic
brew 'php'
brew 'composer'
brew 'git-crypt'
# Sentry is a mobile monitoring tool
brew 'getsentry/tools/sentry-cli'
# Unfortunately, this is a must have as an app, because "Cmd ." doesn't work in
# the browser
cask 'slack'

# Apps

# a Terminal.app replacement
cask 'iterm2'
cask 'google-chrome'
# Privacy-focused web browser
cask 'duckduckgo'
# a Spotlight replacement, plus many automation features
cask 'alfred'
# Password manager — the README install steps reference opening
# 1Password right after `setup.sh`, so it needs to actually be there.
cask '1password'
# Window manager configurable via a script
cask 'hammerspoon'
# change the screen temperature according to the time of the day
cask 'flux-app'
cask 'dropbox'
cask 'spotify'
cask 'vlc'
# For those rare occasions when Vim won't do it
cask 'visual-studio-code'
# Tool to remap keys in the macOS keyboard
cask 'karabiner-elements'

brew 'mas'
mas 'Tadam', id: 531349534

# Quick Look Plugins

cask 'qlcolorcode'
# view plain text files without a file extension
cask 'qlstephen'
cask 'qlmarkdown'
# view .ipa and .mobileprovision files
cask 'provisionql'

# VS Code extensions
vscode 'dbaeumer.vscode-eslint'
vscode 'dotjoshjohnson.xml'
vscode 'eamodio.gitlens'
vscode 'editorconfig.editorconfig'
vscode 'esbenp.prettier-vscode'
vscode 'gcazaciuc.vscode-flow-ide'
vscode 'github.copilot'
vscode 'github.copilot-chat'
vscode 'github.vscode-pull-request-github'
vscode 'grapecity.gc-excelviewer'
vscode 'hashicorp.terraform'
vscode 'ivandemchenko.roc-lang-unofficial'
vscode 'jetmartin.bats'
vscode 'mechatroner.rainbow-csv'
vscode 'mhcpnl.xcodestrings'
vscode 'misogi.ruby-rubocop'
vscode 'ms-azuretools.vscode-containers'
vscode 'ms-azuretools.vscode-docker'
vscode 'ms-playwright.playwright'
vscode 'ms-vscode-remote.remote-containers'
vscode 'ms-vscode-remote.remote-ssh'
vscode 'ms-vscode-remote.remote-ssh-edit'
vscode 'ms-vscode.cmake-tools'
vscode 'ms-vscode.cpp-devtools'
vscode 'ms-vscode.cpptools'
vscode 'ms-vscode.cpptools-extension-pack'
vscode 'ms-vscode.cpptools-themes'
vscode 'ms-vscode.makefile-tools'
vscode 'ms-vscode.powershell'
vscode 'ms-vscode.remote-explorer'
vscode 'msjsdiag.vscode-react-native'
vscode 'orta.vscode-jest'
vscode 'redhat.vscode-xml'
vscode 'redhat.vscode-yaml'
vscode 'shopify.ruby-lsp'
vscode 'sswg.swift-lang'
vscode 'thadeu.vscode-run-rspec-file'
vscode 'twxs.cmake'
vscode 'vadimcn.vscode-lldb'
vscode 'vknabel.swift-coverage'
vscode 'vknabel.vscode-apple-swift-format'
vscode 'vknabel.vscode-swiftlint'
vscode 'vscodevim.vim'

# Additional casks
cask 'discord'                  # Voice/text chat for communities
cask 'whatsapp'                 # WhatsApp messaging desktop app
cask 'obs'                      # Screen recording and live streaming
cask 'keycastr'                 # On-screen keystroke visualizer for demos/screencasts
cask 'db-browser-for-sqlite'    # GUI to create/edit SQLite databases
cask 'calibre'                  # E-book library manager and converter
cask 'anki'                     # Spaced-repetition flashcards
cask 'transmission'             # Lightweight BitTorrent client
cask 'gimp'                     # Open-source raster image editor
cask 'sigil'                    # EPUB e-book editor
cask 'quicklook-json'           # Quick Look plugin to preview JSON files
cask 'font-open-sans'           # Open Sans font family
cask 'font-fira-code-nerd-font' # iTerm/neovim terminal font with Nerd Font icons
cask 'parallels-virtualization-sdk'  # SDK for scripting Parallels VMs
cask 'claude'                   # Anthropic's official Claude desktop app
cask 'chatgpt'                  # OpenAI's official ChatGPT desktop app
cask 'linear-linear'            # Linear's official issue-tracking desktop app

# Additional App Store apps
mas 'Spark', id: 1176895641           # Email client
mas 'Vimari', id: 1480933944          # Vim-style keyboard navigation for Safari
mas 'Numbers', id: 409203825          # Apple spreadsheets
mas 'Pages', id: 409201541            # Apple word processor
mas 'Keynote', id: 409183694          # Apple presentations
mas 'TestFlight', id: 899247664       # Apple beta-app testing
mas 'iMovie', id: 408981434           # Video editing
mas 'GIF Brewery 3', id: 1081413713   # Convert video clips to GIFs
mas 'Simple Comic', id: 1497435571    # Comic-book (CBR/CBZ) reader
mas 'Messenger', id: 1480068668       # Facebook Messenger
mas 'Kindle', id: 302584613           # Amazon e-book reader
mas 'Kindle Classic', id: 405399194   # Old Kindle
mas 'Piano', id: 6738069680           # Piano app
mas 'Simple ZXCV Piano', id: 6743351038  # Piano app
mas 'Teleprompter', id: 1420515755    # Teleprompter
mas 'Virtual Teleprompter Lite', id: 1598483936  # Teleprompter (lite)
mas 'Developer', id: 640199958        # Apple Developer app
mas '1Password for Safari', id: 1569813296  # 1Password Safari extension

# Additional CLI tools (formulae)
# iOS / Swift toolchain
brew 'swiftlint'                          # Swift linter
brew 'swiftformat'                        # SwiftFormat (Nick Lockwood)
brew 'swift-format'                       # apple/swift-format
brew 'swift-protobuf'                     # Protocol Buffers for Swift
brew 'swift-sh'                           # Run Swift scripts with dependencies
brew 'xcbeautify'                         # Prettify xcodebuild output
brew 'xclogparser'                        # Parse Xcode build logs
brew 'xcodegen'                           # Generate .xcodeproj from a spec
brew 'xcodesorg/made/xcodes'              # Install/switch multiple Xcode versions
brew 'chargepoint/xcparse/xcparse'        # Extract data/attachments from .xcresult
brew 'ios-deploy'                         # Install/debug iOS apps from the CLI
brew 'periphery'                          # Detect unused Swift code
brew 'carthage'                           # Swift/ObjC dependency manager
# General dev
brew 'gh'                                 # GitHub CLI
brew 'go'                                 # Go language
brew 'rust'                               # Rust language (cargo for fallback builds, e.g. vim-tagquery)
brew 'difftastic'                         # Structural (syntax-aware) diff
brew 'git-filter-repo'                    # Rewrite git history
brew 'git-flow'                           # git branching-model helper
brew 'gitleaks'                           # Scan repos for committed secrets
brew 'fnm'                                # Fast Node version manager
brew 'rbenv'                              # Ruby version manager
brew 'hub'                                # Legacy GitHub git wrapper
brew 'the_silver_searcher'                # ag fast code search
brew 'ncdu'                               # TUI disk-usage analyzer
brew 'gnu-sed'                            # GNU sed
brew 'yq'                                 # YAML/JSON processor
brew 'yamllint'                           # YAML linter
brew 'cmake'                              # Cross-platform build-system generator
brew 'create-dmg'                         # Build macOS .dmg installers
brew 'zk'                                 # Zettelkasten note CLI
brew 'watchman'                           # File-watching service (React Native / Jest)
# Infra / containers / cloud
brew 'colima'                             # Container runtime on a Lima VM
brew 'docker'                             # Docker CLI client
brew 'doctl'                              # DigitalOcean CLI
brew 'kubeconform'                        # Validate Kubernetes manifests
brew 'hashicorp/tap/packer'               # Build machine images
brew 'heroku/brew/heroku'                 # Heroku CLI
brew 'ansible'                            # IT automation / config management
brew 'openconnect'                        # VPN client (Cisco/Pulse compatible)
# Media / docs
brew 'pandoc'                             # Universal document converter
brew 'hugo'                               # Static-site generator
brew 'yt-dlp'                             # Media/video downloader
brew 'openai-whisper'                     # Speech-to-text (Whisper) CLI
brew 'aria2'                              # Multi-protocol/multi-source downloader
brew 'qrencode'                           # Generate QR codes
brew 'p7zip'                              # 7-Zip CLI
brew 'mist-cli'                           # Download macOS installers / IPSWs
# Languages / runtimes
brew 'openjdk@17'                         # OpenJDK 17 (Java)
brew 'llvm@16'                            # LLVM toolchain v16
brew 'redis'                              # In-memory data store
brew 'postgresql@14'                      # PostgreSQL 14
brew 'powershell'                         # PowerShell
brew 'perl'                               # Perl
brew 'uv'                                 # Fast Python package manager/installer
brew 'ruff'                               # Python linter/formatter
brew 'nox'                                # Python test automation
brew 'python@3.9'                         # Python 3.9
brew 'python@3.10'                        # Python 3.10
brew 'python@3.11'                        # Python 3.11
# Signing / security
brew 'minisign'                           # Sign/verify files
brew 'osslsigncode'                       # Sign Windows executables
brew 'hudochenkov/sshpass/sshpass'        # Non-interactive ssh password
# Work taps
brew 'automattic/build-tools/drawtext'    # Automattic drawText CLI
brew 'buildkite/buildkite/buildkite-agent' # Buildkite CI agent
brew 'lokalise/cli-2/lokalise2'           # Lokalise localization CLI
# Verify before relying on these taps (may need access on a fresh machine)
brew 'anomalyco/tap/opencode'             # OpenCode AI coding agent CLI
brew 'markmarkoh/lt/lt'                   # unidentified — verify
brew 'rom-tools'                          # retro-ROM tooling — verify
brew 'tumblr/tools/tunguard'              # Tumblr internal tool — verify tap access
brew 'rockymadden/rockymadden/slack-cli'  # Slack CLI
