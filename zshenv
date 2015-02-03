# Defines environment variables.
# Based on the .zshenv from the prezto project: https://github.com/sorin-ionescu/prezto

# Browser
if [[ "$OSTYPE" == darwin* ]]; then
  export BROWSER='open' 
fi

# Editors
export EDITOR='vim'
export VISUAL='vim'
export PAGER='less'

# Language
if [[ -z "$LANG" ]]; then
  export LANG='en_US.UTF-8'
fi

# Paths
typeset -gU cdpath fpath mailpath path

# Set the list of directories that Zsh searches for programs.
path=(
  /usr/local/{bin,sbin}
  $path
)

# Set the default Less options.
# Mouse-wheel scrolling has been disabled by -X (disable screen clearing).
# Remove -X and -F (exit if the content fits on one screen) to enable it.
export LESS='-F -g -i -M -R -S -w -X -z-4'

# Set the Less input preprocessor.
if (( $+commands[lesspipe.sh] )); then
  export LESSOPEN='| /usr/bin/env lesspipe.sh %s 2>&-'
fi

# Temporary Files
if [[ -d "$TMPDIR" ]]; then
  export TMPPREFIX="${TMPDIR%/}/zsh"
  if [[ ! -d "$TMPPREFIX" ]]; then
    mkdir -p "$TMPPREFIX"
  fi
fi

## mokagio ##

# rbenv
PATH=$HOME/.rbenv/bin:$PATH
eval "$(rbenv init -)"
# npm
PATH=$PATH:/usr/local/share/npm/bin
# personal scripts
PATH=$PATH:$HOME/Scripts
# Postgres.app bins
PATH=$PATH:/Applications/Postgres.app/Contents/MacOS/bin
# OCLint
PATH=$PATH:$HOME/Executables/oclint/bin

export RBENV_VERSION="2.1.3"
