After pulling 5eb59167bb337244bb67aa6be7086b5ea1bd6280, fzf/notational flow stopped working on the Termux app using these dotfiles.

To fix it, I had to add the final two lines in the init.vim tracked as a sibling to this file.

The problem was that Termux looked for Ag, which was not installed.

But also, Termux uses that custom init.vim instead of the setup in the dotfiles.

I don't remember why I did that, but it was likely because of compatibility issues and/or wanting to keep the setup in Termux lean.
After all, mosst of the stuff in the dotfiles is for my full dev environment on macOS, while the Termux setup is only for writing in NeoVim on my zettelkasten and articles drafts.
