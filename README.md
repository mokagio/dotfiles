# dotfiles

These are my dotfiles, in the hope to simplify the transition to any new machine.

## Install

1. The starting point is Xcode, and its Command Line Tools which you can install via `xcode-select --install`
1. You'll now have `git`, use it to clone this repo
1. Install [Homebrew](https://brew.sh/)
1. Run the `setup.sh` script, which will symlink all the dotfiles to `$HOME` and install the other tools (when running `brew bundle`, it might look unresponsive, but it's actually just installing casks silently)
1. Open and configure 1Password
1. Open and configure Dropbox, as it contains the config folders for other apps

Apps you'll want to launch and configure next:

- Alfred (wait for its `.preferences` folder to appear in Dropbox)
- Tadam
- flux

### zsh

Zsh will be installed through Homebrew, but it needs to be set as the default shell: `chsh -s $(which zsh)`

If the command errors saying `chsh: <# path #>: non-standard shell` make sure that the path is listed in `/etc/shells`, if not `sudo vim /etc/shells` and add it. Now run `chsh` again.

Open a new shell instance and type `echo $SHELL` to make sure zsh is the current shell. If it isn't maybe try logging in and out.

## macOS notes

- [How to enable three fingers drag](https://support.apple.com/en-au/HT204609)
- [How to complete the GPG Git signing setup](https://stackoverflow.com/a/47087248/809944) and makes sure to use `/opt/homebrew/bin/pinentry-mac` instead of `/usr/local/bin/pinentry-mac` on an Apple Silicon machine!
