let s:shared_rc = expand("$DOTFILES_HOME") . "/vimrc.shared"
if filereadable(s:shared_rc)
  execute 'source' fnameescape(s:shared_rc)
else
  echohl ErrorMsg
  echom "Could not find shared rc at " . s:shared_rc
  echohl None
endif

" Turn off vi compatibility
set nocompatible

if filereadable(expand("~/.vimrc.plugs"))
  call plug#begin('~/.vim/plugged')
  source ~/.vimrc.plugs
  source $DOTFILES_HOME/vimrc.plugs.zettelkasten
  call plug#end()
endif

" Theme settings — vim-specific overrides
let g:tokyonight_style = 'night'
let g:tokyonight_enable_italic = 1

" Apply the shared theme logic (needs colorschemes loaded first)
call ApplyTheme()

" Goyo override for nord
autocmd! User GoyoEnter colorscheme nord

" Keep tabs active for Makefiles
autocmd FileType make setlocal tabstop=8
autocmd FileType make setlocal shiftwidth=8
autocmd FileType make setlocal noexpandtab

"
" Vim-only plugin settings
"

" coc.nvim — disable suggestions for markdown
autocmd FileType markdown let b:coc_suggest_disable = 1

" ctrlp
let g:ctrlp_map = '<c-p>'
let g:ctrlp_cmd = 'CtrlP'
let g:ctrlp_show_hidden = 1
let g:ctrlp_custom_ignore = {
  \ 'dir': '\v[\/](test_coverage|docs|DerivedData|node_modules|\.build|\.git)$',
  \ }

" NERDTree
map <C-n> :NERDTreeToggle<CR>
let NERDTreeShowLineNumbers=1
let NERDTreeShowHidden=1
autocmd FileType nerdtree setlocal relativenumber

" airline
let g:airline#extensions#tabline#enabled = 1
set laststatus=2
let g:airline_powerline_fonts=1

" Syntastic
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0

let g:syntastic_ruby_checkers = ['rubocop']
let g:syntastic_loc_list_height = 4
let g:syntastic_swift_checkers = ['swiftpm', 'swiftlint']
let g:syntastic_javascript_checkers = ['eslint']

" vim-rspec
map <Leader>t :call RunCurrentSpecFile()<CR>
map <Leader>n :call RunNearestSpec()<CR>
map <Leader>l :call RunLastSpec()<CR>
map <Leader>a :call RunAllSpecs()<CR>
let g:rspec_runner = "os_x_iterm2"

" vim-xcode
map <Leader>b :Xbuild<CR>
map <Leader>u :Xtest<CR>

" Vim Wiki & Zettelkasten settings
let g:zettel_wikigrep_command = "rg -l %pattern %path --glob='*%ext'"

let slipbox = {}
let slipbox.path = '$VIMWIKI_HOME/zettelkasten'
let slipbox.ext = '.md'
let slipbox.syntax = 'markdown'

let worklog_wiki = {}
let worklog_wiki.path = '~/Dropbox/.worklog_wiki'
let worklog_wiki.ext = '.md'
let worklog_wiki.syntax = 'markdown'

let g:vimwiki_list = [ slipbox, worklog_wiki ]

let s:zettelkasten_vimrc = expand("$DOTFILES_HOME/vimrc.zettelkasten")
if filereadable(s:zettelkasten_vimrc)
  execute 'source' fnameescape(s:zettelkasten_vimrc)
else
  echom "Warning: " . s:zettelkasten_vimrc . " not found."
endif

" Notational-FZF-Vim settings
if isdirectory(expand("$VIMWIKI_HOME/zettelkasten"))
  let g:nv_search_paths = [ "$VIMWIKI_HOME/zettelkasten" ]
  let g:zettel_dir = $VIMWIKI_HOME
else
  autocmd VimEnter * echom "VIMWIKI_HOME/zettelkasten not found — notational-fzf and vim-zettel disabled"
endif
let g:zettel_synced = 0

" Source Vim configuration file and install plugins
nnoremap <silent><leader>1 :source ~/.vimrc \| :PlugInstall<CR> \| :PlugUpdate<CR>
