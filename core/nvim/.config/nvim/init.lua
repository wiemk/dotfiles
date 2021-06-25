-- vi:set ft=lua ts=4 sw=4 noet ai fdm=marker:
-- {{{ Packer plugin manager
local install_path = vim.fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
	vim.fn.system({'git', 'clone', 'https://github.com/wbthomason/packer.nvim', install_path})
	vim.api.nvim_command 'packadd packer.nvim'
end
vim.api.nvim_exec([[
	augroup Packer
		autocmd!
		autocmd BufWritePost init.lua PackerCompile
	augroup end
]], false)

local use = require'packer'.use
require'packer'.startup(function()
	use 'wbthomason/packer.nvim'          -- Package manager
	use 'tpope/vim-fugitive'              -- Git commands in nvim
	use 'tpope/vim-commentary'            -- "gc" to comment visual regions/lines
	use 'ludovicchabant/vim-gutentags'    -- Automatic tags management
	use 'neovim/nvim-lspconfig'           -- Collection of configurations for built-in LSP client
	use 'hrsh7th/nvim-compe'              -- Autocompletion plugin
	use 'nvim-treesitter/nvim-treesitter' -- Language parser
	use 'mfussenegger/nvim-lint'          -- External linter support
	use 'glepnir/indent-guides.nvim'      -- Indent guides for spaces
	use 'rafcamlet/nvim-luapad'           -- Lua scratchpad
	use 'dracula/vim'                     -- Popular dracula theme
	-- use 'joshdick/onedark.vim'         -- Theme inspired by Atom
	use { 'hoob3rt/lualine.nvim', requires = {'kyazdani42/nvim-web-devicons', opt = true} }
	-- Keymap wrapper functions
	use 'tjdevries/astronauta.nvim'
	-- Add git related info in the signs columns and popups
	use {'lewis6991/gitsigns.nvim', requires = {'nvim-lua/plenary.nvim'},
		config = function()
			require'gitsigns'.setup()
		end
	}
	-- UI to select things (files, grep results, open buffers...)
	use {'nvim-telescope/telescope.nvim',
		requires = {{'nvim-lua/popup.nvim'}, {'nvim-lua/plenary.nvim'}}
	}
	-- Frecency algorithm support for telescope
	use {'nvim-telescope/telescope-frecency.nvim',
		requires= {{'nvim-telescope/telescope.nvim'},
			{'tami5/sql.nvim', config = "vim.g.sql_clib_path = [[/usr/lib64/libsqlite3.so.0]]"}},
		config = function()
			require"telescope".load_extension("frecency")
		end
	}
end)
-- }}}
-- {{{ Utility functions
ex = setmetatable({}, {
	__index = function(t, k)
		local command = k:gsub("_$", "!")
		local f = function(...)
			return vim.api.nvim_command(table.concat(vim.tbl_flatten {command, ...}, " "))
		end
		rawset(t, k, f)
		return f
	end
});

function _G.dump(...)
	local objects = vim.tbl_map(vim.inspect, {...})
	return unpack(objects)
end

local util = {}
function util.win_float(s)
	vim.lsp.util.open_floating_preview({s}, 'plaintext', {})
end

function util.keep_state(callback, ...)
	local view = vim.fn.winsaveview()
	callback(...)
	vim.fn.winrestview(view)
end

function util.dump(t, indent, done)
	done = done or {}
	indent = indent or 0
	done[t] = true
	for key, value in pairs(t) do
		print(string.rep("\t", indent))
		if type(value) == "table" and not done[value] then
			done[value] = true
			print(key, ":\n")
			dump(value, indent + 2, done)
			done[value] = nil
		else
			print(key, "\t=\t", value, "\n")
		end
	end
end

function util.trim(s)
	local b = s:find"%S"
	return b and s:match(".*%S", b) or ""
end

function util.tok(s, sep)
	if sep == nil then
		sep = "%s"
	end
	local t = {}
	for str in s:gmatch("([^"..sep.."]+)") do
		table.insert(t, str)
	end
	return t
end

-- create mapping functions
local globals = (function(modes)
	local map = {}
	modes:gsub(".", function(c)
		f = function(key, action, opts)
			if opts == nil then
				opts = { noremap = true }
			end
			vim.api.nvim_set_keymap(c, key, action, opts)
		end
		local fn = c .. 'map'
		rawset(_G, fn, f)
		table.insert(map, fn)
	end)
	return map
end)("cinostvx");

(function()
	local km = require'astronauta.keymap'
	for k,v in pairs(km) do
		if string.match(k, "%Dnoremap") then
			table.insert(globals, k)
			rawset(_G, k, v)
		end
	end
end)()
-- }}}
-- {{{ Generic options
-- Disable netrw
vim.g.loaded_netrwPlugin = 1

-- Do not show the startup message
vim.o.shortmess = vim.o.shortmess .. "I"

-- Incremental live completion
vim.o.inccommand = "nosplit"

-- Set highlight on search
vim.o.hlsearch = false
vim.o.incsearch = true

-- Keep cursor away from screen edge
vim.o.scrolloff = 5

-- Make line numbers default
vim.wo.number = true
vim.wo.relativenumber = true

-- Do not save when switching buffers
vim.o.hidden = true

--Do not show x on last line
vim.o.showmode = false
vim.o.showcmd = false

--Enable mouse mode
vim.o.mouse = "a"

-- Use primary clipboard
vim.o.clipboard = "unnamed"

--Indentation
vim.bo.tabstop = 4;
vim.o.tabstop = 4;
vim.bo.shiftwidth = 4;
vim.o.shiftwidth = 4;
vim.bo.expandtab = false;
vim.o.expandtab = false;
vim.bo.softtabstop = -1;
vim.o.softtabstop = -1;
vim.bo.copyindent = true;

-- Autoreload files changed outside vim
vim.o.autoread = true

-- Enable break indent
vim.o.breakindent = true

-- Enable line wrapping
vim.wo.wrap = false
vim.wo.linebreak = false
vim.o.sidescroll = 10
vim.wo.colorcolumn = "120"

-- Save undo history
vim.o.undodir = vim.fn.stdpath('cache') .. '/undo'
vim.bo.undofile = true

vim.o.directory = vim.fn.stdpath('cache') .. '/swap'
vim.o.backup = false
vim.o.writebackup = true
vim.o.swapfile = true

-- Show whitespace characters
vim.wo.list = true
vim.o.listchars = "tab:→ ,eol:↲,nbsp:␣,trail:•,extends:⟩,precedes:⟨"
vim.o.showbreak = "↪ "

-- Fold method, may be changed by treesitter
vim.o.foldmethod = "marker"

-- Case insensitive searching UNLESS /C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Eliminate delays
vim.o.timeout = false
vim.o.timeoutlen = 0
vim.o.ttimeout = false
vim.o.ttimeoutlen = 0

-- Decrease update time for CursorHold
vim.o.updatetime = 250

-- Always show diagnostics column
vim.wo.signcolumn = "number"

-- Set colorscheme (order is important here)
vim.o.termguicolors = true
vim.wo.cursorline = true
vim.wo.cursorcolumn = true
-- vim.g.onedark_terminal_italics = 2
-- Add map to enter paste mode
vim.o.pastetoggle="<F3>"
-- }}}
-- {{{ LSP
local nvim_lsp = require'lspconfig'
local on_attach = function(client, bufnr)
	vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
	local map = (function(modes)
		local map = {}
		modes:gsub(".", function(c)
			f = function(key, action, opts)
				if opts == nil then
					opts = { noremap = true }
				end
				vim.api.nvim_buf_set_keymap(bufnr, c, key, action, opts)
			end
			rawset(map, c, f)
		end)
		return map
	end)("nvic")

	local opts = { noremap=true, silent=true }
	map.n('gD', '<Cmd>lua vim.lsp.buf.declaration()<CR>', opts)
	map.n('gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
	map.n('K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
	map.n('gi', '<Cmd>lua vim.lsp.buf.implementation()<CR>', opts)
	map.n('<C-k>', '<Cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
	map.n('<leader>wa', '<Cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
	map.n('<leader>wr', '<Cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
	map.n('<leader>wl', '<Cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
	map.n('<leader>D', '<Cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
	map.n('<leader>rn', '<Cmd>lua vim.lsp.buf.rename()<CR>', opts)
	map.n('gr', '<Cmd>lua vim.lsp.buf.references()<CR>', opts)
	map.n('<leader>ca', '<Cmd>lua vim.lsp.buf.code_action()<CR>', opts)
	map.n('<leader>e', '<Cmd>lua vim.lsp.diagnostic.show_line_diagnostics({focusable = false})<CR>', opts)
	map.n('ö', '<Cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
	map.n('ä', '<Cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
	map.n('<leader>q', '<Cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)

	-- Set some keybinds conditional on server capabilities
	if client.resolved_capabilities.document_formatting then
		map.n("<space>f", "<Cmd>lua vim.lsp.buf.formatting()<CR>", opts)
	elseif client.resolved_capabilities.document_range_formatting then
		map.n("<space>f", "<Cmd>lua vim.lsp.buf.range_formatting()<CR>", opts)
	end
end
-- {{{ Enable the following language servers
(function()
	local servers = {
		-- 'clangd',
		-- 'dockerls',
		-- 'bashls',
		-- 'cmake',
		-- 'gopls',
		-- 'rust_analyzer',
		-- 'pyright',
		-- 'tsserver'
	}
	for _, lsp in ipairs(servers) do
		nvim_lsp[lsp].setup {
			on_attach = on_attach
		}
	end
end)()
-- }}}
-- {{{ LSP features
vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
	vim.lsp.diagnostic.on_publish_diagnostics, {
		underline = true,
		virtual_text = true,
		signs = true,
		update_in_insert = false,
	})
-- }}}
-- {{{ Lua language server
local sumneko_root_path = vim.fn.getenv("XDG_DATA_HOME") .. "/lua-language-server"
local sumneko_binary_path = "/bin/Linux/lua-language-server"
table.insert(globals, 'vim')
local settings = {
	Lua = {
		runtime = {
			version = 'LuaJIT',
			path = vim.split(package.path, ';'),
		},
		completion = {
			enable = true,
			callSnippet = "Both"
		},
		diagnostics = {
			enable = true,
			globals = globals,
			disable = {'lowercase-global'}
		},
		workspace = {
			library = {
				[vim.fn.expand('$VIMRUNTIME/lua')] = true,
				[vim.fn.expand('$VIMRUNTIME/lua/vim/lsp')] = true,
			},
			maxPreload = 2000,
			preloadFileSize = 1000
		}
	}
}

nvim_lsp.sumneko_lua.setup {
	cmd = { sumneko_root_path .. sumneko_binary_path, "-E", sumneko_root_path .. "/main.lua" };
	on_attach = on_attach,
	settings = settings
}
-- }}}
-- Map :Format to vim.lsp.buf.formatting()
vim.cmd([[command! Format :lua vim.lsp.buf.formatting()]])
-- Allow for virtual text to be toggled
vim.b.lsp_virtual_text_enabled = true

local diagnostic_toggle_virtual_text = function()
	local virtual_text = vim.b.lsp_virtual_text_enabled
	virtual_text = not virtual_text
	vim.b.lsp_virtual_text_enabled = virtual_text
	vim.lsp.diagnostic.display(vim.lsp.diagnostic.get(0, 1), 0, 1, { virtual_text = virtual_text })
end
-- {{{ Show diagnostics on CursorHold
show_line_diagnostics = function()
	local diag = vim.lsp.diagnostic.get_line_diagnostics()
	if not next(diag) then
		return
	end
	local severity = 9
	local index = 0
	for key, value in pairs(diag) do
		if value.severity < severity then
			severity = value.severity
			index = key
		end
	end
	if diag[index].message ~= nil then
		print(diag[index].message)
		vim.api.nvim_exec([[
			augroup cleardiag
				autocmd!
				autocmd CursorMoved * : echo "" | autocmd!
			augroup end
		]], false)
	end
end
vim.api.nvim_exec([[
	augroup linediag
		autocmd!
" 		autocmd CursorHold * lua show_line_diagnostics()
		autocmd CursorHold * lua vim.lsp.diagnostic.show_line_diagnostics({focusable = false})
	augroup end
]], false)
-- }}}
-- }}}
-- {{{ Mouse toggle
local nomouse = {
	status = false,
	window = 0,
	target = {
		number = false,
		relativenumber = false,
		list = false,
		signcolumn = 'no'
	}
}
toggle_mouse = function()
	local backup = function(t)
		t.window = vim.api.nvim_get_current_win()
		t.backup = {}
		for k,v in pairs(t.target) do
			nomouse.backup[k] = vim.api.nvim_win_get_option(t.window, k)
		end
	end
	local setopt = function(t)
		if next(t) ~= nil then
			for k,v in pairs(t) do
				vim.api.nvim_win_set_option(t.window, k, v)
			end
		end
	end
	if vim.o.mouse == 'a' then
		backup(nomouse)
		diagnostic_toggle_virtual_text()
		setopt(nomouse.target)
		vim.o.mouse = 'v'
	else
		diagnostic_toggle_virtual_text()
		setopt(nomouse.backup)
		vim.o.mouse = 'a'
	end
	nomouse.status = not nomouse.status
end

nmap('<F4>', '<Cmd>lua toggle_mouse()<CR>')
-- }}}
-- {{{ Treesitter
require'nvim-treesitter.configs'.setup {
	-- debatable whether this should be commented or not
	-- ensure_installed = "maintained", -- one of "all", "maintained" (parsers with maintainers), or a list of languages
	ensure_installed = "maintained",
	highlight = {
		enable = true,              -- false will disable the whole extension
		-- disable = { "lua" }
	},
	incremental_selection = {
		enable = true,
		keymaps = {
			init_selection = "gnn",
			node_incremental = "grn",
			scope_incremental = "grc",
			node_decremental = "grm",
		},
	},
	indent = {
		enable = true
	}
};
-- Treesitter folding whitelist
(function()
	local fold_whitelist = {
		'markdown',
	}
	for _, value in pairs(fold_whitelist) do
		vim.api.nvim_exec('augroup fold | autocmd! fold FileType ' .. value ..
			' setlocal foldmethod=expr | setlocal foldexpr=nvim_treesitter#foldexpr()', false)
	end
end)()
nmap('<F5>', '<Cmd>setlocal foldmethod=expr | setlocal foldexpr=nvim_treesitter#foldexpr()<CR>')
-- }}}
-- {{{ nvim-lint
local lint = require'lint'
lint.linters_by_ft = {
	sh = {'shellcheck',},
	bash = {'shellcheck',},
}

vim.api.nvim_exec([[
	augroup Linter
		autocmd!
		autocmd BufWritePost <buffer> lua require'lint'.try_lint()
	augroup end
]], false)
-- }}}
-- {{{ lualine statusbar
require'lualine'.setup {
	options = {
		theme = 'dracula';
		icons_enabled = false,
		padding = 1,
		left_padding = 1,
		right_padding = 1,
		upper = false,
		lower = true
	},
	sections = {
		lualine_a = { 'mode' },
		lualine_b = {
			{
				(function() return [[NOMOUSE]]; end),
				condition = (function() return nomouse.status; end),
				lower = false
			},
			{
				(function() return [[PASTE]]; end),
				condition = (function() return vim.o.paste; end),
				lower = false
			}
		},
		lualine_c = {
			{ 'filename', file_status = true },
			{ 'fugitive#head'},
			{ 'diff', color_added = 'green', color_modified = 'yellow', color_removed = 'red' }},
		lualine_y = { 'progress', 'hostname' }
	},
	extension = { 'fzf', 'fugitive' }
}
-- }}}
-- {{{ Whitespace handling
trim_lines = function()
	util.keep_state(vim.api.nvim_command, [[keeppatterns %s/\s\+$//e]])
end
delete_empty = function()
	util.keep_state(vim.api.nvim_command, [[keeppatterns :v/\_s*\S/d]])
end

vim.cmd([[command! TrimTrailingWhite :lua trim_lines()]])
vim.cmd([[command! TrimTrailingLines :lua delete_empty()]])
vim.cmd([[command! TrimAll :lua trim_lines(); delete_empty()]])
-- }}}
-- {{{ Custom key bindings
-- Test mapping with lua callback
-- nnoremap { '<leader>hello', function() print('"hello world!" from lua!') end }

-- Remap space as leader key
vim.api.nvim_set_keymap('', '<Space>', '<Nop>', {noremap = true, silent = true})
vim.g.mapleader = " "
vim.g.maplocalleader = " "

opts = { noremap = true, expr = true, silent = true }

-- Lua test mapping

nmap('k', "v:count == 0 ? 'gk' : 'k'", opts)
nmap('j', "v:count == 0 ? 'gj' : 'j'", opts)

-- Do not copy when pasting
xmap("p", "pgvy")

-- J and K to move up and down
nmap("J", "}")
nmap("K", "{")
vmap("J", "}")
vmap("K", "{")

-- H and L to move to the beginning and end of a line
nmap("H", "_")
nmap("L", "$")
vmap("H", "_")
vmap("L", "$")

nmap("<C-f>", "/")
nmap("<C-g>", ":Rg<CR>")
nmap("<C-q>", ":q<CR>")
nmap("<C-s>", ":w<CR>")
nmap("<C-t>", ":Telescope fd<CR>")
nmap("u", ":undo<CR>")
nmap("U", ":redo<CR>")

-- Create splits with s and S
nmap("<C-w>s", ":vsplit<CR>:wincmd l<CR>")

-- Create, close, and move between tabs
nmap("<M-N>", ":tabnew<CR>")
nmap("<M-n>", ":tabprevious<CR>")
nmap("<M-m>", ":tabnext<CR>")
nmap("<M-M>", ":tabclose<CR>")

-- Cycle through open buffers
nmap("<leader>.", ":bnext<CR>")
nmap("<leader>,", ":bprevious<CR>")

-- Change to file directory in current window
nmap("<leader>cd", ":lcd %:p:h<CR>:pwd<CR>")

-- Save all.
nmap("<C-M-s>", ":wa<CR>")

-- Search and replace using marked text
vmap("<C-r>", "\"hy:%s/<C-r>h//gc<left><left><left>")

-- Don't yank when using delete
nmap('<del>', '"_x')

-- Y yank until the end of line
nmap('Y', 'y$')

-- Transpose lines
opts = { noremap = true, silent = true }
nmap('<S-Up>', '<Cmd>move .-2<CR>', opts)
nmap('<S-Down>', '<Cmd>move .+1<CR>', opts)
-- need to leave visual mode (:) for the mark to be set
vmap('<S-Up>', ':move \'<-2<CR>gv=gv', opts)
vmap('<S-Down>', ':move \'>+1<CR>gv=gv', opts);
-- }}}
-- {{{ Abbreviations
-- Force write with sudo
(function()
	local askpass = {
		'/usr/libexec/seahorse/ssh-askpass',
		'/usr/libexec/openssh/gnome-ssh-askpass',
	}
	for _, v in ipairs(askpass) do
		if vim.fn.executable(v) then
			ex.abbrev('w!!', 'w !SUDO_ASKPASS=' .. v .. ' sudo -A tee > /dev/null %')
			return
		end
	end
	print('No gui capable askpass binary found.')
end)();

-- }}}
-- {{{ Insert modeline
GenerateModeline = function()
	local expand
	if vim.bo.expandtab ~= "noexpandtab" then
		expand = "noet"
	else
		expand = "et"
	end
	local autoindent
	if vim.bo.autoindent ~= "noautoindent" then
		autoindent = "noai"
	else
		autoindent = "ai"
	end
	local cin = ""; local cout = ""
	if vim.o.commentstring ~= nil then
		local ctok = util.tok(vim.o.commentstring, "%%s")
		if next(ctok) ~= nil then
			cin = util.trim(ctok[1])
			if next(ctok, 1) ~= nil then
				cout = util.trim(ctok[2])
			end
		end
	end
	local ml = cin .. " vi:set ft=" .. vim.bo.filetype .. " ts=" .. vim.bo.tabstop ..
		" sw=" .. vim.bo.shiftwidth .. " " .. expand .. " " .. autoindent .. ": " .. cout
	vim.api.nvim_put({ util.trim(ml) }, 'l', true, false)
end
nmap('<leader>M', [[<Cmd>lua GenerateModeline()<CR>]])
-- }}}
-- {{{ Telescope
require'telescope'.setup {
	defaults = {
		mappings = {
			i = {
				["<C-u>"] = false,
				["<C-d>"] = false,
			},
		},
		generic_sorter =  require'telescope.sorters'.get_fzy_sorter,
		file_sorter =  require'telescope.sorters'.get_fzy_sorter,
	}
}
-- Add leader shortcuts
opts = { noremap = true, silent = true }
nmap('<leader>f', [[<Cmd>lua require'telescope.builtin'.find_files()<CR>]], opts)
nmap('<leader><space>', [[<Cmd>lua require'telescope.builtin'.buffers()<CR>]], opts)
nmap('<leader>b', [[<Cmd>lua require'telescope.builtin'.buffers()<CR>]], opts)
nmap('<leader>r', [[<Cmd>lua require'telescope.builtin'.registers()<CR>]], opts)
nmap('<leader>l', [[<Cmd>lua require'telescope.builtin'.current_buffer_fuzzy_find()<CR>]], opts)
nmap('<leader>m', [[<Cmd>lua require'telescope.builtin'.marks()<CR>]], opts)
nmap('<leader>t', [[<Cmd>lua require'telescope.builtin'.tags()<CR>]], opts)
nmap('<leader>?', [[<Cmd>lua require'telescope.builtin'.oldfiles()<CR>]], opts)
nmap('<leader>sd', [[<Cmd>lua require'telescope.builtin'.grep_string()<CR>]], opts)
nmap('<leader>sp', [[<Cmd>lua require'telescope.builtin'.live_grep()<CR>]], opts)
nmap('<leader>o', [[<Cmd>lua require'telescope.builtin'.tags{ only_current_buffer = true)<CR>]], opts)
nmap('<leader>gc', [[<Cmd>lua require'telescope.builtin'.git_commits()<CR>]], opts)
nmap('<leader>gb', [[<Cmd>lua require'telescope.builtin'.git_branches()<CR>]], opts)
nmap('<leader>gs', [[<Cmd>lua require'telescope.builtin'.git_status()<CR>]], opts)
nmap('<leader>gp', [[<Cmd>lua require'telescope.builtin'.git_bcommits()<CR>]], opts)

-- Frecency extension
nmap('<leader><Tab>', [[<Cmd>lua require'telescope'.extensions.frecency.frecency()<CR>]], opts)

-- Change preview window location
vim.g.splitbelow = true
-- }}}
-- {{{ gutentags
-- vim.g.gutentags_cache_dir = vim.fn.stdpath('cache') .. '/tags'
-- }}}
-- {{{ Compe
-- Set completeopt to have a better completion experience
vim.o.completeopt="menuone,noselect"
vim.o.shortmess = vim.o.shortmess .. "c"

require'compe'.setup {
	enabled = true;
	autocomplete = true;
	debug = false;
	min_length = 2;
	preselect = 'enable';
	throttle_time = 80;
	source_timeout = 200;
	incomplete_delay = 400;
	max_abbr_width = 100;
	max_kind_width = 100;
	max_menu_width = 100;
	documentation = true;

	source = {
		buffer = true;
		calc = false;
		nvim_lua = true;
		nvim_lsp = true;
		path = false;
	};
}

-- Insert mode mappings
opts = { silent = true, expr = true  }
imap('<C-Space>', 'compe#complete()', opts)
imap('<CR>', "compe#confirm('<CR>')", opts)
imap('<C-e>', "compe#close('<C-e>')", opts)
imap('<C-f>', "compe#scroll({ 'delta': +4 }", opts)
imap('<C-d>', "compe#scroll({ 'delta': -4 }", opts)

-- {{{ Tab completion
local t = function(str)
	return vim.api.nvim_replace_termcodes(str, true, true, true)
end

local check_back_space = function()
	local col = vim.fn.col('.') - 1
	return col == 0 or vim.fn.getline('.'):sub(col, col):match('%s')
end

-- Use (s-)tab to:
--- move to prev/next item in completion menuone
--- jump to prev/next snippet's placeholder
_G.tab_complete = function()
	if vim.fn.pumvisible() == 1 then
		return t "<C-n>"
	elseif check_back_space() then
		return t "<Tab>"
	else
		return vim.fn['compe#complete']()
	end
end

_G.s_tab_complete = function()
	if vim.fn.pumvisible() == 1 then
		return t "<C-p>"
	else
		return t "<S-Tab>"
	end
end

imap('<Tab>', 'v:lua.tab_complete()', {expr = true})
smap('<Tab>', 'v:lua.tab_complete()', {expr = true})
imap('<S-Tab>', 'v:lua.s_tab_complete()', {expr = true})
smap('<S-Tab>', 'v:lua.s_tab_complete()', {expr = true})
-- }}}
-- }}}
-- {{{ Indent guides
require'indent_guides'.setup {
	indent_guide_size = 1;
	indent_start_level = 1;
	indent_levels = 16;
	indent_enable = true;
	indent_space_guides = true;
	indent_tab_guides = true;
	indent_soft_pattern = '\\s';
	exclude_filetypes = {'help','dashboard','dashpreview','NvimTree','vista','sagahover'};
	even_colors = { fg='#2a3834',bg='#332b36' };
	odd_colors = { fg='#332b36',bg='#2a3834' };
}
-- }}}
-- {{{ Luapad
require'luapad'.config {
	count_limit = 150000,
	error_indicator = false,
	eval_on_move = true,
	error_highlight = 'WarningMsg',
	on_init = function()
		print('Luapad initialized.')
	end,
	context = {
		shout = function(str) return(string.upper(str) .. '!') end
	}
}
nmap('<F2>', '<Cmd>Luapad<CR>')
-- }}}
-- {{{ Loose autocmds
-- Hide cmdline after entering a command
vim.api.nvim_exec([[
	augroup cmdline
		autocmd!
		autocmd CmdlineLeave : echo ""
	augroup end
]], false)
-- Highlight on yank
vim.api.nvim_exec([[
	augroup YankHighlight
		autocmd!
		autocmd TextYankPost * silent! lua vim.highlight.on_yank()
	augroup end
]], false)
-- Remap escape to leave terminal mode
vim.api.nvim_exec([[
	augroup Terminal
		autocmd!
		au TermOpen * tnoremap <buffer> <Esc> <c-\><c-n>
		au TermOpen * set nonu
	augroup end
]], false);
-- }}}
-- {{{ Theme
-- Override highlighting
vim.api.nvim_exec([[
	function! ColorOverride() abort
		highlight clear MatchParen
		highlight MatchParen cterm=underline ctermfg=84 gui=underline guifg=#50FA7B guibg=#ff79c6
		highlight link String DraculaPurple
		highlight iCursor guifg=white guibg=#50FA7B
	endfunction
	augroup hloverride
		autocmd!
		autocmd ColorScheme dracula call ColorOverride()
	augroup end
]], false);
vim.o.guicursor = vim.o.guicursor .. ",i:ver100-iCursor,i:blinkon2"
ex.colorscheme([[dracula]])
-- }}}
-- {{{ Staging area
-- }}}
