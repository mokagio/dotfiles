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

export EDITOR='vim'
export VISUAL='vim'
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
path=(
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

PATH=$PATH:/usr/local/share/npm/bin

# Android dev stuff
#
export ANDROID_HOME=~/Library/Android/sdk
# Notice how this depends on Android Studio. So far, it seems the best way
# to make sure I have consistent Gradle behaviour between the IDE and the CLI
#
# See also: https://stackoverflow.com/a/43237101/809944
#
# Was jre before, but became jbr with Android Studio Giraffe
export JAVA_HOME="/Applications/Android Studio.app/Contents/jbr/Contents/Home"
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

export GPG_TTY=$(tty)

# Get rid of Fastlane noise
export FASTLANE_SKIP_UPDATE_CHECK=1
export FASTLANE_HIDE_CHANGELOG=1
export FASTLANE_HIDE_PLUGINS_TABLE=1
export FASTLANE_SKIP_ACTION_SUMMARY=1
# This is useful only if your work in the Automattic Mobile Platform team ^-^'
#
# See
# https://github.com/wordpress-mobile/release-toolkit/blob/984a1854b42641daf43b29aa7ae36d0961be8f59/lib/fastlane/plugin/wpmreleasetoolkit/helper/interactive_prompt_reminder.rb#L10-L18
export FASTLANE_PROMPT_REMINDER_MESSAGE=1

# Mint is an installer for tools distributed via SPM
# https://github.com/yonaskolb/Mint
export PATH="$PATH:$HOME/.mint/bin"

# Edit this line locally (but don't track the change) if the path is different
# from the one here.
# TODO: It'd be good to have a zshenv.local or something to decouple this.
DOTFILES_HOME="$HOME/.dotfiles"

export PATH="$PATH:$DOTFILES_HOME/scripts"

# Cloud66 Toolbelt (`cx`)
export PATH="$PATH:/opt/cloud66/bin"
