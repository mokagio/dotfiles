# Executes commands at the start of an interactive session.

# Resolve Homebrew prefix: read from disk cache, or resolve once and cache
_brew_cache="${XDG_CACHE_HOME:-$HOME/.cache}/dotfiles/homebrew_prefix"
if [[ -r "$_brew_cache" ]]; then
  HOMEBREW_PREFIX=$(<"$_brew_cache")
elif command -v brew &>/dev/null; then
  HOMEBREW_PREFIX=$(brew --prefix)
  mkdir -p "${_brew_cache:h}"
  print -n "$HOMEBREW_PREFIX" > "$_brew_cache"
fi
unset _brew_cache
export HOMEBREW_PREFIX

# --- ZSH plugins (direct sourcing) ---
# If startup feels slow, consider migrating to zinit for turbo/lazy-loading.

# Completions from Homebrew (must precede compinit)
if [[ -d "$HOMEBREW_PREFIX/share/zsh-completions" ]]; then
  fpath=("$HOMEBREW_PREFIX/share/zsh-completions" $fpath)
fi

# Case-insensitive tab completion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z} m:=_ m:=- m:=.'

# Colored man pages
source "$DOTFILES_HOME/zsh/plugins/colored-man-pages.plugin.zsh"

# Ctrl-Z toggles between shell and fg (replaces zsh-vim-crtl-z plugin)
fancy-ctrl-z() {
  if [[ $#BUFFER -eq 0 ]]; then
    BUFFER="fg"
    zle accept-line
  else
    zle push-input
    zle clear-screen
  fi
}
zle -N fancy-ctrl-z
bindkey '^Z' fancy-ctrl-z

# Fish-like autosuggestions
if [[ -f "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
  source "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi

# Syntax highlighting (must be last among plugins)
if [[ -f "$HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
  source "$HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi

# Starship prompt (replaces spaceship-prompt)
if command -v starship &>/dev/null; then
  eval "$(starship init zsh)"
fi

# Use vim keybindings
bindkey -v
# Re-enable Ctrl-r to search history (vim keybindning disabled it)
bindkey '^R' history-incremental-search-backward
# When in normal mode, press v to edit the command in the $VISUAL editor
autoload -z edit-command-line
zle -N edit-command-line
bindkey -M vicmd v edit-command-line

# zoxide — smarter cd
if command -v zoxide &>/dev/null; then
  eval "$(zoxide init zsh)"
  alias j=z
fi

# Turn off autocorrect for some commands
# See http://yountlabs.com/blog/2010/11/06/disable-autocorrect-in-zsh/
alias jake='nocorrect jake'
alias leiningen='nocorrect leiningen'

# As reccomended in the bower installer
alias bower='noglob bower'

alias showFiles='defaults write com.apple.finder AppleShowAllFiles YES; killall Finder /System/Library/CoreServices/Finder.app'
alias hideFiles='defaults write com.apple.finder AppleShowAllFiles NO; killall Finder /System/Library/CoreServices/Finder.app'

test -e ${HOME}/.iterm2_shell_integration.zsh && source ${HOME}/.iterm2_shell_integration.zsh

# Convert an input `.md` file to HTML and paste it to the clipboard.
# I use this everytime I work on a newsletter or other text content to paste
# into an HTML editor.
md2html() {
  if [[ -z "$1" ]]; then
    # `printf` will not add a newline at the end of the printed output
    printf "Missing path to .md file to convert to HTML"
    # return something that's not 0 so the consumer knows there's been an
    # error.
    return 1
  fi

  pandoc --from gfm --to html --standalone $1 | pbcopy
}

# Generate a random number between 1 and a given threshold, included
rand() {
  echo $((1 + RANDOM % $1))
}

# Fastlane autocompletion
# https://docs.fastlane.tools/faqs/#enable-tab-auto-complete-for-fastlane-lane-names
fastlane_autocompletion_source=~/.fastlane/completions/completion.sh
if [[ -f $fastlane_autocompletion_source ]]; then
  source ~/.fastlane/completions/completion.sh
else
  echo "❌ Could not find Fastlane autocompletion script"
fi

# Useful keybindings and fuzzy completion for fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Enable Zsh Git tab completions
# This used to be on by default in my pre-antigen prezto setup...
# See also
# https://stackoverflow.com/questions/24513873/git-tab-completion-not-working-in-zsh-on-mac/58517668#58517668
# -u: skip insecure-directory check — Homebrew sets group-write on its share dir
autoload -Uz compinit && compinit -u

# Go
export GOPATH=$HOME/.go
export PATH=$PATH:$GOPATH/bin

# AWS CLI Autocompleter
# https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-completion.html
autoload bashcompinit && bashcompinit
complete -C '/usr/local/bin/aws_completer' aws

# Xcode build autocompletion, via https://github.com/keith/zsh-xcode-completions
fpath=($HOMEBREW_PREFIX/share/zsh/site-functions $fpath)

# Paste content of file to clipboard
pastetoclipboard() {
  cat $1 | pbcopy
}
alias pbc=pastetoclipboard

# Joseph is my automated virtual assitant. A collection of scripts to open
# certain recurring pages at the start and end of the day.
joseph_path=$HOME/.joseph
if [ -d $joseph_path ]; then
  alias joseph=$joseph_path/joseph.rb
else
  echo "\033[1;31mCan't find Joseph at $joseph_path. Please install it.\033[0m"
fi

# If there is a local zshrc, load it.
#
# Always load the local zshrc last (or last but before any setting depending on
# it).
LOCAL_ZSHRC="${HOME}/.zshrc.local"
[ -f "$LOCAL_ZSHRC" ] && source "$LOCAL_ZSHRC"

# Load the aliases after the local zshrc, just in case there are env var
# overrides in it.
for _alias_file in aliases.navigation.sh aliases.git.sh aliases.sh; do
  _alias_path="$DOTFILES_HOME/$_alias_file"
  if [[ -f "$_alias_path" ]]; then
    source "$_alias_path"
  else
    echo "\033[1;31mMissing aliases file at $_alias_path. Have a look inside the zshrc.\033[0m"
  fi
done
unset _alias_file _alias_path

# bun completions
[ -s "/Users/gio/.bun/_bun" ] && source "/Users/gio/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# roc - https://www.roc-lang.org/install/macos_apple_silicon
# ROC_ID=2024-06-18-41ea2bfbc7d
ROC_ID=2024-06-26-f8c6786502b
export PATH="$PATH:$HOME/Developer/roc_lang/roc_nightly-macos_apple_silicon-$ROC_ID"

# Stop Homebrew from auto-updating because it is often inconvenient.
#
# I'll need something installed fast and Homebrew will spend minutes updating unrelated packages.
# Reminds me of Windows installing updates every other day...
export HOMEBREW_NO_AUTO_UPDATE=1
# mise — polyglot version manager (Ruby, Node, tuist, etc.).
# Reads legacy version files (.ruby-version, .nvmrc) via legacy_version_file.
if command -v mise &>/dev/null; then
  eval "$(mise activate zsh)"
fi

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/gio/.lmstudio/bin"
# End of LM Studio CLI section

# GPG needs to know which terminal to use for passphrase prompts.
# Set in .zshrc (not .zshenv) because tty fails in non-interactive shells.
export GPG_TTY=$(tty)

# For Claude Code
export PATH="$HOME/.local/bin:$PATH"
