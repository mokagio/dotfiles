# zshenv is always sourced, so it's useful for variables that should be
# available to other programs, like $PATH or $EDITOR.
#
# More info here:
# https://unix.stackexchange.com/questions/71253/what-should-shouldnt-go-in-zshenv-zshrc-zlogin-zprofile-zlogout
#
# Some of the settings here are based on the .zshenv from the prezto project:
# https://github.com/sorin-ionescu/prezto

#
# Browser
#

if [[ "$OSTYPE" == darwin* ]]; then
  export BROWSER='open'
fi

#
# Editors
#

export EDITOR='nvim'
export VISUAL='nvim'
export PAGER='less'

#
# Language
#

if [[ -z "$LANG" ]]; then
  export LANG='en_US.UTF-8'
fi

#
# Paths
#

# Ensure path arrays do not contain duplicates.
typeset -gU cdpath fpath mailpath path

# Set the the list of directories that cd searches.
# cdpath=(
#   $cdpath
# )

# Set the list of directories that Zsh searches for programs.
# mise shims go first so managed tools (ruby, node, etc.) win over
# system copies in /usr/local/bin.
# `~/.local/bin` is where the Claude Code native installer puts its
# binary; keep it on PATH so `claude` is findable from any shell.
path=(
  $HOME/.local/share/mise/shims
  $HOME/.local/bin
  /usr/local/{bin,sbin}
  $path
)

#
# Less
#

# Set the default Less options.
# Mouse-wheel scrolling has been disabled by -X (disable screen clearing).
# Remove -X and -F (exit if the content fits on one screen) to enable it.
export LESS='-F -g -i -M -R -S -w -X -z-4'

# Set the Less input preprocessor.
# Try both `lesspipe` and `lesspipe.sh` as either might exist on a system.
if (( $#commands[(i)lesspipe(|.sh)] )); then
  export LESSOPEN="| /usr/bin/env $commands[(i)lesspipe(|.sh)] %s 2>&-"
fi

#
# Temporary Files
#

if [[ ! -d "$TMPDIR" ]]; then
  export TMPDIR="/tmp/$LOGNAME"
  mkdir -p -m 700 "$TMPDIR"
fi

TMPPREFIX="${TMPDIR%/}/zsh"

#
# mokagio
#

# Android dev stuff
#
export ANDROID_HOME=~/Library/Android/sdk
# Gradle 8.13 refuses to run on JDK 24+, and Android Studio's bundled JBR is
# on 25. Falls back to the JBR so a machine without Temurin still gets a JDK.
# Drop this once the Android projects are on Gradle 9.1+, which runs on 25.
JAVA_21_HOME=$(/usr/libexec/java_home -v 21 2>/dev/null)
if [[ -n "$JAVA_21_HOME" ]]; then
  export JAVA_HOME="$JAVA_21_HOME"
else
  export JAVA_HOME="/Applications/Android Studio.app/Contents/jbr/Contents/Home"
fi
unset JAVA_21_HOME
# Add the platform-tools to the PATH to call them easily. Also, Fastlane looks
# for them in PATH, it doesn't look in $ANDROID_HOME
export PATH="$PATH:$ANDROID_HOME/platform-tools/"
export PATH="$PATH:$ANDROID_HOME/emulator/"
ANDROID_CMDLINE_TOOLS_PATH="$ANDROID_HOME/cmdline-tools/latest/bin/"
if [[ -d "$ANDROID_CMDLINE_TOOLS_PATH" ]]; then
  export PATH="$PATH:$ANDROID_CMDLINE_TOOLS_PATH" # avdmanager is located here
else
  echo "\033[1;31mCannot find Android command line tools at $ANDROID_CMDLINE_TOOLS_PATH. They can be installed via Android Studio.\033[0m"
fi

# PHP / Composer / Valet
export PATH="$PATH:$HOME/.composer/vendor/bin"

# Get rid of Fastlane noise
export FASTLANE_SKIP_UPDATE_CHECK=1
export FASTLANE_HIDE_CHANGELOG=1
export FASTLANE_HIDE_PLUGINS_TABLE=1
export FASTLANE_SKIP_ACTION_SUMMARY=1

# Mint is an installer for tools distributed via SPM
# https://github.com/yonaskolb/Mint
export PATH="$PATH:$HOME/.mint/bin"

# Exported so subprocesses see it — notably Vim, whose rc does
# `source $DOTFILES_HOME/...`. Without export it resolves empty there.
export DOTFILES_HOME="$HOME/.dotfiles"

export PATH="$PATH:$DOTFILES_HOME/scripts"

# Cloud66 Toolbelt (`cx`)
export PATH="$PATH:/opt/cloud66/bin"

# Cargo is Rust's dependency manager and library builder
[[ -f "$HOME/.cargo/env" ]] && . "$HOME/.cargo/env"

# Automattic stuff
# See
# https://github.com/wordpress-mobile/release-toolkit/blob/984a1854b42641daf43b29aa7ae36d0961be8f59/lib/fastlane/plugin/wpmreleasetoolkit/helper/interactive_prompt_reminder.rb#L10-L18
export FASTLANE_PROMPT_REMINDER_MESSAGE=1
export PATH="$PATH:/opt/ci/bin"

# Stop Homebrew from auto-updating because it is often inconvenient.
# In zshenv so non-interactive calls (Makefiles, scripts) also skip it.
export HOMEBREW_NO_AUTO_UPDATE=1

# gh-dash config lives in dotfiles instead of ~/.config/gh-dash/
export GH_DASH_CONFIG="$DOTFILES_HOME/gh-dash.yml"

# In zshenv, not zshrc, so scripts and cron jobs get the wrapper too.
source "$DOTFILES_HOME/zsh/functions/claude.zsh"

# Machine-local overrides (not tracked in dotfiles)
LOCAL_ZSHENV="${HOME}/.zshenv.local"
[[ -f "$LOCAL_ZSHENV" ]] && source "$LOCAL_ZSHENV"
