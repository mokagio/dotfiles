let mapleader = "\<Space>"

" Turn off vi compatibility
set nocompatible

" Automatically :write before running commands
set autowrite

if filereadable(expand("~/.vimrc.plugs"))
  call plug#begin('~/.vim/plugged')
  source ~/.vimrc.plugs
  call plug#end()
endif

" Remap ESC and save on pinky travel time :)
inoremap kk <esc>

" Map <Leader>s to save
noremap <Leader>s :w<CR>

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
filetype plugin indent on
set tabstop=2
set shiftwidth=2
set expandtab
" Keep tabs active for Makefiles
autocmd FileType make setlocal noexpandtab

" Use F2 to toggle the past/nopaste mode
set pastetoggle=<F2>

" Color schemes are managed through the https://github.com/flazz/vim-colorschemes plugin
" See all available schemes in ~/.vim/bundle/vim-colorschemes/colors
colorscheme Zenburn

" If the color scheme won't work for some reason, these settings will be applied
" Highlight current line
set cursorline
hi CursorLine cterm=NONE ctermbg=darkgray
" Highlight extra whitespace(s) at the end of a line
hi ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /\s\+$/
" Visual mode selection color
hi Visual term=NONE cterm=NONE ctermbg=darkgray

" Show page guide at column 80
set colorcolumn=80

" Better navigation for beginning and end of line
" Note that these replace the jump to top (H) and bottom (L) visible lines
" actions, but to be honest I've never used them, so is not a big loss...
"
" Via https://twitter.com/_supermarin/status/687016530769383425
nnoremap H ^
nnoremap L $

" ctrlp settings
" ctrlp is a fuzzy file finder and opener
let g:ctrlp_map = '<c-p>'
let g:ctrlp_cmd = 'CtrlP'
" show hidden files (.something) by default
let g:ctrlp_show_hidden = 1
let g:ctrlp_custom_ignore = {
  \ 'dir': '\v[\/](test_coverage|docs|DerivedData|node_modules)$',
  \ }

" Type-based indentation
"
"See http://stackoverflow.com/questions/8536711/how-to-autoindent-ruby-source-code-in-vim
set smartindent
set autoindent

" Load indent file for the current filetype
filetype indent on

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

" Highlight Podfile, Fatfile, etc. as a Ruby file
au BufRead,BufNewFile Podfile,Fastfile,AppFile,Deliverfile,Snapfile,Dangerfile set filetype=ruby

" netrw settings
"
" no banner
let g:netrw_banner=0
" tree style
let g:netrw_liststyle=3

" NERDTree
"
" Show/hide NERDTree with <C-n>
map <C-n> :NERDTreeToggle<CR>
let NERDTreeShowLineNumbers=1
let NERDTreeShowHidden=1
" use relative line numbers in NERDTree too <3
autocmd FileType nerdtree setlocal relativenumber

" airline
"
" enable airline
let g:airline#extensions#tabline#enabled = 1
" always show the status bar
" this is a vim setting rather than airplane, but makes sense here
set laststatus=2
" use powerline fonts for bold fatty arrous and othe symbols in the status bar (https://github.com/powerline/fonts.git)
" important: you'll need to install a powerline patched version of the font you want to use.
" important 2: when using vim from withing a terminal you'll need to set the patched font in the terminal app settings.
let g:airline_powerline_fonts=1

" Omni completion
"
filetype plugin on
set omnifunc=syntaxcomplete#Complete

" Neocomplete
"
" Enable automatic autocompletion via neocompletion by default
let g:neocomplete#enable_at_startup = 1
let g:neocomplete#enable_camel_case = 1
" Disable for markdown
autocmd FileType markdown NeoCompleteLock

" Syntastic
"
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0

let g:syntastic_loc_list_height = 4

" vim-markdown settings
"
" disable automatic folding
let g:vim_markdown_folding_disabled = 1
" disable new list item indent
let g:vim_markdown_new_list_item_indent = 0

" vim-rspec settings
"
map <Leader>t :call RunCurrentSpecFile()<CR>
map <Leader>n :call RunNearestSpec()<CR>
map <Leader>l :call RunLastSpec()<CR>
map <Leader>a :call RunAllSpecs()<CR>
let g:rspec_runner = "os_x_iterm2"

" swift.vim settings
"
let g:syntastic_swift_checkers = ['swiftpm', 'swiftlint']

" vim-xcode mappings
map <Leader>b :Xbuild<CR>
map <Leader>u :Xtest<CR>

" vim-jsx settings
"
" enable jsx highlighting for js files as well
let g:jsx_ext_required = 0
let g:syntastic_javascript_checkers = ['eslint']

" Custom Commands
"
com! FormatJSON %!python -m json.tool
