
call plug#begin('~/.vim/plugged')

Plug 'tpope/vim-sensible'
Plug 'NLKNguyen/papercolor-theme'
Plug 'vim-scripts/DfrankUtil'
Plug 'vim-scripts/vimprj'

Plug 'ctrlpvim/ctrlp.vim'
Plug 'ycm-core/YouCompleteMe', { 'do': './install.py' }
Plug 'scrooloose/nerdtree'

if system('which ctags') =~ "ctags"
Plug 'vim-scripts/indexer.tar.gz'
endif

call plug#end()

map <C-j> <C-W>j
map <C-k> <C-W>k
map <C-h> <C-W>h
map <C-l> <C-W>l


set t_Co=256   " This is may or may not needed.

set background=light
colorscheme PaperColor

" enable syntax highlighting
syntax on

" remove tailing spaces
autocmd BufWritePre * :%s/\s\+$//e

highlight Pmenu ctermbg=gray guibg=gray
:let g:ycm_show_diagnostics_ui = 0

:set tabstop=4
:set shiftwidth=4
:set expandtab
:set smartindent
