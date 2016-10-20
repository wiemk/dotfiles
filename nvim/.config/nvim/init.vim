" vim windows fix
scriptencoding utf-8
if has('unix')
	if has('nvim')
		" neovim
		let s:config_path='~/.config/nvim/plugged'
	else
		" vim
		let s:config_path='~/.vim/plugged'
	endif
" we blatantly assume windows and vim
else
	let s:config_path='~/vimfiles/plugged'
endif
call plug#begin(s:config_path)
Plug 'flazz/vim-colorschemes'
Plug 'tpope/vim-fugitive'
Plug 'matze/vim-move'
if has('unix')
	Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --bin' }
	Plug 'junegunn/fzf.vim'
endif
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'Raimondi/delimitMate'
Plug 'jiangmiao/auto-pairs'
if has('nvim') && has('python3')
	Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
endif
Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }
call plug#end()

if has('gui_running')
	set guifont=Meslo\ LG\ M:h10
	if &guifont != 'Meslo LG M:h10'
		set guifont=Consolas:h10
			if &guifont != 'Consolas:h10'
				set guifont=DejaVu\ Sans\ Mono:h10
			endif
	endif
	" remove clutter

	set guioptions-=T " no toolbar
	set guioptions-=m " no menus
	set guioptions-=r " no scrollbar on the right
	set guioptions-=R " no scrollbar on the right
	set guioptions-=l " no scrollbar on the left
	set guioptions-=b " no scrollbar on the bottom
	set guioptions=aiA
	set mouse=a
endif

" vim
let mapleader = ","

filetype off
syntax enable
set background=dark
hi Normal ctermbg=none

" Color Scheme
color monokai-chris

" Mapping f8 for c++ compiling and executing
" map <F8> :!g++ % && ./a.out <CR>

" Setting Tab and indent widths
" tabs
set tabstop=4
set shiftwidth=4
set softtabstop=0
set noexpandtab
" indentation
filetype plugin indent on
filetype indent on
" generic smartindent is annoying for non-C filetype
" set smartindent
" copies indent method from previous line
set copyindent
" try tro preserve existing indentation style
set preserveindent
" copy indent from previous line
set autoindent
set title
" can be dangerous but I like modelines
set modeline
" http://stackoverflow.com/a/2159997
" display indentation guides
set list listchars=tab:▸\ ,trail:·,precedes:←,extends:→,eol:↲,nbsp:␣
" line breaks
set wrap
set linebreak
set showbreak=>\ \ \
" make searching case insensitive
set ignorecase
" unless captial letters
set smartcase
" Show current Position
set ruler
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
" minimum values (http://stackoverflow.com/q/22336553)
set winwidth=84
set winheight=5
set winminheight=5
set winheight=30
" some options not set automatically in vim
if !has('nvim')
	set autoread
	set backspace=indent,eol,start
	set complete=.,w,b,u,t
	set display=lastline
	set encoding=utf8
	set formatoptions=tcqj
	set history=10000
	set hlsearch
	set incsearch
	set langnoremap
	set laststatus=2
	set mouse=a
	set nocompatible
	set nrformats=bin,hex
	set sessionoptions=blank,buffers,curdir,folds,help,tabpages,winsize
	set smarttab
	set tabpagemax=50
	set tags=./tags;,tags
	set ttyfast
	set viminfo=!,'100,<50,s10,h
	set wildmenu
endif


" resizing
nnoremap <silent> + :exe "resize " . (winheight(0) * 5/4)<CR>
nnoremap <silent> - :exe "resize " . (winheight(0) * 1/2)<CR>

" Common typos
:command! WQ wq
:command! Wq wq
:command! W w
:command! Q q

" Edit/View files relative to current directory
cnoremap %% <C-R>=expand('%:h').'/'<cr>
map <leader>e :edit %%
map <leader>v :view %%

" tabs
nnoremap <Leader>. :tabn<CR>
nnoremap <Leader>, :tabp<CR>
nnoremap <leader>t :tabnew<CR>
nnoremap <Leader>w :tabclose<CR>

" buffers
nnoremap <Tab> :bnext<CR>
nnoremap <S-Tab> :bprevious<CR>

" use F13 as Esc replacement when in insertmode
imap <F13> <Esc>
vmap <F13> <Esc>

" terminal mode
if has('nvim')
	tmap <Esc> <C-\><C-n>
	tmap <F13> <C-\><C-n>
endif

" use a POSIX compatible shell
if &shell == "/usr/bin/fish"
	set shell=/usr/bin/bash
endif

" strip comments
nnoremap <silent> <Leader>sc :%g/\v^(#\|$)/d<CR>
" replace word below cursor with x
nnoremap <Leader>src :%s/\<<C-r><C-w>\>//g<Left><Left>
" Search and Replace
nnoremap <Leader>s :%s//g<Left><Left>
" Append modeline after last line in buffer.

" arbitrary functions and mappings
function! AppendModeline()
  let l:modeline = printf(" vim: set ts=%d sw=%d sts=%d tw=%d %set :",
		  \ &tabstop, &shiftwidth, &softtabstop, &textwidth, &expandtab ? '' : 'no')
			let l:modeline = substitute(&commentstring, "%s", l:modeline, "")
call append(line("$"), l:modeline)
endfunction

nnoremap <silent> <Leader>ml :call AppendModeline()<CR>

" Relative numbering
function! NumberToggle()
  if(&relativenumber == 1)
	set nornu
	set number
  else
	set rnu
  endif
endfunction

" execute arg and restore windowview
function! KeepEx(arg)
  let l:winview = winsaveview()
  execute a:arg
  call winrestview(l:winview)
endfunction

" don't pollute namespace with global variables if plugin isn't loaded
function! IsPlugActive(arg)
	if(index(g:plugs_order, a:arg) >= 0)
		return 1
	endif
	return 0
endfunction

" strip whitespaces and convert indent spaces to tabs, restore cursor position
function! StripTrailingWhitespace()
		"http://stackoverflow.com/a/7496085
		call KeepEx('%s/\s\+$//e | set noexpandtab | retab! | $put _ | $;?\(^\s*$\)\@!?+1,$d')
endfunction

" use sudo for saving
cnoremap sudow w !sudo tee % > /dev/null

" Toggle between normal and relative numbering.
nnoremap <leader>r :call NumberToggle()<CR>

" Use <C-L> to clear the highlighting of :set hlsearch.
if maparg('<C-x><C-L>', 'n') ==# ''
  nnoremap <silent> <C-x><C-l> :nohlsearch<CR><C-L>
endif

augroup formatting
	autocmd!
	" for all text files set tw to 78
	autocmd FileType text setlocal textwidth=78
	" convert spaces to tabs when reading file
	autocmd BufReadPost * if (&readonly == 0) | set noexpandtab | retab! | endif
	autocmd BufWritePre * if(&readonly == 0) | call StripTrailingWhitespace() | endif
augroup end

" autoreload config file on save
augroup vimrc
	autocmd!
	autocmd BufWritePost init.vim source %
	autocmd BufWritePost .vimrc source %
augroup end

nnoremap <silent> <Leader>sw :call StripTrailingWhitespace()<CR>

" vim-plug
command! PU PlugUpdate | PlugUpgrade

" NERDTree
nmap <silent> <Leader>n :NERDTreeToggle<CR>
" close buffer without messing up layout
nnoremap <leader>q :bp<CR>:bd #<CR>
let g:NERDTreeChristmasTree = 1
let g:NERDTreeShowHidden = 1
let g:NERDTreeHijackNetrw = 1
let g:NERDTreeQuitOnOpen = 1
let g:NERDTreeDirArrows = 1
let g:NERDTreeChDirMode = 2

" fzf
if(IsPlugActive('fzf'))
	set rtp+=~/.fzf
	let g:fzf_prefer_tmux = 0
	let g:fzf_colors =
	\ { 'fg':		['fg', 'Normal'],
	  \ 'bg':		['bg', 'Normal'],
	  \ 'hl':		['fg', 'Comment'],
	  \ 'fg+':		['fg', 'CursorLine', 'CursorColumn', 'Normal'],
	  \ 'bg+':		['bg', 'CursorLine', 'CursorColumn'],
	  \ 'hl+':		['fg', 'Statement'],
	  \ 'info':		['fg', 'PreProc'],
	  \ 'prompt':	['fg', 'Conditional'],
	  \ 'pointer':	['fg', 'Exception'],
	  \ 'marker':	['fg', 'Keyword'],
	  \ 'spinner':	['fg', 'Label'],
	  \ 'header':	['fg', 'Comment'] }
	let g:fzf_layout = { 'down': '~40%' }
	let g:fzf_history_dir = '~/.local/share/fzf-history'

	" Mapping selecting mappings
	nmap <leader><tab> <plug>(fzf-maps-n)
	xmap <leader><tab> <plug>(fzf-maps-x)
	omap <leader><tab> <plug>(fzf-maps-o)
	" Insert mode completion
	imap <c-x><c-k> <plug>(fzf-complete-word)
	imap <c-x><c-f> <plug>(fzf-complete-path)
	imap <c-x><c-j> <plug>(fzf-complete-file-ag)
	imap <c-x><c-l> <plug>(fzf-complete-line)

	nmap <leader>f :Files<CR>
	nmap <leader>b :Buffers<CR>
endif

" vim-move
let g:move_key_modifier = 'M'

" deoplete
if(IsPlugActive('deoplete.nvim'))
	" let g:deoplete#enable_at_startup = 1
	call deoplete#enable()
	let g:deoplete#enable_smart_case = 1
	autocmd! InsertLeave,CompleteDone * if pumvisible() == 0 | pclose | endif
endif

" delimitMate
" seems bugged
" let delimitMate_expand_cr = 1

" vim-airline
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#left_sep = ' '
let g:airline#extensions#tabline#left_alt_sep = '|'
" vim: set ts=4 sw=4 sts=0 tw=78 noet :
