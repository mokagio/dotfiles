" Turn off vi compatibility
set nocompatible

" Automatically :write before running commands
set autowrite

if filereadable(expand("~/.vimrc.bundles"))
  source ~/.vimrc.bundles
endif

" Turn on syntax highlighting
syntax on

" Relative line numbers, line_number on the current line, 1 for the on above and below, and so on
set relativenumber
" Remove this to show 0 instead of line_number on the current line
set number
" This will make relative line numbers work on Netrw too
let g:netrw_bufsettings = 'noma nomod nu nobl nowrap ro'

" Highlight current line
set cursorline
hi CursorLine cterm=NONE ctermbg=darkgray
" Highlight extra whitespace(s) at the end of a line
hi ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /\s\+$/

" Visual mode selection color
hi Visual term=NONE cterm=NONE ctermbg=darkgray

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

" Allow erase to delete characters insert in previous insert sessions
" http://vim.wikia.com/wiki/Erasing_previously_entered_characters_in_insert_mode
set backspace=indent,eol,start

" Keep text selected after indentation.
vnoremap < <gv
vnoremap > >gv
