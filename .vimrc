
au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif

call plug#begin('~/.vim/plugged')

Plug 'tpope/vim-sensible'
Plug 'NLKNguyen/papercolor-theme'
Plug 'vim-scripts/DfrankUtil'
Plug 'vim-scripts/vimprj'
Plug 'ctrlpvim/ctrlp.vim'

call plug#end()

set background=light
colorscheme PaperColor

map <C-j> <C-W>j
map <C-k> <C-W>k
map <C-h> <C-W>h
map <C-l> <C-W>l


set t_Co=256   " This is may or may not needed.


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

let g:netrw_banner=0        " disable annoying banner
let g:netrw_liststyle=3     " tree view
let g:netrw_chgwin=1
