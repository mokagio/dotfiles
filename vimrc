let mapleader = "\<Space>"

" Turn off vi compatibility
set nocompatible

" Automatically :write before running commands
set autowrite

if filereadable(expand("~/.vimrc.bundles"))
  source ~/.vimrc.bundles
endif

" Remap ESC and save on pinky travel time :)
inoremap kk <esc>

" Turn on syntax highlighting
syntax on

" Relative line numbers, line_number on the current line, 1 for the on above and below, and so on
set relativenumber
" Remove this to show 0 instead of line_number on the current line
set number
" This will make relative line numbers work on Netrw too
let g:netrw_bufsettings = 'noma nomod nu nobl nowrap ro'

" Use spaces instead of tabs, and default tab to 2 spaces
" See http://stackoverflow.com/questions/234564/tab-key-4-spaces-and-auto-indent-after-curly-braces-in-vim
" Not sure about this combo from what I read from the help of the single settings, but hey the answer had 740 upvodes at the time of writing
set smartindent
set tabstop=2
set shiftwidth=2
set expandtab
" Keep tabs active for Makefiles
autocmd FileType make setlocal noexpandtab

" Use F2 to toggle the past/nopaste mode
set pastetoggle=<F2>

" Color schemes are managed through the https://github.com/flazz/vim-colorschemes plugin
" See all available schemes in ~/.vim/bundle/vim-colorschemes/colors
colorscheme grb256

" If the color scheme won't work for some reason, these settings will be applied
" Highlight current line
set cursorline
hi CursorLine cterm=NONE ctermbg=darkgray
" Highlight extra whitespace(s) at the end of a line
hi ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /\s\+$/
" Visual mode selection color
hi Visual term=NONE cterm=NONE ctermbg=darkgray

" ctrlp settings
" ctrlp is a fuzzy file finder and opener
let g:ctrlp_map = '<c-p>'
let g:ctrlp_cmd = 'CtrlP'

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

" Keep pasted pieces of code "in the buffer" to paste multiple times
xnoremap p pgvy

" Spell check markdown files
au BufRead *.md setlocal spell spelllang=en_au

" Highlight Podfile as a Ruby file
au BufRead,BufNewFile Podfile set filetype=ruby

" netrw settings
"
" no banner
let g:netrw_banner=0
" tree style
let g:netrw_liststyle=3

" NerdTree
"
map <C-n> :NERDTreeToggle<CR>

" airline
"
" enable airline
let g:airline#extensions#tabline#enabled = 1
" always show the status bar
" this is a vim setting rather than airplane, but makes sense here
set laststatus=2
