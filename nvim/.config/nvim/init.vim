call plug#begin('~/.config/nvim/plugged')
"Plug 'Raimondi/delimitMate'
"Plug 'jiangmiao/auto-pairs'
Plug 'flazz/vim-colorschemes'
"Plug 'chriskempson/base16-vim'
"Plug 'tpope/vim-fugitive'
"Plug 'matze/vim-move'
"Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }
"Plug 'fatih/vim-go', { 'for': 'go' }
call plug#end()

filetype off                  " required

let base16colorspace=256  " Access colors present in 256 colorspace

filetype plugin indent on    " required
syntax enable
set background=dark
hi Normal ctermbg=none
filetype indent on

" Color Scheme
color monokai-chris

" Mapping f8 for c++ compiling and executing
map <F8> :!g++ % && ./a.out <CR>

" Setting Tab and indent Widths
set tabstop=4 softtabstop=0 expandtab shiftwidth=4
set smarttab
set expandtab
set title
set autoindent
set smartindent

"Highlight search results
set hlsearch
"Show current Position
set ruler
" Better Search settings
set incsearch
" Set Encoding
set encoding=utf8
" For Line numbers
set number
" Show matching braces
set showmatch
" Highlighting current line
set cursorline
highlight CursorLine cterm=bold ctermbg=NONE ctermfg=NONE guibg=NONE guifg=NONE
" Set No backups
set nobackup
set nowb
set noswapfile

" Common typos
:command WQ wq
:command Wq wq
:command W w
:command Q q
