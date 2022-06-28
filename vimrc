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

" Enable project-specific vimrc
" See https://andrew.stwrt.ca/posts/project-specific-vimrc/
set exrc

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
"
" Enable true colors support - Recommended in
" https://github.com/ayu-theme/ayu-vim I didn't research what it means, but
" without it, the nord and ayu light themes don't work.
set termguicolors
" Zenburn is a classic, nice one to use when in doubt
" colorscheme Zenburn
" Nord (https://github.com/arcticicestudio/nord-vim) a quiet theme to write in
" the dark.
" colorscheme nord
let ayucolor="light"
" Ayu (https://github.com/ayu-theme/ayu-vim), in light mode, is nice to write
" in bright places.
" colorscheme ayu
" And here's another theme that's good in the light version
" https://github.com/sonph/onehalf/tree/master/vim
" colorscheme onehalflight

" Use a dedicated theme for early writing sessions (which is 99% of why I
" would use Vim in the early morning).
if strftime("%H") < 7 || strftime("%H") >= 21
  colorscheme nord
else
  colorscheme Zenburn
endif

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
"let &colorcolumn=join(range(81,999),",")
"highlight ColorColumn ctermbg=235 guibg=#2c2d27
highlight ColorColumn ctermbg=darkgray

" Better navigation for beginning and end of line
" Note that these replace the jump to top (H) and bottom (L) visible lines
" actions, but to be honest I've never used them, so is not a big loss...
"
" Via https://twitter.com/_supermarin/status/687016530769383425
nnoremap H ^
nnoremap L $

" Tweak whereVim open splits to be 'more natural'
"
" Via https://vimtricks.com/p/open-splits-more-naturally/
set splitbelow
set splitright

" ctrlp settings
" ctrlp is a fuzzy file finder and opener
let g:ctrlp_map = '<c-p>'
let g:ctrlp_cmd = 'CtrlP'
" show hidden files (.something) by default
let g:ctrlp_show_hidden = 1
let g:ctrlp_custom_ignore = {
  \ 'dir': '\v[\/](test_coverage|docs|DerivedData|node_modules|\.build)$',
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

" Spell checking settings
"
" Custom words list. Quite useful when working in tech because Vim doesn't
" know a lot of the names we use.
set spellfile=$HOME/.vim/spell/custom-spell.utf-8.add
" I haven't figured out a way to have good spell checking for code, so for now
" only check spelling on 'text' files
"
" TODO: extract lang value in a constant
au BufRead *.md setlocal spell spelllang=en_us
" Check spelling on commit messages too
au BufRead COMMIT_EDITMSG setlocal spell spelllang=en_us
" Check spelling when opening pull requests with hub
" https://github.com/github/hub
au BufRead PULLREQ_EDITMSG setlocal spell spelllang=en_us

" Highlight Podfile, Fatfile, etc. as a Ruby file
au BufRead,BufNewFile Podfile,Fastfile,AppFile,Deliverfile,Matchfile,Snapfile,Pluginfile,Dangerfile set filetype=ruby
au BufRead,BufNewFile Jetpack-Fastfile set filetype=ruby
" Highlight Pods.WORKSPACE as a Starlark file
au BufRead,BufNewFile Pods.WORKSPACE set filetype=starlark

" Prettier formatter configuration
autocmd FileType typescript setlocal formatprg=prettier\ --parser\ typescript

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
" this is a vim setting rather than airline, but makes sense here
set laststatus=2
" use powerline fonts for bold fatty arrous and othe symbols in the status bar (https://github.com/powerline/fonts.git)
" important: you'll need to install a powerline patched version of the font you want to use.
" important 2: when using vim from withing a terminal you'll need to set the patched font in the terminal app settings.
let g:airline_powerline_fonts=1

" Omni completion
"
filetype plugin on
set omnifunc=syntaxcomplete#Complete

" Neocomplete - Disabled while I try coc.vim
"
" Enable automatic autocompletion via neocompletion by default
" let g:neocomplete#enable_at_startup = 1
" let g:neocomplete#enable_camel_case = 1
" Disable for markdown
" autocmd FileType markdown NeoCompleteLock

" coc.vim
" Disable for markdown
autocmd FileType markdown let b:coc_suggest_disable = 1

" vim-test mappings
" See https://github.com/vim-test/vim-test/tree/b882783760b954144dda5be7ad6cd4bdefd013fb#setup
nmap <silent> t<C-n> :TestNearest<CR>
nmap <silent> t<C-f> :TestFile<CR>
nmap <silent> t<C-s> :TestSuite<CR>
nmap <silent> t<C-l> :TestLast<CR>
nmap <silent> t<C-g> :TestVisit<CR>

" Syntastic
"
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0

let g:syntastic_ruby_checkers = ['rubocop']

let g:syntastic_loc_list_height = 4

" At some point, Ruby files started to be very slow when saving. Namely, after
" saving (e.g. with the Leader<s> map) Vim would hang in command mode for at
" least a second.
"
" I stumbled on the StackOverflow question below and tried a few options...
" Using `lazyredraw` seems to work well so far.
"
" https://stackoverflow.com/questions/16902317/vim-slow-with-ruby-syntax-highlighting
autocmd FileType ruby setlocal lazyredraw

" vim-markdown settings
"
" disable automatic folding
let g:vim_markdown_folding_disabled = 1
" disable new list item indent
let g:vim_markdown_new_list_item_indent = 0
" front matter highlighting
let g:vim_markdown_frontmatter = 1
let g:vim_markdown_toml_frontmatter = 1
" Goyo (focused writing) settings
let g:goyo_linenr = 1
" Soft word wrapping, see http://vim.wikia.com/wiki/Word_wrap_without_line_breaks
set wrap
set linebreak
set nolist

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

" Indent XML files
" See http://ku1ik.com/2011/09/08/formatting-xml-in-vim-with-indent-command.html
au FileType xml setlocal equalprg=xmllint\ --format\ --recover\ -\ 2>/dev/null

" Vim Wiki & Zettelkasten settings
"
" I have two Zettelkasten spliboxes, one for "work" one for "life & parenting"
" stuff.
"
" I'm not sure whether it's a good idea, because life and work blend all the
" time, but I think it might make it easier to search. After all, I don't plan
" to write about parenting or philosophy any time soon.
let parenting_slipbox = {}
let parenting_slipbox.path = '~/Dropbox/vimwiki/parenting/'
let parenting_slipbox.ext = '.md'
let parenting_slipbox.syntax = 'markdown'

let writing_slipbox = {}
let writing_slipbox.path = '~/Dropbox/vimwiki/writing-business/'
let writing_slipbox.ext = '.md'
let writing_slipbox.syntax = 'markdown'

let philosophy_slipbox = {}
let philosophy_slipbox.path = '~/Dropbox/vimwiki/philosophy/'
let philosophy_slipbox.ext = '.md'
let philosophy_slipbox.syntax = 'markdown'

let coding_wiki = {}
let coding_wiki.path = '~/Dropbox/vimwiki/coding/'
let coding_wiki.ext = '.md'
let coding_wiki.syntax = 'markdown'

let g:vimwiki_list = [ writing_slipbox, parenting_slipbox, philosophy_slipbox, coding_wiki ]
" As recommended in the help, map creating a new note with title to a leader
" command
nnoremap <Leader>zn :ZettelNew<space>
nnoremap <Leader>zt :VimwikiRebuildTags<CR>
" Create a new note using the selected text as the title
" (This is the default value but I keep forgetting about it...)
autocmd FileType vimwiki xmap z <Plug>ZettelNewSelectedMap
" Notational-FZF-Vim settings
"
" Before using this, every time I wanted to find a note, I had to use `[[` which
" resulted in a new link being created in the text.
" That's cool when you want to link notes, but that's not always the case,
" and I'd have to remember to go back and remove the link from the
" previous note.
let g:nv_search_paths = ['~/Dropbox/vimwiki']
" p, the same as CtrlP but for notes
nnoremap <silent> <Leader>zp :NV<CR>
" One downside of using Vim for this is that I don't have handy UI to see
" connection. To compensate, here's mappings to make getting them as fast as
" possible.
nnoremap <silent> <Leader>zb :ZettelBackLinks<CR>
" Sync VimWiki / Zettelkasten slipbox to Git via
" https://github.com/michal-h21/vimwiki-sync
" This folder needs to be defined so that the sync plugin runs only there and
" not in every markdown file.
let g:zettel_dir = '~/Dropbox/vimwiki'
let g:zettel_synced = 0 " disable Git syncying

" Source Vim configuration file and install plugins
" via https://pragmaticpineapple.com/ultimate-vim-typescript-setup/
nnoremap <silent><leader>1 :source ~/.vimrc \| :PlugInstall<CR> \| :PlugUpdate<CR>

" Markdown Preview settings
" TODO: these are _all_ the options from
" https://github.com/iamcco/markdown-preview.nvim/tree/96c0bc72252f87c4fcafaa672352a91730dee61d#install--usage
" but the only one I wanted to tweak is the synchronized scrolling, how can I
" update only that one without redefining the dictionary?
let g:mkdp_preview_options = {
      \ 'mkit': {},
      \ 'katex': {},
      \ 'uml': {},
      \ 'maid': {},
      \ 'disable_sync_scroll': 0,
      \ 'sync_scroll_type': 'middle',
      \ 'hide_yaml_meta': 1,
      \ 'sequence_diagrams': {},
      \ 'flowchart_diagrams': {},
      \ 'content_editable': v:false,
      \ 'disable_filename': 0
      \ }

"
" Custom Commands
"
com! FormatJSON %!python -m json.tool
