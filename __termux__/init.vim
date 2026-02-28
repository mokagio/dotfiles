source $DOTFILES_HOME/vimrc.shared

call plug#begin('~/.local/share/nvim/plugged')

Plug 'kien/ctrlp.vim'

Plug 'junegunn/limelight.vim'
Plug 'junegunn/goyo.vim'

source $DOTFILES_HOME/vimrc.plugs.zettelkasten
call plug#end()

let mapleader=" "
let maplocalleader=" "

" Vim Wiki & Zettelkasten settings
"
let s:zettelkasten_home = expand("~/zettelkasten/zettelkasten")

let zettel_wiki = {}
let zettel_wiki.path = fnameescape(s:zettelkasten_home)
let zettel_wiki.ext = '.md'
let zettel_wiki.syntax = 'markdown'

let g:vimwiki_list = [zettel_wiki]

let g:zettel_dir = fnameescape(s:zettelkasten_home)

" TODO: DRY and parametrize ($HOME? $DOTFILES_HOME?)
let s:zettelkasten_vimrc = expand("~/dotfiles/vimrc.zettelkasten")
if filereadable(s:zettelkasten_vimrc)
  execute 'source' fnameescape(s:zettelkasten_vimrc)
else
  echom "Warning: " . s:zettelkasten_vimrc . " not found."
endif

" notation-fzf-vim
"let g:nv_search_paths = [ fnameescape(s:zettelkasten_home) ]
let g:nv_search_paths = [ expand("~/zettelkasten/zettelkasten") ]
let g:nv_search_command = "rg"
let g:zettel_fzf_command = "rg --column --line-number --ignore-case --no-heading --color=always"

