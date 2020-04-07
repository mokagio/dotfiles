# dotfiles

These are my dotfiles, in the hope to simplify the transiction to any new machine.

## Install

1. The starting point is Xcode, and its Command Line Tools which you can install via `xcode-select --install`
1. You'll now have `git`, use it to clone this repo
1. Install [Homebrew](https://brew.sh/)
1. Run the `setup.sh` script, which will symlink all the dotfiles to `$HOME` and install the other tools
1. Open Vim and install its plugins via `:PlugInstall`

### zsh

zsh will be installed through homebrew, but it needs to be set as the default shell: `chsh -s $(which zsh)`

If the command errors saying `chsh: <# path #>: non-standard shell` make sure that the path is listed in `/etc/shells`, if not `sudo vim /etc/shells` and add it. Now run `chsh` again.

Open a new shell instance and type `echo $SHELL` to make sure zsh is the current shell. If it isn't maybe try logging in and out.

The setup is currently depending on [prezto](https://github.com/sorin-ionescu/prezto), have a look at the **entire** installation section of the README.

You will also need to `ln -s ~/.zprezto/runcoms/zpreztorc ~/.zpreztorc` to enable the Prezto modules, as at the moment those are not configure in this setup.

### vim and vim-plug

You'll need to install [vim-plug](https://github.com/junegunn/vim-plug) manually, then load the plugins from inside vim with `:PlugInstall`

### Alfred

If Alfred doesn't find the apps installed through Homebrew Cask, you'll need to add the casks' locations to Alfred's scope.

_This should not be necessary with Alfred 2.6.1+_, see: http://www.alfredforum.com/topic/5489-fresh-install-doesnt-have-homebrew-cask-in-search-scope-until-reset-is-hit-accepted/

### Xcode

You can get your snippets using [xcsnippets](https://github.com/mokagio/xcsnippet).

Also don't forget to download the documentation, so that it can be used by Dash.

## macOS notes

- [How to enable three fingers drag](https://support.apple.com/en-au/HT204609)
