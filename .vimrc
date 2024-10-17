set nocompatible              " be iMproved, required

so ~/.vim/plugins.vim

syntax enable

let mapleader = ','

"----Mappings---------"
"Alias ,ev to open a new tab to edit .vimrc"
nmap <Leader>ev :tabedit $MYVIMRC<cr>
"Alias ,<space> to clearing search highlights"
nmap <Leader><space> :nohlsearch<cr>
"Alias CTRL+1 to open project's side tree"
nmap <A-1> :NERDTreeToggle<cr>

"----Auto Commands----"
"Automatically source the .vimrc file on save."
augroup autosourcing
    autocmd!
    autocmd BufWritePost .vimrc source %
augroup END

"----Search-----------"
set hlsearch
set incsearch

"----File Search------"
filetype plugin on
set path+=**
set wildignore+=*/node_modules/*
set wildignore+=*/vendor/*
set wildmenu

set ignorecase
set noswapfile
set nocompatible

"----Split Management-"
set splitbelow
set splitright

nmap <C-J> <C-W><C-J>
nmap <C-K> <C-W><C-K>
nmap <C-H> <C-W><C-H>
nmap <C-L> <C-W><C-L>

"Disable sounds"
set belloff=all

"Indents"
filetype plugin indent on
set tabstop=2
set shiftwidth=2
set expandtab

"Hybrid line numbers"
set nu rnu
set number

set backspace=indent,eol,start

"----Plugins--------"

"CtrlP"

"NERDTree"
let NERDTreeHijackNetrw = 0
