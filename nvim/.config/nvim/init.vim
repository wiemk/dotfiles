scriptencoding utf-8
let s:use_fzf=0
" Environment
if has('nvim')
	" neovim
	let s:plug_path='~/.config/nvim/plugged'
else
	" neovim defaults, set explicitly in vim
	" make sure to export VIMINIT=
	" let $MYVIMRC="$XDG_CONFIG_HOME/vim/vimrc" | source $MYVIMRC
	" language
	if has('win32')
		language english
		language time german
	endif
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
	set wildmenu
	set viminfo=!,'100,<50,s10,h

	" XDG Base Directory
	"let $XDG_DATA_HOME =
	"			\ exists('$XDG_DATA_HOME')	 ? $XDG_DATA_HOME	: ($HOME . '/.local/share')
	"let $XDG_CACHE_HOME =
	"			\ exists('$XDG_CACHE_HOME')  ? $XDG_CACHE_HOME	: ($HOME . '/.cache')
	"let $XDG_CONFIG_HOME =
	"			\ exists('$XDG_CONFIG_HOME') ? $XDG_CONFIG_HOME : ($HOME . '/.config')

	" vim Environment, for simplicity we expect properly set XDG vars
	if exists("$XDG_CACHE_HOME") && exists("$XDG_CONFIG_HOME")
		if !isdirectory($XDG_CACHE_HOME . '/vim')
			call mkdir($XDG_CACHE_HOME . '/vim', "p")
		endif
		let s:plug_path="$XDG_CONFIG_HOME/vim/plugged"
		set directory=$XDG_CACHE_HOME/vim
		set backupdir=$XDG_CACHE_HOME/vim
		set viminfo+=n$XDG_CACHE_HOME/vim/viminfo
		set runtimepath=$XDG_CONFIG_HOME/vim,$XDG_CONFIG_HOME/vim/after,$VIM,$VIMRUNTIME
		let $MYVIMRC="$XDG_CONFIG_HOME/vim/vimrc"
	else
		" no XDG paths set, set only the most necessary paths
		if has('unix')
			let s:config_path='~/.vim/plugged'
		else "has('win32')
			let s:config_path='~/vimfiles/plugged'
		endif
	endif
endif

" don't pollute namespace with global variables if plugin isn't loaded
function! s:is_plug_active(arg)
	if(index(g:plugs_order, a:arg) >= 0)
		return 1
	endif
	return 0
endfunction

" Check vimproc
function! s:has_vimproc() abort
	if !exists('s:_has_vimproc')
		try
		call vimproc#version()
			let s:_has_vimproc = 1
		catch
			let s:_has_vimproc = 0
		endtry
	endif
	return s:_has_vimproc
endfunction

" special win32 build
if has('win32') && !s:has_vimproc() "!exists(':VimProcBang')
	let s:plugin_contrib = fnamemodify(v:progpath, ':h') . '\plugins\vimproc'
	if isdirectory(s:plugin_contrib)
		let g:vimproc#download_windows_dll = 0
		let &rtp .= ','.s:plugin_contrib
	else
		let g:vimproc#download_windows_dll = 1
	endif
endif
let s:completion_provider = 0

""" PLUGIN LOADING
call plug#begin(s:plug_path)
Plug 'flazz/vim-colorschemes'
Plug 'tpope/vim-fugitive'
Plug 'matze/vim-move'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'jiangmiao/auto-pairs'
Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }

if has('unix') && s:use_fzf
	Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --bin' }
	Plug 'junegunn/fzf.vim'
else
	Plug 'ctrlpvim/ctrlp.vim', { 'on': ['CtrlP', 'CtrlPBuffer', 'CtrlPMixed', 'CtrlPMRU'] }
endif

if has('unix') && has('nvim')
	" build manually
	Plug 'Shougo/vimproc.vim', { 'do' : 'make' }
endif

if has('win32') && g:vimproc#download_windows_dll
	" win32, do not build manually, try downloading the dll
	Plug 'Shougo/vimproc.vim'
endif

if has('nvim')
	if has('python3')
		let s:completion_provider=1
		Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
	endif
else
	if has('lua')
		let s:completion_provider=1
		Plug 'Shougo/neocomplete.vim'
	endif
endif
if s:completion_provider == 1
	Plug 'Shougo/neco-vim'
endif

call plug#end()
""" END LOADING

if has('gui_running')
	set lines=50 columns=200
	if !has('unix')
		set renderoptions=type:directx
	endif
	silent!	set guifont=Meslo\ LG\ M:h9
	if &guifont != 'Meslo LG M:h9'
		silent! set guifont=DejaVu\ Sans\ Mono:h10
	endif
	" remove clutter
	set guioptions-=T " no toolbar
	set guioptions-=m " no menus
	set guioptions-=r " no scrollbar on the right
	set guioptions-=R " no scrollbar on the right
	set guioptions-=l " no scrollbar on the left
	set guioptions-=b " no scrollbar on the bottom
	set guioptions=aiA
	set guicursor+=a:blinkon0
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
set list listchars=eol:¬,tab:\^\ ,trail:~,extends:>,precedes:<
"Invisible character colors
highlight NonText guifg=#4a4a59
highlight SpecialKey guifg=#4a4a59
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

" use F13 as Esc replacement when in insert mode
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

" execute arg and restore window view
function! s:keep_ex(arg)
	let l:winview = winsaveview()
	execute a:arg
	call winrestview(l:winview)
endfunction

" strip whitespaces and convert indent spaces to tabs, restore cursor position
function! StripTrailingWhitespace()
	"http://stackoverflow.com/a/7496085
	call s:keep_ex('%s/\s\+$//e | set noexpandtab | retab! | $put _ | $;?\(^\s*$\)\@!?+1,$d')
endfunction

" use sudo for saving
cnoremap sudow w !sudo tee % > /dev/null

" Toggle between normal and relative numbering.
nnoremap <leader>r :call NumberToggle()<CR>
nnoremap <leader>cc :set number!<CR>
" Toggle whitespace characters
nnoremap <leader>ll :set list!<CR>

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
	autocmd BufWritePost _vimrc source %
	autocmd BufWritePost vimrc source %
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

if(s:is_plug_active('ctrlp.vim'))
	"	let g:ctrlp_cache_dir = $HOME . '/.cache/ctrlp'
	let g:ctrlp_clear_cache_on_exit = 0
	let g:ctrlp_show_hidden = 1
	"	let g:ctrlp_working_path_mode = 0
	if has('unix') && executable('ag')
		let g:ctrlp_user_command = 'ag %s -l --nocolor -g ""'
	endif

	nnoremap <leader>f :CtrlP<CR>
	nnoremap <leader>b :CtrlPBuffer<CR>
	nnoremap <leader>a :CtrlPMixed<CR>
	nnoremap <leader>m :CtrlPMRU<CR>
endif

" fzf
if(s:is_plug_active('fzf'))
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
execute 'vmap' '<' . g:move_key_modifier . '-Down>' '<Plug>MoveBlockDown'
execute 'vmap' '<' . g:move_key_modifier . '-Up>' '<Plug>MoveBlockUp'
execute 'nmap' '<' . g:move_key_modifier . '-Down>' '<Plug>MoveLineDown'
execute 'nmap' '<' . g:move_key_modifier . '-Up>' '<Plug>MoveLineUp'

" vim-airline
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#left_sep = ' '
let g:airline#extensions#tabline#left_alt_sep = '|'

" neocomplete
if(s:is_plug_active('neocomplete.vim'))
	let g:neocomplete#enable_at_startup = 1
	" increases screen flicker
	let g:neocomplete#enable_refresh_always = 0
	let g:neocomplete#max_list = 30
	let g:neocomplete#enable_auto_select = 1
	let g:neocomplete#enable_smart_case = 1
	let g:neocomplete#min_keyword_length = 1
	let g:neocomplete#sources#syntax#min_keyword_length = 3
	"	let g:neocomplete#enable_auto_select = 0
	let g:neocomplete#enable_fuzzy_completion = 1
	let g:neocomplete#enable_auto_delimiter = 1
	"	" Define keyword.
	if !exists('g:neocomplete#keyword_patterns')
		let g:neocomplete#keyword_patterns = {}
	endif
	let g:neocomplete#keyword_patterns._ = '\h\k*(\?'
	if !exists('g:neocomplete#sources#omni#input_patterns')
		let g:neocomplete#sources#omni#input_patterns = {}
	endif
	inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"
endif

" deoplete
if(s:is_plug_active('deoplete.nvim'))
	let g:deoplete#enable_at_startup = 1
	let g:deoplete#enable_refresh_always = 0
	let g:deoplete#max_list = 30
	let g:deoplete#enable_auto_select = 1

	if !exists('g:deoplete#keyword_patterns')
		let g:deoplete#keyword_patterns = {}
	endif
	let g:deoplete#keyword_patterns._ = '[a-zA-Z_]\k*\(?'
	" call deoplete#enable()
	let g:deoplete#enable_smart_case = 1
	if !exists('g:deoplete#omni#input_patterns')
		let g:deoplete#omni#input_patterns = {}
	endif
	inoremap <expr><TAB> pumvisible() ? "\<C-n>" : "\<TAB>"
	" close window after completion
	autocmd! InsertLeave,CompleteDone * if pumvisible() == 0 | pclose | endif
endif

" auto-pairs
if(s:is_plug_active('auto-pairs'))
	if(s:is_plug_active('neocomplete.vim') || s:is_plug_active('deoplete.nvim'))
		let g:AutoPairsMapCR = 0
		imap <expr><CR> pumvisible() ?	"\<C-y>" :	"\<CR>\<Plug>AutoPairsReturn"
	endif
endif

"EOF
" vim: set ts=4 sw=4 sts=0 tw=78 noet :
