# Defines environment variables.
# Based on the .zshenv from the prezto project: https://github.com/sorin-ionescu/prezto

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

# Put personal scripts here
PATH=$PATH:$HOME/bin

# Android dev stuff
export ANDROID_HOME=~/Library/Android/sdk
export ANDROID_SDK_ROOT=$ANDROID_HOME
# Notice how this depends on Android Studio. So far, it seems the best way
# to make sure I have consistent Gradle behaviour between the IDE and the CLI
export JAVA_HOME="/Applications/Android Studio.app/Contents/jre/jdk/Contents/Home"
# Add the platform-tools to the PATH to call them easily. Also, Fastlane looks
# for them in PATH, it doesn't look in ANDROID_HOME
export PATH="$PATH:$ANDROID_HOME/platform-tools/"
export PATH="$PATH:$ANDROID_HOME/emulator/"

# PHP / Composer / Valet
export PATH="$PATH:$HOME/.composer/vendor/bin"

# Edit this line locally (but don't track the change) if the path is different
# from the one here.
# TODO: It'd be good to have a zshenv.local or something to decouple this.
DOTFILES_HOME=~/dotfiles/

GPG_TTY=$(tty)
