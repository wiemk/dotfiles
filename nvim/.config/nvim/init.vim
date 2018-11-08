scriptencoding utf-8
" seems to break some plugins
" set noshellslash
if v:version < 800 | finish | endif
if &term == 'win32'
	set termencoding=cp932
endif
" Variables {{{
let g:theme = $NVIM_THEME
let g:text_width = 100
let s:use_fzf = 1
let s:ignore_ft = [
			\ 'gitcommit', 'gitrebase', 'hgcommit']
"}}}
" Environment and default options {{{
" make sure to export VIMINIT=
" let $MYVIMRC="$XDG_CONFIG_HOME/vim/vimrc" | source $MYVIMRC
if !exists('$HOME') && has('win32')
	let $HOME = $LOCALAPPDATA
endif

let $XDG_DATA_HOME =
			\ exists('$XDG_DATA_HOME') ? $XDG_DATA_HOME
			\ : ($HOME . '/.local/share')
let $XDG_CACHE_HOME =
			\ exists('$XDG_CACHE_HOME') ? $XDG_CACHE_HOME
			\ : ($HOME . '/.cache')
let $XDG_CONFIG_HOME =
			\ exists('$XDG_CONFIG_HOME') ? $XDG_CONFIG_HOME
			\ : ($HOME . '/.config')
if !isdirectory($XDG_CACHE_HOME . '/vim')
	call mkdir($XDG_CACHE_HOME . '/vim', "p")
endif

if has('nvim')
	let s:pack_path = $XDG_DATA_HOME . '/nvim'
else
	if (has('win32') && !has('nvim'))
		language english
		language time german
	endif
	" neovim defaults, set explicitly in vim
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

	set directory=$XDG_CACHE_HOME/vim
	set backupdir=$XDG_CACHE_HOME/vim
	set viminfo+=n$XDG_CACHE_HOME/vim/viminfo
	set runtimepath=$XDG_DATA_HOME/vim/site,$XDG_CONFIG_HOME/vim,$XDG_CONFIG_HOME/vim/after,$VIM,$VIMRUNTIME
	let $MYVIMRC = "$XDG_CONFIG_HOME/vim/vimrc"
	let s:pack_path = $XDG_DATA_HOME . '/vim'
endif
"}}}
" minpac {{{

function! Bootstrap()
	call PackInit()
	call minpac#update('', {'do': 'call minpac#status()'})
	if has('nvim') | UpdateRemotePlugins | endif
	sleep 10
	source $MYVIMRC
endfunction

let &packpath = s:pack_path . ',' . &packpath
let s:minpac_path = s:pack_path . '/pack/minpac/opt/minpac'
silent! packadd minpac
if !exists('*minpac#init')  && executable('git')
	if !isdirectory(s:minpac_path)
		call mkdir(s:minpac_path, 'p')
	endif
	exe 'silent !git clone "https://github.com/k-takata/minpac.git" ' . s:minpac_path
	autocmd! VimEnter * call Bootstrap()
endif

function! PackInit() abort
	packadd minpac
	call minpac#init()

	call minpac#add('k-takata/minpac', {'type': 'opt'})
	call minpac#add('mhartington/oceanic-next')
	call minpac#add('lifepillar/vim-solarized8')
	call minpac#add('vim-airline/vim-airline')
	call minpac#add('vim-airline/vim-airline-themes')
	call minpac#add('tpope/vim-fugitive')
	call minpac#add('matze/vim-move')
	call minpac#add('airblade/vim-gitgutter')
	call minpac#add('easymotion/vim-easymotion')
	call minpac#add('justinmk/vim-dirvish')
	call minpac#add('tpope/vim-eunuch')

	" fzf doesn't compile unter windows for now
	if has('unix') && s:use_fzf
		if executable('fzf')
			call minpac#add('junegunn/fzf')
		else
			call minpac#add('junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --bin' })
		endif
		call minpac#add('junegunn/fzf.vim')
	else
		call minpac#add('ctrlpvim/ctrlp.vim', { 'on': ['CtrlP', 'CtrlPBuffer', 'CtrlPMixed', 'CtrlPMRU'] })
	endif

	if has('win32')
		let g:vimproc_path = expand(fnamemodify(v:progpath, ':h')
					\ . '\plugins\vimproc')
		if(isdirectory(g:vimproc_path))
			call minpac#add(g:vimproc_path)
		else
			let g:vimproc#download_windows_dll = 1
			call minpac#add('Shougo/vimproc.vim')
		endif
	elseif has('unix') && !has('nvim')
		call minpac#add('Shougo/vimproc.vim', { 'do' : 'make' })
	endif

	let s:completion_provider = 0
	if has('nvim')
		if has('python3')
			let s:completion_provider = 1
			call minpac#add('Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' })
		endif
	else
		if has('lua')
			let s:completion_provider = 1
			call minpac#add('Shougo/neocomplete.vim')
		endif
	endif
	if s:completion_provider
		call minpac#add('Shougo/neco-vim')
	endif
endfunction

command! PU call PackInit() | call minpac#update('', {'do': 'call minpac#status()'})
command! PC call PackInit() | call minpac#clean()
command! PS call PackInit() | call minpac#status()
"}}}
" general settings {{{
let mapleader = "\<Space>"
nmap , <Space>
" change to folder of file in buffer
set autochdir
" UTG-8 bom
set nobomb
filetype off
syntax enable
set background=dark
highlight Normal ctermbg=none
" message
set shortmess+=a
set confirm
set title
" beep
set errorbells
set novisualbell
set t_vb=
" timeout
set timeoutlen=3000
set ttimeoutlen=10
set updatetime=1000
" modeline
set showfulltag
set modeline
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
" Set No backups
set nobackup
set nowb
set noswapfile
" minimum values (http://stackoverflow.com/q/22336553)
set winwidth=84
set winheight=5
set winminheight=5
set winheight=30
" allow switching buffers without saving
set hidden
" only redraw when something was typed
set lazyredraw
" Conceal
set conceallevel=2
set concealcursor=nc
" folds
"set foldlevel=1
set foldmethod=marker
set foldlevelstart=0

" clipBoard
set clipboard=unnamed
if has('unnamedplus')
	set clipboard^=unnamedplus
endif

" use a POSIX compatible shell
if(!has('nvim') && &shell == "/usr/bin/fish")
	set shell=/usr/bin/bash
endif
"}}}
" undo file {{{
set undofile
set undodir^=$XDG_CACHE_HOME/vimundo
if !isdirectory($XDG_CACHE_HOME . '/vimundo')
	call mkdir($XDG_CACHE_HOME . '/vimundo', 'p')
endif
autocmd! BufWritePre *
			\ let &undofile = index(s:ignore_ft, &filetype) < 0
"}}}
" utility functions {{{
" execute arg and restore window view
function! s:keep_ex(arg)
	let l:winview = winsaveview()
	execute a:arg
	call winrestview(l:winview)
endfunction

" don't pollute namespace with global variables if plugin isn't loaded
" and try to not initialize minpac if it isn't needed
function! s:is_module_in_path(module)
	let l:module = map(split(&runtimepath, ','), 'fnamemodify(v:val, ":t")')
	 return index(l:module, a:module) >= 0
endfunction

function! s:is_plug_enabled(module)
	if !exists('*minpac#init')
		return 0
	endif
	let l:plug_list = minpac#getpackages("minpac", "", a:module, 1)
	return empty(l:plug_list)
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
"}}}
" vimproc without vim-plug {{{
" manually managed vimproc, replaced with vim-plug
"if has('win32') && !s:has_vimproc() "!exists(':VimProcBang')
"	let s:plugin_contrib = fnamemodify(v:progpath, ':h') . '\plugins\vimproc'
"	if isdirectory(s:plugin_contrib)
"		let g:vimproc#download_windows_dll = 0
"		let &rtp .= ','.s:plugin_contrib
"	else
"		let g:vimproc#download_windows_dll = 1
"	endif
"endif
"let s:completion_provider = 0
"}}}
" gvim options {{{
if has('gui_running')
	if (!has('unix') && !has('nvim'))
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
"}}}
" colorscheme and style {{{
" info {{{
" ensure that the highlight group gets created and
" is not cleared by future colorscheme commands
"augroup ColorScheme
"	autocmd!
"	autocmd ColorScheme * highlight CursorLine cterm=bold ctermbg=NONE ctermfg=NONE gui=bold guibg=NONE guifg=NONE
"augroup end
"}}}

let s:set_termguicolors = 0
let s:stheme = [ 'solarized8', 'solarized8_flat', 'solarized8_low', 'solarized8_high', 'OceanicNext' ]

function! s:is_valid_theme()
	 return index(s:stheme, g:theme) >= 0
endfunction

function! s:is_term_truecolor()
	" VTE, iTerm2, Konsole, ..
	if $COLORTERM =~ 'truecolor' | return 1 | endif
	if $COLORTERM =~ '24bit' | return 1 | endif
	" WSL terminal
	if !empty(glob("/dev/lxss")) | return 1 | endif
	" manual override
	if $FORCE_TC == 1 | return 1 | endif
	return 0
endfunction

if exists('+termguicolors')
	if s:is_term_truecolor()
		if(!has('nvim'))
			let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
			let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
		endif
		set termguicolors
		let s:set_termguicolors = 1
	endif
endif

if !s:is_valid_theme()
	let g:theme = 'solarized8_flat'
endif

"determine the best colorscheme based on terminal color support
if g:theme == 'OceanicNext'
		" enable italics, disabled by default
		let g:oceanic_next_terminal_italic = 1
		" enable bold, disabled by default
		let g:oceanic_next_terminal_bold = 1
endif

" force 16 colors for better consistency in non-truecolor terminals
" needs solarized terminal colors or it will look wrong
if g:theme =~ 'solarized8*' && !s:set_termguicolors
	let g:solarized_use16 = 1
endif

if &t_Co == 16
	let g:solarized_use16 = 1
	let g:theme = 'solarized8_flat'
endif
" set the determined scheme
exe 'silent! colorscheme '.g:theme
"set cursorcolumn
highlight CursorLine cterm=bold gui=bold

" http://stackoverflow.com/a/2159997
" display indentation guides
set list listchars=eol:¬,tab:\^\ ,trail:~,extends:>,precedes:<
"Invisible character colors
highlight NonText guifg=#4a4a59
highlight SpecialKey guifg=#4a4a59
"}}}
" colorcolumn alternative {{{
" http://superuser.com/a/771555
" highlight ExceedingColumnWidth ctermbg=darkgreen guibg=darkgreen
"call matchadd('ExceedingColumnWidth', '\%79v', 100)
"}}}
" highlight whitespaces {{{
" http://vim.wikia.com/wiki/Highlight_unwanted_spaces
highlight ExtraWhitespace ctermbg=darkgreen guibg=darkgreen
augroup WhitespaceMatch
	autocmd!
	autocmd BufWinEnter,InsertLeave * call s:ToggleWhitespaceMatch('n')
	autocmd BufWinLeave * call s:ToggleWhitespaceMatch('c')
	autocmd InsertEnter * call s:ToggleWhitespaceMatch('i')
augroup end

function! s:ToggleWhitespaceMatch(mode)
	if a:mode == 'i'
		let l:pattern = [ '[^\t]\zs\t\+', '\s\+$\| \+\ze\t' ]
	elseif a:mode == 'n'
		let l:pattern = [ '\s\+$' ]
	else
		let l:pattern = []
		let w:ws_id = []
	endif
	if(!exists('w:ws_id'))
		let w:ws_id = []
	endif
	if(!empty(w:ws_id))
		call map(w:ws_id, 'matchdelete(v:val)')
		unlet w:ws_id[:]
	endif
	call map(l:pattern, 'add(w:ws_id, matchadd("ExtraWhitespace", v:val, 10))')
endfunction

"}}}
" tabs and indentation {{{
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
"}}}
" linebreaks and linewrap {{{
" line widths, let the user decide what textwidth he prefers
" and derive everything else from it
" set colorcolumn to textwidth + 1 in current buffer
setlocal colorcolumn=+1
" wrap around visually without modifying the buffer
set wrap
set linebreak
set showbreak=>\ \ \
set wrapmargin=0
" don't let vim repeatedly reformat the line while we are typing but show some
" initial effort to break the line
set formatoptions+=l
"set formatoptions-=t
"}}}
" info {{{
augroup FoldMarkers
	autocmd!
	autocmd FileType vim setlocal foldmethod=marker foldmarker={{{,}}}
augroup end
"}}}
" help mappings {{{
function! s:help_mappings()
	nmap <buffer> <CR> <C-]>
	nmap <buffer> <BS> <C-T>
	nmap <buffer> o /''[a-z]\{2,\}''<CR>
	nmap <buffer> O ?''[a-z]\{2,\}''<CR>
	nmap <buffer> s /\|\S\+\|<CR>
	nmap <buffer> S ?\|\S\+\|<CR>
endfunction

augroup HelpKeys
	autocmd!
	autocmd FileType help :call s:help_mappings()
augroup end
"}}}
" various mappings {{{
nnoremap <silent> + :exe "resize " . (winheight(0) * 5/4)<CR>
nnoremap <silent> - :exe "resize " . (winheight(0) * 1/2)<CR>
nnoremap <silent><leader>y :set lines=50 columns=200<CR>

" Common typos
cabbr WQ wq
cabbr Wq wq
cabbr wQ wq
cabbr W w
cabbr Q q

" Edit/View files relative to current directory
cnoremap %% <C-R>=expand('%:h').'/'<cr>
map <leader>e :edit %%
map <leader>v :view %%

" tabs
nnoremap <leader>. :tabn<CR>
nnoremap <leader>, :tabp<CR>
nnoremap <leader>t :tabnew<CR>
nnoremap <leader>w :tabclose<CR>

" buffers
nnoremap <Tab> :bnext<CR>
nnoremap <S-Tab> :bprevious<CR>

" use F13 as Esc replacement when in insert mode
imap <F13> <Esc>
vmap <F13> <Esc>

" terminal mode
"if has('nvim')
"	tmap <Esc> <C-\><C-n>
"	tmap <F13> <C-\><C-n>
"endif

" use <C-L> to clear the highlighting of :set hlsearch.
if maparg('<C-x><C-l>', 'n') ==# ''
	nnoremap <silent> <C-x><C-l> :nohlsearch<CR><C-L>
endif

" strip comments
nnoremap <silent> <leader>sc :%g/\v^(#\|$)/d<CR>
" replace word below cursor with x
nnoremap <leader>src :%s/\<<C-r><C-w>\>//g<Left><Left>
" Search and Replace
nnoremap <leader>s :%s//g<Left><Left>

" use sudo for saving
cnoremap w!! execute 'silent! write !sudo tee % >/dev/null' <bar> edit!

nnoremap <leader>cc :set number!<CR>
" Toggle whitespace characters
nnoremap <leader>ll :set list!<CR>
"}}}
" mapped functions & autocommands {{{
function! AppendModeline()
	let l:modeline = printf(" vim: set ft=%s ts=%d sw=%d sts=%d tw=%d %set :",
				\ &filetype, &tabstop, &shiftwidth, &softtabstop, &textwidth, &expandtab ? '' : 'no')
	let l:modeline = substitute(&commentstring, "%s", l:modeline, "")
	call append(line("$"), l:modeline)
endfunction
" Append modeline after last line in buffer.
nnoremap <silent> <leader>ml :call AppendModeline()<CR>

" relative numbering
function! NumberToggle()
	if(&relativenumber == 1)
		set nornu
		set number
	else
		set rnu
	endif
endfunction
" Toggle between normal and relative numbering.
nnoremap <leader>r :call NumberToggle()<CR>

" strip whitespaces and convert indent spaces to tabs, restore cursor position
function! StripTrailingWhitespaces()
	"http://stackoverflow.com/a/7496085
	call s:keep_ex('%s/\s\+$//e | set noexpandtab | retab! | $put _'
				\. ' | $;?\(^\s*$\)\@!?+1,$d')
endfunction
nnoremap <silent> <leader>sw :call StripTrailingWhitespaces()<CR>

augroup formatting
	autocmd!
	" for all text files set tw to 78
	autocmd FileType text setlocal textwidth=78
	autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab
	" convert spaces to tabs when reading file
"	autocmd BufReadPost * if (&readonly == 0) | set noexpandtab | retab! | endif
"	autocmd BufWritePre * if(&readonly == 0) | call StripTrailingWhitespaces() | endif
augroup end

" source vim configuration upon save
" let s:my_vimrc = fnamemodify($MYVIMRC, ":t")
augroup vimrc
	autocmd!
	execute 'autocmd BufWritePost ' . $MYVIMRC . ' source % | redraw
				\ | echom "Reloaded " . expand("%:p")'
	execute 'autocmd BufWritePost ' . $MYGVIMR . ' if has("gui_running")
				\ | source % | redraw | echom "Reloaded " . expand("%:p") | endif'
augroup end
"}}}
" plugins: {{{
" vim-gitgutter {{{
if(s:is_module_in_path('vim-gitgutter'))
	let g:gitgutter_avoid_cmd_prompt_on_windows = 0
endif
"}}}
" vim-dirvish {{{
if(s:is_module_in_path('vim-dirvish'))
	" disable bloated netrw
	let g:loaded_netrw = 1
	let g:loaded_netrwPlugin = 1

    command! -nargs=? -complete=dir Explore Dirvish <args>
    command! -nargs=? -complete=dir Sexplore belowright split | silent Dirvish <args>
    command! -nargs=? -complete=dir Vexplore leftabove vsplit | silent Dirvish <args>
	
	" not supported
	set noautochdir
	let g:dirvish_mode = 2
	let g:dirvish_relative_paths = 1
	
	nnoremap <buffer> <silent> <leader>t :call dirvish#open('tabedit', 0)<CR>
	xnoremap <buffer> <silent> <leader>t :call dirvish#open('tabedit', 0)<CR>
	" close buffer without messing up layout
	nnoremap <leader>q :bp<CR>:bd #<CR>

	"}}}
	" ctrlp {{{
	if(s:is_module_in_path('ctrlp.vim'))
		"	let g:ctrlp_cache_dir = $HOME . '/.cache/ctrlp'
		let g:ctrlp_use_caching = 1
		let g:ctrlp_clear_cache_on_exit = 0
		let g:ctrlp_show_hidden = 1
		"	let g:ctrlp_working_path_mode = 0
		if(has('unix') && executable('ag'))
			let g:ctrlp_user_command = 'ag %s -l --nocolor -g ""'
		elseif(has('win32') && executable('dir'))
			let g:ctrlp_user_command = 'dir %s /-n /b /s /a-d'
		endif
		let g:ctrlp_extensions = [
					\ 'mixed',
					\ 'dir',
					\ 'quickfix',
					\ 'undo',
					\ 'changes'
					\]

		nnoremap <leader>f :CtrlP<CR>
		nnoremap <leader>b :CtrlPBuffer<CR>
		nnoremap <leader>a :CtrlPMixed<CR>
		nnoremap <leader>m :CtrlPMRU<CR>
	endif
endif
"}}}
" fzf {{{
if(s:is_module_in_path('fzf'))
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
	let g:fzf_buffers_jump = 1

	" show hidden files
	if executable('ag')
		let $FZF_DEFAULT_COMMAND = 'ag --hidden --ignore .git -g ""'
	elseif executable('find')
		let $FZF_DEFAULT_COMMAND =
					\ "find . -path \'.\' -o -type f -print -o -type l -print 2> /dev/null"
	endif

	" mapping selecting mappings
	nmap <leader><tab> <plug>(fzf-maps-n)
	xmap <leader><tab> <plug>(fzf-maps-x)
	omap <leader><tab> <plug>(fzf-maps-o)
	" insert mode completion
	imap <c-x><c-k> <plug>(fzf-complete-word)
	imap <c-x><c-f> <plug>(fzf-complete-path)
	imap <c-x><c-j> <plug>(fzf-complete-file-ag)
	imap <c-x><c-l> <plug>(fzf-complete-line)

	nmap <leader>f :Files<CR>
	nmap <leader>b :Buffers<CR>
endif
"}}}
" vim-move {{{
let g:move_key_modifier = 'M'
execute 'vmap' '<' . g:move_key_modifier . '-Down>' '<Plug>MoveBlockDown'
execute 'vmap' '<' . g:move_key_modifier . '-Up>' '<Plug>MoveBlockUp'
execute 'nmap' '<' . g:move_key_modifier . '-Down>' '<Plug>MoveLineDown'
execute 'nmap' '<' . g:move_key_modifier . '-Up>' '<Plug>MoveLineUp'
"}}}
" vim-airline {{{
let g:airline_powerline_fonts = 0
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#left_sep = ' '
let g:airline#extensions#tabline#left_alt_sep = '|'
if s:is_module_in_path('oceanic-next')
	if g:theme == 'OceanicNext'
		let g:airline_theme='oceanicnext'
	endif
elseif s:is_module_in_path('vim-solarized8')
	if g:theme =~ 'solarized8*'
		let g:airline_theme='solarized'
	endif
endif
"}}}
" neocomplete {{{
if(s:is_module_in_path('neocomplete.vim'))
	let g:neocomplete#enable_at_startup = 1
	" increases screen flicker
	let g:neocomplete#enable_refresh_always = 0
	let g:neocomplete#max_list = 30
	" don't select anything automatically
	let g:neocomplete#enable_auto_select = 1
	let g:neocomplete#enable_smart_case = 1
	let g:neocomplete#min_keyword_length = 1
	let g:neocomplete#sources#syntax#min_keyword_length = 3
	let g:neocomplete#enable_auto_select = 0
	let g:neocomplete#enable_fuzzy_completion = 1
	let g:neocomplete#enable_auto_delimiter = 1
	if s:is_module_in_path('vimproc')
		let g:neocomplete#use_vimproc = 1
	endif
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
"}}}
" deoplete {{{
if(s:is_module_in_path('deoplete.nvim'))
	let g:deoplete#enable_at_startup = 1
	let g:deoplete#enable_refresh_always = 0
	let g:deoplete#max_list = 30
	" don't select anything automatically
	let g:deoplete#enable_auto_select = 0

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
"}}}
" auto-pairs {{{
if(s:is_module_in_path('auto-pairs'))
	if(s:is_module_in_path('neocomplete.vim') || s:is_module_in_path('deoplete.nvim'))
		let g:AutoPairsMapCR = 0
		imap <expr><CR> pumvisible() ?	"\<C-y>" :	"\<CR>\<Plug>AutoPairsReturn"
	endif
endif
"}}}
" easymotion {{{
" https://code.tutsplus.com/tutorials/vim-essential-plugin-easymotion--net-19223
" <Leader>f{char} to move to {char}
" map  <Leader>f <Plug>(easymotion-bd-f)
" nmap <Leader>f <Plug>(easymotion-overwin-f)
"
" " s{char}{char} to move to {char}{char}
" nmap s <Plug>(easymotion-overwin-f2)
"
"" Move to line
" map <Leader>L <Plug>(easymotion-bd-jk)
" nmap <Leader>L <Plug>(easymotion-overwin-line)

" Move to word
" map  <Leader>w <Plug>(easymotion-bd-w)
" nmap <Leader>w <Plug>(easymotion-overwin-w)
" "

"}}}
" eunuch {{{
"	Delete: Delete a buffer and the file on disk simultaneously.
"	:Unlink: Like :Delete, but keeps the now empty buffer.
"	:Move: Rename a buffer and the file on disk simultaneously.
"	:Rename: Like :Move, but relative to the current file's containing directory.
"	:Chmod: Change the permissions of the current file.
"	:Mkdir: Create a directory, defaulting to the parent of the current file.
"	:Cfind: Run find and load the results into the quickfix list.
"	:Clocate: Run locate and load the results into the quickfix list.
"	:Lfind/:Llocate: Like above, but use the location list.
"	:Wall: Write every open window. Handy for kicking off tools like guard.
"	:SudoWrite: Write a privileged file with sudo.
"	:SudoEdit: Edit a privileged file with sudo.
"	File type detection for sudo -e is based on original file name.
"	New files created with a shebang line are automatically made executable.
"	New init scripts are automatically prepopulated with /etc/init.d/skeleton.
"}}}
" customization: {{{
function! SourceIfExists(file)
	if filereadable(expand(a:file))
		exe 'source' a:file
    endif
endfunction
let g:vimrc_local_base = fnamemodify(resolve(expand('$MYVIMRC:p:h')), ':h')

call SourceIfExists(g:vimrc_local_base . '/local.vim')
"}}}
" vim: set ts=4 sw=4 sts=0 tw=78 noet :
