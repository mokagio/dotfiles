source $DOTFILES_HOME/vimrc.shared

call plug#begin('~/.vim/plugged')
source $DOTFILES_HOME/vimrc.plugs.zettelkasten
call plug#end()

" Vim Wiki & Zettelkasten settings
"
let slipbox = {}
let slipbox.path = '$VIMWIKI_HOME/zettelkasten'
let slipbox.ext = '.md'
let slipbox.syntax = 'markdown'

let worklog_wiki = {}
let worklog_wiki.path = '~/Dropbox/.worklog_wiki'
let worklog_wiki.ext = '.md'
let worklog_wiki.syntax = 'markdown'

let g:vimwiki_list = [ slipbox, worklog_wiki ]

" TODO: DRY and parametrize ($HOME? $DOTFILES_HOME?)
let s:zettelkasten_vimrc = expand("~/.vimrc.zettelkasten")
if filereadable(s:zettelkasten_vimrc)
  execute 'source' fnameescape(s:zettelkasten_vimrc)
else
  echom "Warning: " . s:zettelkasten_vimrc . " not found."
endif

" Notational-FZF-Vim settings
"
" Before using this, every time I wanted to find a note, I had to use `[[` which
" resulted in a new link being created in the text.
" That's cool when you want to link notes, but that's not always the case,
" and I'd have to remember to go back and remove the link from the
" previous note.
let g:nv_search_paths = [ "$VIMWIKI_HOME/zettelkasten" ]
