call plug#begin('~/.config/nvim/plugged')
Plug 'Raimondi/delimitMate'
Plug 'jiangmiao/auto-pairs'
"Plug 'chriskempson/base16-vim'
"Plug 'tpope/vim-fugitive'
Plug 'matze/vim-move'
"Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }
"Plug 'fatih/vim-go', { 'for': 'go' }
Plug 'flazz/vim-colorschemes'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
call plug#end()

" vim
let mapleader = ","
filetype off
syntax enable
set background=dark
hi Normal ctermbg=none

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
set smarttab

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
set list listchars=tab:→\ ,trail:·,extends:»,precedes:«,nbsp:×

" for all text files set tw to 78
autocmd FileType text setlocal textwidth=78

" dangerous and silly stuff below
" convert spaces to tabs when reading file
autocmd! BufReadPost * set noexpandtab | retab! 4
" convert tabs to spaces before writing file
" autocmd! bufwritepre * set expandtab | retab! 4
" convert spaces to tabs after writing file (to show guides again)
autocmd! BufWritePost * set noexpandtab | retab! 4
" strip trailing whitespaces
autocmd! BufWritePre * %s/\s\+$//e
" http://stackoverflow.com/a/7496085
autocmd! BufWritePre * $put _ | $;?\(^\s*$\)\@!?+1,$d
" end dangerous stuff

set wrap
set linebreak
set showbreak=>\ \ \

" Highlight search results
set hlsearch
" make searching case insensitive
set ignorecase
" unless captial letters
set smartcase
" Show current Position
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

" vim-plug
command! PU PlugUpdate | PlugUpgrade

" fzf
set rtp+=~/.fzf
let g:fzf_prefer_tmux = 1

" Mapping selecting mappings
nmap <leader><tab> <plug>(fzf-maps-n)
xmap <leader><tab> <plug>(fzf-maps-x)
omap <leader><tab> <plug>(fzf-maps-o)
" Insert mode completion
imap <c-x><c-k> <plug>(fzf-complete-word)
imap <c-x><c-f> <plug>(fzf-complete-path)
imap <c-x><c-j> <plug>(fzf-complete-file-ag)
imap <c-x><c-l> <plug>(fzf-complete-line)
" Advanced customization using autoload functions
inoremap <expr> <c-x><c-k> fzf#vim#complete#word({'left': '15%'})

" vim-move
let g:move_key_modifier = 'M'

" deoplete
if has('python3')
	" let g:deoplete#enable_at_startup = 1
	call deoplete#enable()
	let g:deoplete#enable_smart_case = 1
"	 imap <C-@> <C-Space>
	autocmd InsertLeave,CompleteDone * if pumvisible() == 0 | pclose | endif
endif

" delimitMate
" seems bugged
" let delimitMate_expand_cr = 1

" vim-airline
set laststatus=2
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#left_sep = ' '
let g:airline#extensions#tabline#left_alt_sep = '|'

" use F13 as Esc replacement when in insertmode
:imap <F13> <Esc>

" Append modeline after last line in buffer.
" " Use substitute() instead of printf() to handle '%%s' modeline in LaTeX
" " files.
function! AppendModeline()
  let l:modeline = printf(" vim: set ts=%d sw=%d sts=%d tw=%d %set :",
		  \ &tabstop, &shiftwidth, &softtabstop, &textwidth, &expandtab ? '' : 'no')
			let l:modeline = substitute(&commentstring, "%s", l:modeline, "")
call append(line("$"), l:modeline)
endfunction
nnoremap <silent> <Leader>ml :call AppendModeline()<CR>

" strip comments
nnoremap <silent> <Leader>sc :%g/\v^(#\|$)/d<CR>
" replace word below cursor with x
nnoremap <Leader>src :%s/\<<C-r><C-w>\>//g<Left><Left>
" Search and Replace
nnoremap <Leader>s :%s//g<Left><Left>

" use sudo for saving
cnoremap sudow w !sudo tee % > /dev/null

" Relative numbering
function! NumberToggle()
  if(&relativenumber == 1)
	set nornu
	set number
  else
	set rnu
  endif
endfunction

" Toggle between normal and relative numbering.
nnoremap <leader>r :call NumberToggle()<cr>

" Use <C-L> to clear the highlighting of :set hlsearch.
if maparg('<C-L>', 'n') ==# ''
  nnoremap <silent> <C-L> :nohlsearch<CR><C-L>
endif
" vim: set ts=4 sw=4 sts=0 tw=78 noet :
