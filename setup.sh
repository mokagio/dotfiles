#!/usr/bin/env bash

# Usage: setup.sh [--links-only] [--ruby-only]
#
#   (no args)      Run everything: symlinks + all install steps
#   --links-only   Only create symlinks and directories
#   --ruby-only    Only run Ruby setup (mise install + bundle)
#
# Flags can be combined: --links-only --ruby-only runs both but skips
# the heavy install steps (Homebrew, Node, Vim plugins, etc.).

# Print a red, attention-grabbing message. Used for both warnings (which
# continue execution) and fatal errors (via `die`). Goes to stdout to
# match the rest of the script's logging and to keep `bats run` able to
# capture it in `$output`.
warn() { printf '\033[1;31m%s\033[0m\n' "$*"; }
die()  { warn "$@"; exit 1; }

# Symlink $1 to $2 if $2 doesn't already exist.
# Fails loud if the source doesn't exist — catches typos in the dotfiles
# array and stale entries whose source file has since been removed,
# rather than silently producing a dangling symlink.
link() {
  if [[ ! -e "$1" ]]; then
    warn "ERROR: source $1 does not exist, cannot link"
    return 1
  fi
  if [[ -h "$2" ]]; then
    echo "$2 exists already, skipping"
  elif [[ -e "$2" ]]; then
    echo "WARNING: $2 exists and is not a symlink, skipping"
  else
    echo "Will run: ln -s $1 $2"
    ln -s "$1" "$2"
  fi
}

# Sourceable: when this file is sourced (e.g. by tests), bail out
# before running the install flow. Functions defined above remain
# available to the sourcing shell. When invoked as a script,
# ${BASH_SOURCE[0]} == ${0} and the guard falls through.
[[ "${BASH_SOURCE[0]}" == "${0}" ]] || return 0

set -euo pipefail

do_links=false
do_install=false
do_ruby=false

if [[ $# -eq 0 ]]; then
  do_links=true
  do_install=true
  do_ruby=true
else
  for arg in "$@"; do
    case "$arg" in
      --links-only) do_links=true ;;
      --ruby-only)  do_ruby=true ;;
      *)
        printf "Unknown option: %s\n" "$arg" >&2
        printf "Usage: setup.sh [--links-only] [--ruby-only]\n" >&2
        exit 1
        ;;
    esac
  done
fi

dotfiles_dir="$(cd "$(dirname "$0")" && pwd)"

# ---------------------------------------------------------------------------
# Symlinks and directories
# ---------------------------------------------------------------------------

if $do_links; then

printf '\033[1;36m==> %s\033[0m\n' "Setting up symlinks"
printf '\033[2m'

dotfiles=(
  'editorconfig'
  'gemrc'
  'gitconfig'
  'gitignore'
  'ghci'
  'ideavimrc'
  'lldbinit'
  'liftoffrc'
  'tigrc'
  'vimrc'
  'vimrc.zettelkasten'
  'vimrc.plugs'
  'xvimrc'
  'zshrc'
  'zshenv'
  'zshprompt'
)

for dot in "${dotfiles[@]}"
do
  destination="$HOME/.$dot"

  link "$dotfiles_dir/$dot" "$destination"
done

# Link Vim spellfile.
# Not sure how to symlink and entire folder yet
mkdir -p ~/.vim/spell
# Note that you should not use `_` in the file name, see
# https://unix.stackexchange.com/questions/85538/how-can-i-create-my-own-spelling-file-for-vim
vim_spell_path="$dotfiles_dir/vim/spell/custom-spell.utf-8.add"
if [[ -f $vim_spell_path ]]; then
  # Interestingly, I had to use $HOME here instead of ~, otherwise, ln would
  # fail with "No such file or directory". Why does ~ work above but not here?
  # Is it because there's nested folders in this destination path?
  destination="$HOME/.vim/spell/custom-spell.utf-8.add"
  link "$vim_spell_path" "$destination"
else
  echo "Could not find $vim_spell_path! Aborting."
  exit 1
fi

# NeoVim
neovim_root=~/.config/nvim
neovim_init="$dotfiles_dir/neovim_init.vim"
mkdir -p "$neovim_root"
if [[ -f $neovim_init ]]; then
  destination="$neovim_root/init.vim"
  link "$neovim_init" "$destination"
else
  echo "Could not find $neovim_init! Aborting."
  exit 1
fi
# Native LSP configs
link "$dotfiles_dir/nvim/lsp" "$neovim_root/lsp"

# Hammerspoon window manager
# http://www.hammerspoon.org/
mkdir -p ~/.hammerspoon
link "$dotfiles_dir/hammerspoon_init.lua" "$HOME/.hammerspoon/init.lua"

# mise — needs idiomatic_version_file_enable_tools = ["ruby"] so `.ruby-version`
# files in repos (pinning 3.2.2 for a8c iOS work) win over the global 3.4.7 pin.
mkdir -p ~/.config/mise
link "$dotfiles_dir/mise/global-config.toml" "$HOME/.config/mise/config.toml"

# Claude Code
mkdir -p ~/.claude
for f in claude/settings.json claude/CLAUDE.md claude/statusline.sh; do
  link "$dotfiles_dir/$f" "$HOME/.${f}"
done
# AGENTS.md at both the conventional home location and the XDG location.
# Keep both so different agent tools can discover the same shared file.
link "$dotfiles_dir/agents/AGENTS.md" "$HOME/AGENTS.md"
mkdir -p ~/.codex
link "$dotfiles_dir/agents/AGENTS.md" "$HOME/.codex/AGENTS.md"
mkdir -p ~/.config/agents
link "$dotfiles_dir/agents/AGENTS.md" "$HOME/.config/agents/AGENTS.md"
# `nullglob` makes unmatched globs expand to nothing rather than to the
# literal pattern, which would otherwise be passed to `link` and trip
# the source-existence guard. Scoped to just the rule + skill loops so
# the later Powerline `*owerline*` glob (which relies on the default
# pass-literal behavior to make `ls` fail) is unaffected.
shopt -s nullglob
mkdir -p ~/.config/agents/rules
mkdir -p ~/.claude/rules
for rule in "$dotfiles_dir"/agents/rules/*.md; do
  rule_name="$(basename "$rule")"
  link "$rule" "$HOME/.config/agents/rules/$rule_name"
  link "$rule" "$HOME/.claude/rules/$rule_name"
done
link "$dotfiles_dir/claude/hooks" "$HOME/.claude/hooks"
# Shared skills — whole-directory symlink for ~/.agents/skills
mkdir -p ~/.agents
link "$dotfiles_dir/agents/skills" "$HOME/.agents/skills"
# Per-skill symlinks for Claude so Claude-only skills can coexist
mkdir -p ~/.claude/skills
for skill in "$dotfiles_dir"/agents/skills/*/; do
  skill_name="$(basename "$skill")"
  link "$skill" "$HOME/.claude/skills/$skill_name"
done
# Claude-only skills (not shared with other agents)
for skill in "$dotfiles_dir"/claude/skills/*/; do
  skill_name="$(basename "$skill")"
  link "$skill" "$HOME/.claude/skills/$skill_name"
done
shopt -u nullglob
printf '\033[0m'

fi # do_links

# ---------------------------------------------------------------------------
# Install steps (skipped by --links-only)
# ---------------------------------------------------------------------------

if $do_install; then

echo ""
printf '\033[1;36m==> %s\033[0m\n' "Installing tools"

if ! command -v xcodebuild &>/dev/null; then
  die "xcodebuild not found. Run 'xcode-select --install' first to install the Xcode Command Line Tools."
fi
if ! xcodebuild -license check &>/dev/null; then
  die "Xcode CLI tools license not accepted. Run 'sudo xcodebuild -license' first."
fi

# Locate Homebrew without relying on PATH being already configured —
# on a fresh Mac, the `brew shellenv` line lives in `.zprofile` which
# isn't sourced until the user opens a new shell. Apple Silicon installs
# under `/opt/homebrew`, Intel under `/usr/local`; probe both, prefer
# Apple Silicon, fail if neither is present.
brew_bin=""
for candidate in /opt/homebrew/bin/brew /usr/local/bin/brew; do
  if [[ -x "$candidate" ]]; then
    brew_bin="$candidate"
    break
  fi
done
if [[ -z "$brew_bin" ]]; then
  die "Homebrew not found at /opt/homebrew/bin/brew or /usr/local/bin/brew. Install it from https://brew.sh first."
fi
# Apply brew's shell setup for the rest of this script so subsequent
# tools (brew bundle, mise, nvim, gh, ...) are reachable on PATH.
eval "$("$brew_bin" shellenv)"

# Some casks (Karabiner-Elements, pinentry-mac, ...) shell out to sudo
# mid-install. Prime the credential once up front and keep it warm so
# the bundle doesn't pause for a password partway through. The keep-alive
# loop exits when this script exits (kill -0 "$$" probe).
echo ""
echo "Some Homebrew casks need sudo to install (e.g. Karabiner-Elements, pinentry-mac)."
echo "Priming sudo now so 'brew bundle' doesn't pause for a password later."
sudo -v
while true; do sudo -n true; sleep 50; kill -0 "$$" 2>/dev/null || exit; done 2>/dev/null &

if ! HOMEBREW_VERBOSE_USING_DOTS=1 brew bundle --verbose; then
  warn "brew bundle finished with errors. Some formulae may not have installed."
  warn "Run 'brew bundle' manually to retry."
fi

for cmd in nvim mise; do
  if ! command -v "$cmd" &>/dev/null; then
    die "$cmd not found after brew bundle. Cannot continue."
  fi
done
# Some of the tools installed via Homebrew might need additional manual steps.
#
# Install fzf useful keybindings and fuzzy completion for ZSH
if [[ ! -f ~/.fzf.zsh ]] && command -v brew &>/dev/null; then
  fzf_install="$(brew --prefix)/opt/fzf/install"
  if [[ -f "$fzf_install" ]]; then
    "$fzf_install"
  fi
fi
# Bypass gatekeeper for QLColorCode
# https://github.com/anthonygelibert/QLColorCode/issues/84
qlcolorcode_path="$HOME/Library/QuickLook/QLColorCode.qlgenerator"
if [[ -d "$qlcolorcode_path" ]]; then
  xattr -cr "$qlcolorcode_path"
fi

# Open Hammerspoon on first install so macOS surfaces the accessibility
# permission prompt and any other in-app first-run setup. The `init.lua`
# symlink is already in place from the do_links phase, so the app loads
# with the intended config on first launch. `defaults read` returning
# non-zero means the user defaults domain doesn't exist yet, i.e. the app
# has never been launched — the right time to open it. Skip on repeat
# setup runs to avoid stealing focus.
if [[ -d /Applications/Hammerspoon.app ]] \
   && ! defaults read org.hammerspoon.Hammerspoon >/dev/null 2>&1; then
  echo "Opening Hammerspoon — grant accessibility permission when prompted."
  open -a Hammerspoon
fi

# Install the Node version pinned in the global mise config (currently `lts`).
# Don't `mise use --global` here: the global config is symlinked into this
# repo, so writing to it would clobber the pinned version.
if command -v mise &>/dev/null; then
  if ! mise install node; then
    warn "mise install node failed; continuing."
  # Read the version into a variable so a failing `node --version` is
  # reported instead of producing `Node  installed via mise` (with an
  # empty version) — command-substitution failures don't propagate
  # through `echo`.
  elif node_version=$(mise exec -- node --version); then
    echo "Node $node_version installed via mise"
  else
    warn "Node install completed but reading the version failed."
  fi
else
  warn "mise not found, skipping Node setup."
fi

# Install Vim-Plug to manage Vim plugins
# See https://github.com/junegunn/vim-plug/tree/c3b6b7c2971da730d66f6955d5c467db8dae536b#vim
plug_url="https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
vim_plug_path="$HOME/.vim/autoload/plug.vim"
if [[ -f "$vim_plug_path" ]]; then
  echo "Looks like you already have Vim-Plug installed for Vim, skipping"
elif ! curl -fLo "$vim_plug_path" --create-dirs "$plug_url"; then
  warn "Vim-Plug download for Vim failed; PlugInstall will be skipped."
fi
nvim_plug_path="$HOME/.local/share/nvim/site/autoload/plug.vim"
if [[ -f "$nvim_plug_path" ]]; then
  echo "Looks like you already have Vim-Plug installed for Neovim, skipping"
elif ! curl -fLo "$nvim_plug_path" --create-dirs "$plug_url"; then
  warn "Vim-Plug download for Neovim failed; PlugInstall will be skipped."
fi

# Install Vim and Neovim plugins.
# Use `-es` (ex + silent) for vim instead of `--not-a-term`: the latter still
# draws to the alt-screen in non-TTY contexts and leaves `[No Name] / buffers`
# artifacts in setup output. `-i NONE` skips viminfo to keep the run hermetic.
#
# `vim-tagquery`'s `install.sh` exits non-zero on every run after the first
# (https://github.com/matt-snider/vim-tagquery/issues/3), and `PlugInstall!`
# (with bang) re-runs `do` hooks even when the plugin is already installed.
# Don't let that abort the whole setup script — match the `brew bundle` pattern.
if ! vim -es -u ~/.vimrc -i NONE -c 'PlugInstall! --sync' -c 'qall'; then
  warn "vim PlugInstall finished with errors. Check the output above for plugin install failures."
fi
if command -v nvim &>/dev/null; then
  if ! nvim --headless +PlugInstall +qall; then
    warn "nvim PlugInstall finished with errors. Check the output above for plugin install failures."
  fi
fi

# Powerline fonts. Subshell scopes the EXIT trap so the tmpdir is
# cleaned up whether the install succeeds or aborts mid-step. `&&`
# chaining short-circuits: `set -e` is suspended inside `if (...)`, so
# without it a failed `git clone` would still try to run `install.sh`.
if ls "$HOME/Library/Fonts/"*owerline* &>/dev/null; then
  echo "Powerline fonts already installed, skipping"
else
  echo "Installing Powerline fonts..."
  if (
    powerline_tmp=$(mktemp -d)
    trap 'rm -rf "$powerline_tmp"' EXIT
    git clone https://github.com/powerline/fonts.git --depth=1 "$powerline_tmp" \
      && echo "Running Powerline font installer..." \
      && "$powerline_tmp/install.sh"
  ); then
    echo "Powerline fonts installed"
  else
    warn "Powerline font install failed; tmpdir cleaned up; continuing."
  fi
fi

# GitHub CLI extensions — install each independently so one failure
# (network, rate limit, already-installed error) doesn't skip the rest.
if command -v gh &>/dev/null; then
  for ext in dlvhdr/gh-dash meiji163/gh-notify; do
    if gh extension list 2>/dev/null | grep -q "$ext"; then
      echo "gh extension $ext already installed, skipping"
    elif ! gh extension install "$ext"; then
      warn "gh extension install $ext failed; continuing."
    fi
  done
fi

# Claude Code — install via the native installer rather than the Homebrew
# cask. The cask lags behind, while the native install auto-updates via
# `claude update` and is what's actually on PATH on this machine.
if ! command -v claude >/dev/null 2>&1; then
  curl -fsSL https://claude.ai/install.sh | bash
fi

# Claude Code global MCP servers.
# `claude mcp add` exits non-zero if the server already exists, which would
# abort the script under `set -e`, so check first.
if command -v claude >/dev/null 2>&1; then
  if claude mcp get buildkite >/dev/null 2>&1; then
    echo "MCP server buildkite already configured, skipping"
  elif ! claude mcp add --transport http --scope user buildkite https://mcp.buildkite.com/mcp/readonly; then
    warn "claude mcp add buildkite failed; continuing."
  fi
else
  warn "claude not found, skipping MCP server setup."
fi

fi # do_install

# ---------------------------------------------------------------------------
# Ruby setup (runs for --ruby-only and default)
# ---------------------------------------------------------------------------

if $do_ruby; then

echo ""
printf '\033[1;36m==> %s\033[0m\n' "Setting up Ruby"

# Install the Ruby version pinned in the global mise config and system-wide
# gems. Don't `mise use --global` here: the global config is symlinked into
# this repo, so writing to it would clobber the pinned version.
if command -v mise &>/dev/null; then
  if ! mise install ruby; then
    warn "mise install ruby failed; skipping gem setup."
  elif ! mise exec -- gem install bundler; then
    warn "gem install bundler failed; skipping bundle install."
  elif ! mise exec -- bundle install; then
    warn "bundle install failed. Run it manually to retry."
  fi
else
  warn "mise not found, skipping Ruby setup."
fi

fi # do_ruby
