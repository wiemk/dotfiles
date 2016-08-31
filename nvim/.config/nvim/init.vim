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
"	 imap <C-@> <C-Space>
	autocmd InsertLeave,CompleteDone * if pumvisible() == 0 | pclose | endif
endif
" fzf
set rtp+=~/.fzf
let g:fzf_prefer_tmux = 1


filetype off				" required

filetype plugin indent on	" required
syntax enable
set background=dark
hi Normal ctermbg=none
filetype indent on

" Color Scheme
color monokai-chris

" Mapping f8 for c++ compiling and executing
map <F8> :!g++ % && ./a.out <CR>

" Setting Tab and indent Widths
" tabs
set tabstop=4
set shiftwidth=4
set softtabstop=0
set noexpandtab
set copyindent
set preserveindent
set smarttab
set autoindent
set smartindent

set title

" http://stackoverflow.com/a/2159997
" display indentation guides
set list listchars=tab:❘-,trail:·,extends:»,precedes:«,nbsp:×
" convert spaces to tabs when reading file
autocmd! bufreadpost * set noexpandtab | retab! 4
" convert tabs to spaces before writing file
" autocmd! bufwritepre * set expandtab | retab! 4
" convert spaces to tabs after writing file (to show guides again)
autocmd! bufwritepost * set noexpandtab | retab! 4


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
