call plug#begin('~/.config/nvim/plugged')
"Plug 'Raimondi/delimitMate'
"Plug 'jiangmiao/auto-pairs'
"Plug 'chriskempson/base16-vim'
"Plug 'tpope/vim-fugitive'
"Plug 'matze/vim-move'
"Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }
"Plug 'fatih/vim-go', { 'for': 'go' }
Plug 'flazz/vim-colorschemes'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
call plug#end()

" deoplete
if has('python3')
    " let g:deoplete#enable_at_startup = 1
    call deoplete#enable()
    let g:deoplete#enable_smart_case = 1
"    imap <C-@> <C-Space>
    autocmd InsertLeave,CompleteDone * if pumvisible() == 0 | pclose | endif
endif
" fzf
set rtp+=~/.fzf
let g:fzf_prefer_tmux = 1


filetype off                  " required

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

" autocomplete http://stackoverflow.com/a/510571
" we use deoplete for now
"inoremap <expr> <C-Space> pumvisible() \|\| &omnifunc == '' ?
"\ "\<lt>C-n>" :
"\ "\<lt>C-x>\<lt>C-o><c-r>=pumvisible() ?" .
"\ "\"\\<lt>c-n>\\<lt>c-p>\\<lt>c-n>\" :" .
"\ "\" \\<lt>bs>\\<lt>C-n>\"\<CR>"
"imap <C-@> <C-Space>
