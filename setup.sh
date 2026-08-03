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
    if link_matches "$2" "$1"; then
      echo "$2 exists already, skipping"
    elif [[ ! -e "$2" ]]; then
      echo "Updating broken $2 to point to $1"
      rm "$2"
      ln -s "$1" "$2"
    else
      echo "WARNING: $2 points to $(readlink "$2"), expected $1; skipping"
    fi
  elif [[ -e "$2" ]]; then
    echo "WARNING: $2 exists and is not a symlink, skipping"
  else
    mkdir -p "$(dirname "$2")"
    echo "Will run: ln -s $1 $2"
    ln -s "$1" "$2"
  fi
}

ensure_real_dir() {
  local dir=$1 old_managed_target=${2:-}
  if [[ -h "$dir" ]]; then
    if [[ -n "$old_managed_target" ]] && link_matches "$dir" "$old_managed_target"; then
      echo "Replacing $dir symlink with a real directory"
      rm "$dir"
      mkdir -p "$dir"
    else
      echo "WARNING: $dir points to $(readlink "$dir"), expected a real directory; skipping"
    fi
  elif [[ -e "$dir" && ! -d "$dir" ]]; then
    echo "WARNING: $dir exists and is not a directory, skipping"
  else
    mkdir -p "$dir"
  fi
}

# 1Password holds the credentials every later step needs — the GPG signing key,
# GHE SSH access, `gh auth login` — so it goes in and gets unlocked up front
# instead of landing somewhere in the middle of a long `brew bundle` cask run.
# The app/CLI handshake can't be scripted: "Integrate with 1Password CLI" is a
# GUI toggle and biometric unlock needs a signed-in app, so this installs the
# pair, opens the app, then waits on the user.
bootstrap_1password() {
  if op whoami >/dev/null 2>&1; then
    echo "1Password CLI already signed in, skipping bootstrap"
    return 0
  fi

  # `--adopt` because 1Password is often already in /Applications from a manual
  # download; without it brew aborts on the existing app instead of taking it over.
  local cask
  for cask in 1password 1password-cli; do
    if brew list --cask "$cask" >/dev/null 2>&1; then
      echo "$cask already installed"
    elif ! brew install --cask --adopt "$cask"; then
      warn "brew install --cask $cask failed; continuing."
    fi
  done

  open -a 1Password || warn "Could not open 1Password; open it manually."

  echo ""
  echo "1Password, in order:"
  echo "  1. Sign in to your account in the app that just opened"
  echo "  2. Settings > Developer > enable 'Integrate with 1Password CLI'"
  echo "  3. Settings > Developer > enable 'Use the SSH agent' if you keep SSH keys here"
  echo ""

  if [[ ! -t 0 ]]; then
    warn "Not an interactive shell, so not waiting for the 1Password sign-in."
    warn "Do the steps above, then re-run setup.sh."
    return 0
  fi

  wait_for_1password_cli \
    || warn "Continuing without a working 'op'. Re-run setup.sh once 1Password is configured."
  return 0
}

# Re-prompt instead of trusting the first enter: the Developer-settings toggle
# is easy to skip, and an `op` that only fails three steps later is far more
# confusing to debug than one caught here.
wait_for_1password_cli() {
  local attempt=1
  while [[ $attempt -le 3 ]]; do
    read -r -p "Press enter once signed in and the CLI integration is on... " _ || return 1
    if op whoami >/dev/null 2>&1; then
      echo "1Password CLI ready."
      return 0
    fi
    warn "'op whoami' still fails — the CLI can't reach the app yet. ($attempt/3)"
    attempt=$((attempt + 1))
  done
  warn "Giving up on the 1Password check after 3 tries."
  return 1
}

ensure_codex_status_line() {
  local config=${CODEX_CONFIG:-$HOME/.codex/config.toml}
  local setting='status_line = ["model", "context-remaining", "current-dir", "git-branch"]'
  local config_dir tmp

  config_dir=$(dirname "$config")
  mkdir -p "$config_dir"

  if [[ ! -f "$config" ]]; then
    printf "[tui]\n%s\n" "$setting" > "$config"
    return
  fi

  tmp=$(mktemp "$config_dir/.config.toml.XXXXXX")
  awk -v setting="$setting" '
    BEGIN {
      in_tui = 0
      saw_tui = 0
      wrote = 0
    }

    /^\[[^]]+\]$/ {
      if (in_tui && !wrote) {
        print setting
        wrote = 1
      }
      if ($0 == "[tui]") {
        in_tui = 1
        saw_tui = 1
        wrote = 0
      } else {
        in_tui = 0
      }
      print
      next
    }

    in_tui && /^[[:space:]]*status_line[[:space:]]*=/ {
      if (!wrote) {
        print setting
        wrote = 1
      }
      next
    }

    { print }

    END {
      if (in_tui && !wrote) {
        print setting
      }
      if (!saw_tui) {
        print ""
        print "[tui]"
        print setting
      }
    }
  ' "$config" > "$tmp"
  mv "$tmp" "$config"
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

# The list of managed symlinks lives here, shared with dotfiles-doctor.
# shellcheck source=lib/links.sh
source "$dotfiles_dir/lib/links.sh"

# ---------------------------------------------------------------------------
# Symlinks and directories
# ---------------------------------------------------------------------------

if $do_links; then

printf '\033[1;36m==> %s\033[0m\n' "Setting up symlinks"
printf '\033[2m'

# SSH refuses a config in a dir others can write. link() would create ~/.ssh at
# the umask default (typically 755); create it at 700 first so the ssh/config
# symlink lands in a properly-scoped dir.
[[ -d ~/.ssh ]] || install -d -m 700 ~/.ssh

# Same story for ~/.gnupg — gpg refuses to read configs from a world-readable
# dir and emits a warning every invocation if the perms are looser than 700.
[[ -d ~/.gnupg ]] || install -d -m 700 ~/.gnupg

ensure_real_dir "$HOME/.agents/skills" "$dotfiles_dir/agents/skills"
ensure_real_dir "$HOME/.claude/skills"

emit_links link "$dotfiles_dir"

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

echo ""
printf '\033[1;36m==> %s\033[0m\n' "Bootstrapping 1Password"
bootstrap_1password

echo ""
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
# Plain `PlugInstall` (no bang) so `do` hooks only fire on fresh installs.
# With `!` they re-run every setup, which trips vim-tagquery's broken
# `cd $name/ || git clone $url && cd $name/` chain on existing checkouts
# (https://github.com/matt-snider/vim-tagquery/issues/3) and wipes the
# binary it just built. Use `:PlugUpdate <plugin>` to re-trigger a `do`
# hook after editing vimrc.plugs.
# Still wrap in `if !` so genuine fresh-install errors warn but don't abort.
if ! vim -es -u ~/.vimrc -i NONE -c 'PlugInstall --sync' -c 'qall'; then
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

# The native installer drops `claude` in `~/.local/bin`, which is on PATH
# for new shells (via `zshenv`) but not necessarily for the one running
# this script on a first-time install. Prepend it so the MCP setup below
# can find the freshly-installed binary.
export PATH="$HOME/.local/bin:$PATH"

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

# Codex CLI — install globally via npm under mise's Node, the channel used on
# this machine (the Homebrew formula lags, same reason the Claude install above
# skips the cask).
#
# Codex's config (~/.codex/config.toml) is intentionally NOT tracked in these
# dotfiles. Unlike Claude's settings.json, Codex rewrites it at runtime with
# machine-specific state — a project trust list full of absolute paths and
# private repo names, model-migration notices, TUI state — so it can't be
# shared or symlinked. Shared Codex instructions and hooks are linked into
# ~/.codex separately (see lib/links.sh).
if command -v mise &>/dev/null; then
  if ! mise exec -- npm ls -g @openai/codex >/dev/null 2>&1; then
    mise exec -- npm install -g @openai/codex || warn "npm install -g @openai/codex failed."
    mise reshim || warn "mise reshim failed; the codex shim may be stale."
  fi
  # `npm ls` only proves the package is on disk. A half-installed package whose
  # platform binary never landed, or a stale shim that falls through to a broken
  # copy elsewhere on PATH, both pass that check yet fail to launch — so confirm
  # codex actually runs and say so loudly when it doesn't.
  if mise exec -- codex --version >/dev/null 2>&1; then
    echo "Codex ready ($(mise exec -- codex --version))"
  else
    warn "codex is installed but won't run; check 'codex --version'."
  fi
fi
ensure_codex_status_line

echo ""
printf '\033[1;36m==> %s\033[0m\n' "Applying macOS defaults"
# Each script runs in its own `bash` so a failing one (set -e) doesn't abort
# the whole setup, and so it stays runnable standalone.
for macos_script in "$dotfiles_dir"/macos/*.sh; do
  [[ -e "$macos_script" ]] || continue
  echo "Running ${macos_script##*/}..."
  if ! bash "$macos_script"; then
    warn "${macos_script##*/} finished with errors; continuing."
  fi
done

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
  elif ! mise exec -- bundle exec fastlane enable_auto_complete; then
    warn "fastlane enable_auto_complete failed; shell completions not built."
  fi
else
  warn "mise not found, skipping Ruby setup."
fi

fi # do_ruby
