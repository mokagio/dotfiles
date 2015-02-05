# dotfiles

These are my dotfiles, in the hope to simplify the transiction to any new machine.

![I have no idea what I'm doing](http://thumbpress.com/wp-content/uploads/2013/05/I-Have-No-Idea-What-Im-Doing-1.jpg)

## Install

1. The starting point is Xcode, and it's Command Line Tools
2. You'll now have `git`, use it to clone this repo
2. [Homebrew](http://brew.sh), to install basically all the rest
3. [Brewdler](https://github.com/Homebrew/homebrew-brewdler), to install all the other tools and apps
4. Run the `setup.sh` script, which will symlink all the dotfiles to `$HOME`

### zsh

zsh will be installed through homebrew, but it needs to be set as the default shell: `chsh -s $(which zsh)`

If the command errors saying `chsh: <# path #>: non-standard shell` make sure that the path is listed in `/etc/shells`, if not `sudo vim /etc/shells` and add it. Now run `chsh` again.

Open a new shell instance and type `echo $SHELL` to make sure zsh is the current shell. If it isn't maybe try logging in and out.

### vim and Vundle

You'll need to install [Vundle](https://github.com/gmarik/Vundle.vim) manually, then load the plugins from inside vim with `:PluginInstall`
