# dotfiles

These are my dotfiles, in the hope to simplify the transition to any new machine.

## Install

1. The starting point is Xcode, and its Command Line Tools which you can install via `xcode-select --install`
1. Accept the Xcode license: `sudo xcodebuild -license` — `setup.sh` aborts otherwise
1. You'll now have `git`, use it to clone this repo
1. Install [Homebrew](https://brew.sh/)
1. Run the `setup.sh` script.
   It symlinks all the dotfiles to `$HOME` and installs the other tools.
   `brew bundle` may look unresponsive — it's actually just installing casks silently.
1. Open and configure 1Password
1. Open and configure Dropbox, as it contains the config folders for other apps

### After `setup.sh`

1. Set Zsh as the default shell: `chsh -s $(which zsh)` (see [Zsh notes](#zsh) below if this fails)
1. `gh auth login` so the GitHub CLI extensions installed by `setup.sh` can actually talk to GitHub
1. Bootstrap access to Automattic's private GitHub Enterprise.
   The SSH config for GHE lives inside GHE itself, so you can't clone it until you can reach GHE — a chicken-and-egg.
   Manually copy the GHE `Host` block and its `ProxyJump` `Host` block into `~/.ssh/config` (just enough to connect), fetch the full tracked config, then drop the copied blocks since they're now managed by the repo.
1. Import your GPG private key (`gpg --import secret.key`) so commit signing works.
   See the [GPG notes](#macos-notes) below for the full setup.
1. Once Dropbox has synced, point iTerm2 at its preferences:
   iTerm2 → Preferences → General → Settings → "Load preferences from a custom folder or URL" → `~/Dropbox`.
   Like Alfred, iTerm2 syncs its own settings through Dropbox, so they're deliberately not tracked in this public repo.
1. Grant Hammerspoon the macOS accessibility permission when it opens on first run (`setup.sh` opens it for you)

Apps you'll want to launch and configure next:

- Alfred — once Dropbox has synced, point Alfred at the existing config:
  Preferences → Advanced → "Set preferences folder" → `~/Dropbox`.
  Alfred syncs its own settings (including workflows, which can hold secrets) through
  Dropbox, so they're deliberately not tracked in this public repo.
- Tadam
- f.lux

### Re-running `setup.sh`

`setup.sh` is idempotent and accepts flags to skip the slow parts:

- `setup.sh --links-only` — only refresh symlinks (skip Homebrew, plugins, fonts, etc.)
- `setup.sh --ruby-only` — only re-run the Ruby setup (`mise install ruby` + `bundle install`)

Flags can be combined.

### zsh

Zsh will be installed through Homebrew, but it needs to be set as the default shell: `chsh -s $(which zsh)`

If the command errors saying `chsh: <# path #>: non-standard shell`, make sure that the path is listed in `/etc/shells`.
If not, `sudo vim /etc/shells` and add it, then run `chsh` again.

Open a new shell instance and type `echo $SHELL` to make sure zsh is the current shell.
If it isn't, try logging in and out.

## macOS notes

- [How to enable three fingers drag](https://support.apple.com/en-au/HT204609)
- [How to complete the GPG Git signing setup](https://stackoverflow.com/a/47087248/809944).
  On Apple Silicon, use `/opt/homebrew/bin/pinentry-mac` instead of `/usr/local/bin/pinentry-mac`.
