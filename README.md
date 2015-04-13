# dotfiles

These are my dotfiles, in the hope to simplify the transiction to any new machine.

## Install

1. The starting point is Xcode, and it's Command Line Tools which you can install via `xcode-select --install`
2. You'll now have `git`, use it to clone this repo
2. [Homebrew](http://brew.sh), to install basically all the rest
3. [Brewdler](https://github.com/Homebrew/homebrew-brewdler), to install all the other tools and apps
4. Run the `setup.sh` script, which will symlink all the dotfiles to `$HOME`

### zsh

zsh will be installed through homebrew, but it needs to be set as the default shell: `chsh -s $(which zsh)`

If the command errors saying `chsh: <# path #>: non-standard shell` make sure that the path is listed in `/etc/shells`, if not `sudo vim /etc/shells` and add it. Now run `chsh` again.

Open a new shell instance and type `echo $SHELL` to make sure zsh is the current shell. If it isn't maybe try logging in and out.

The setup is currently depending on [prezto](https://github.com/sorin-ionescu/prezto), have a look at the **entire** installation section of the README.

### vim and Vundle

You'll need to install [Vundle](https://github.com/gmarik/Vundle.vim) manually, then load the plugins from inside vim with `:PluginInstall`

### Alfred

If Alfred doesn't find the apps installed through Homebrew Cask, you'll need to add the casks' locations to Alfred's scope.

![Add Cask to Alfred's scope from the Alfred > Preferences > Features > Search Results](https://s3.amazonaws.com/gio-stuff/add-cask-scope-to-alfred)

_This should not be necessary with Alfred 2.6.1+_, see: http://www.alfredforum.com/topic/5489-fresh-install-doesnt-have-homebrew-cask-in-search-scope-until-reset-is-hit-accepted/

### Xcode

Install the [Alcatraz](https://github.com/supermarin/alcatraz) plugin.

You can get your snippets using [xcsnippets](https://github.com/mokagio/xcsnippet).

Also don't forget to download the documentation, so that it can be used by Dash.

