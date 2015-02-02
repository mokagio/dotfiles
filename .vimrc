" Turn off vi compatibility
set nocompatible

" Automatically :write before running commands
set autowrite

if filereadable(expand("~/.vimrc.bundles"))
  source ~/.vimrc.bundles
endif

" Turn on syntax highlighting
syntax on

" Relative line numbers, 0 on the current line, 1 for the on above and below, and so on
set relativenumber

" Use spaces instead of tabs, and default tab to 2 spaces
" See http://stackoverflow.com/questions/234564/tab-key-4-spaces-and-auto-indent-after-curly-braces-in-vim
" Not sure about this combo from what I read from the help of the single settings, but hey the answer had 740 upvodes at the time of writing
set smartindent
set tabstop=2
set shiftwidth=2
set expandtab

"
" Type-based indentation
"
"See http://stackoverflow.com/questions/8536711/how-to-autoindent-ruby-source-code-in-vim
set smartindent
set autoindent

" Load indent file for the current filetype
filetype indent on

" Make vim chdir into the dir of the current open file. 
" Makes working with :e easier for me
set autochdir

" Allow file renames from Netrw Directory Listing
set modifiable

