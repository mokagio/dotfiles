source $DOTFILES_HOME/vimrc.shared

call plug#begin('~/.vim/plugged')

" Shared plugins (completion, git, languages, testing, writing, etc.)
source $DOTFILES_HOME/vimrc.plugs.shared

" Zettelkasten
source $DOTFILES_HOME/vimrc.plugs.zettelkasten

" NeoVim-specific plugins
Plug 'folke/tokyonight.nvim'
Plug 'arcticicestudio/nord-vim', { 'branch': 'main' }
Plug 'ayu-theme/ayu-vim'
Plug 'sainnhe/everforest'

call plug#end()

" Native LSP
lua vim.lsp.enable('ruby_lsp')

" Show diagnostics as inline virtual text with source and error code
lua vim.diagnostic.config({
  \ virtual_text = { source = true, spacing = 2 },
  \ signs = { text = { [1] = 'E', [2] = 'W', [3] = 'I', [4] = 'H' } },
  \ underline = true,
  \ severity_sort = true,
  \ })

" Theme — use NeoVim-native tokyonight config
let g:tokyonight_style = 'night'
let g:tokyonight_enable_italic = 1

" Apply the shared theme logic
call ApplyTheme()

" Goyo override for nord
autocmd! User GoyoEnter colorscheme nord

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
  echohl WarningMsg
  echom "Warning: " . s:zettelkasten_vimrc . " not found."
  echohl None
  call input("")
endif

" Notational-FZF-Vim settings
if isdirectory(expand("$VIMWIKI_HOME/zettelkasten"))
  let g:nv_search_paths = [ "$VIMWIKI_HOME/zettelkasten" ]
  let g:zettel_dir = $VIMWIKI_HOME
else
  autocmd VimEnter * echom "VIMWIKI_HOME/zettelkasten not found — notational-fzf and vim-zettel disabled"
endif
let g:zettel_synced = 0
