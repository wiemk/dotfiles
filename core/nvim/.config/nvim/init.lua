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
	use 'norcalli/nvim.lua'               -- Magic functions
	use 'tpope/vim-fugitive'              -- Git commands in nvim
	use 'tpope/vim-commentary'            -- "gc" to comment visual regions/lines
	use 'ludovicchabant/vim-gutentags'    -- Automatic tags management
	-- UI to select things (files, grep results, open buffers...)
	use {'nvim-telescope/telescope.nvim', requires = {{'nvim-lua/popup.nvim'}, {'nvim-lua/plenary.nvim'}} }
	-- use 'joshdick/onedark.vim'            -- Theme inspired by Atom
	use 'dracula/vim'                     -- Popular dracula theme
	use { 'hoob3rt/lualine.nvim', requires = {'kyazdani42/nvim-web-devicons', opt = true} }
	-- Add git related info in the signs columns and popups
	use {'lewis6991/gitsigns.nvim', requires = {'nvim-lua/plenary.nvim'} }
	use 'neovim/nvim-lspconfig'           -- Collection of configurations for built-in LSP client
	use 'hrsh7th/nvim-compe'              -- Autocompletion plugin
	use 'nvim-treesitter/nvim-treesitter' -- Language parser
	use 'mfussenegger/nvim-lint'          -- External linter support
	use 'glepnir/indent-guides.nvim'      -- Indent guides for spaces
	use 'rafcamlet/nvim-luapad'           -- Lua scratchpad
end)
-- }}}
-- {{{ utility functions
local nvim = require'nvim'

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

local map = (function(modes)
	local map = {}
	modes:gsub(".", function(c)
		f = function(bind, action, special)
			if special == nil then
				special = { noremap = true }
			end
			nvim.set_keymap(c, bind, action, special)
		end
		rawset(map, c, f)
	end)
	return map
end)("nvxc")
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
vim.wo.signcolumn = "no"

-- Set colorscheme (order is important here)
vim.o.termguicolors = true
-- vim.g.onedark_terminal_italics = 2
vim.wo.cursorline = true
vim.wo.cursorcolumn = true
nvim.ex.colorscheme([[dracula]])

-- Add map to enter paste mode
vim.o.pastetoggle="<F3>"
-- }}}
-- {{{ LSP
local nvim_lsp = require'lspconfig'
local on_attach = function(client, bufnr)
	nvim.buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

	local function buf_set_keymap(...)
		nvim.buf_set_keymap(bufnr, ...)
	end
	local function buf_set_option(...)
		nvim.buf_set_option(bufnr, ...)
	end

	local opts = { noremap=true, silent=true }
	buf_set_keymap('n', 'gD', '<Cmd>lua vim.lsp.buf.declaration()<CR>', opts)
	buf_set_keymap('n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
	buf_set_keymap('n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
	buf_set_keymap('n', 'gi', '<Cmd>lua vim.lsp.buf.implementation()<CR>', opts)
	buf_set_keymap('n', '<C-k>', '<Cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
	buf_set_keymap('n', '<leader>wa', '<Cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
	buf_set_keymap('n', '<leader>wr', '<Cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
	buf_set_keymap('n', '<leader>wl', '<Cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
	buf_set_keymap('n', '<leader>D', '<Cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
	buf_set_keymap('n', '<leader>rn', '<Cmd>lua vim.lsp.buf.rename()<CR>', opts)
	buf_set_keymap('n', 'gr', '<Cmd>lua vim.lsp.buf.references()<CR>', opts)
	buf_set_keymap('n', '<leader>ca', '<Cmd>lua vim.lsp.buf.code_action()<CR>', opts)
	buf_set_keymap('n', '<leader>e', '<Cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)
	buf_set_keymap('n', 'ö', '<Cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
	buf_set_keymap('n', 'ä', '<Cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
	buf_set_keymap('n', '<leader>q', '<Cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)

	-- Set some keybinds conditional on server capabilities
	if client.resolved_capabilities.document_formatting then
		buf_set_keymap("n", "<space>f", "<Cmd>lua vim.lsp.buf.formatting()<CR>", opts)
	elseif client.resolved_capabilities.document_range_formatting then
		buf_set_keymap("n", "<space>f", "<Cmd>lua vim.lsp.buf.range_formatting()<CR>", opts)
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
-- vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
--   vim.lsp.diagnostic.on_publish_diagnostics, {
--     -- Enable underline, use default values
--     underline = true,
--     -- Enable virtual text, override spacing to 4
--     virtual_text = {
--       spacing = 4,
--     },
--     -- Use a function to dynamically turn signs off
--     -- and on, using buffer local variables
--     signs = function(bufnr, client_id)
--       return vim.bo[bufnr].show_signs == false
--     end,
--     -- Disable a feature
--     update_in_insert = false,
--   }
-- {{{ LSP features
vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
	vim.lsp.diagnostic.on_publish_diagnostics, {
		underline = true,
		virtual_text = true,
		signs = true,
		update_in_insert = false,
	}
)
-- }}}
-- {{{ Lua language server

local sumneko_root_path = vim.fn.getenv("XDG_DATA_HOME") .. "/lua-language-server"
local sumneko_binary_path = "/bin/Linux/lua-language-server" -- Change to your OS specific output folder
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
			globals = {'vim'},
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
-- local luadev = require'lua-dev'.setup {
-- 	lspconfig = {
-- 		cmd = {sumneko_root_path .. sumneko_binary_path, "-E", sumneko_root_path .. "/main.lua" };
-- 		on_attach = on_attach,
-- 		settings = settings
-- }
-- nvim_lsp.sumneko_lua.setup(luadev) 

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
		nvim.exec([[
			augroup cleardiag
				autocmd!
				autocmd CursorMoved * : echo "" | autocmd!
			augroup end
		]], false)
	end
end
nvim.exec([[
	augroup linediag
		autocmd!
		autocmd CursorHold * lua show_line_diagnostics()
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
		t.window = nvim.get_current_win()
		t.backup = {}
		for k,v in pairs(t.target) do
			nomouse.backup[k] = nvim.win_get_option(t.window, k)
		end
	end
	local setopt = function(t)
		if next(t) ~= nil then
			for k,v in pairs(t) do
				nvim.win_set_option(t.window, k, v)
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

map.n('<F4>', '<Cmd>lua toggle_mouse()<CR>')
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
		nvim.exec('augroup fold | autocmd! fold FileType ' .. value ..
			' setlocal foldmethod=expr | setlocal foldexpr=nvim_treesitter#foldexpr()', false)
	end
end)()
map.n('<F5>', '<Cmd>setlocal foldmethod=expr | setlocal foldexpr=nvim_treesitter#foldexpr()<CR>')
-- }}}
-- {{{ nvim-lint
local lint = require'lint'
lint.linters_by_ft = {
	sh = {'shellcheck',},
	bash = {'shellcheck',},
}

nvim.exec([[
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
				condition = (function() return nomouse; end),
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
	util.keep_state(nvim.command, [[keeppatterns %s/\s\+$//e]])
end
delete_empty = function()
	util.keep_state(nvim.command, [[keeppatterns :v/\_s*\S/d]])
end

vim.cmd([[command! TrimTrailingWhite :lua trim_lines()]])
vim.cmd([[command! TrimTrailingLines :lua delete_empty()]])
vim.cmd([[command! TrimAll :lua trim_lines(); delete_empty()]])
-- }}}
-- {{{ Custom key bindings
-- Remap space as leader key
nvim.set_keymap('', '<Space>', '<Nop>', {noremap = true, silent = true})
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Remap for dealing with word wrap
map.opt = { noremap = true, expr = true, silent = true }

map.n('k', "v:count == 0 ? 'gk' : 'k'", map.opt)
map.n('j', "v:count == 0 ? 'gj' : 'j'", map.opt)

-- Do not copy when pasting
map.x("p", "pgvy")

-- J and K to move up and down
map.n("J", "}")
map.n("K", "{")
map.v("J", "}")
map.v("K", "{")

-- H and L to move to the beginning and end of a line
map.n("H", "_")
map.n("L", "$")
map.v("H", "_")
map.v("L", "$")

map.n("<C-f>", "/")
map.n("<C-g>", ":Rg<CR>")
map.n("<C-q>", ":q<CR>")
map.n("<C-s>", ":w<CR>")
map.n("<C-t>", ":Telescope fd<CR>")
map.n("u", ":undo<CR>")
map.n("U", ":redo<CR>")

-- Create splits with s and S
map.n("<C-w>s", ":vsplit<CR>:wincmd l<CR>")

-- Create, close, and move between tabs
map.n("<M-N>", ":tabnew<CR>")
map.n("<M-n>", ":tabprevious<CR>")
map.n("<M-m>", ":tabnext<CR>")
map.n("<M-M>", ":tabclose<CR>")

-- Cycle through open buffers
map.n("<leader>.", ":bnext<CR>")
map.n("<leader>,", ":bprevious<CR>")

-- Change to file directory in current window
map.n("<leader>cd", ":lcd %:p:h<CR>:pwd<CR>")

-- Save all.
map.n("<C-M-s>", ":wa<CR>")

-- Search and replace using marked text
map.v("<C-r>", "\"hy:%s/<C-r>h//gc<left><left><left>")

-- Don't yank when using delete
map.n('<del>', '"_x')

-- Y yank until the end of line
map.n('Y', 'y$');
-- {{{ Abbreviations
-- Force write with sudo
(function()
	local askpass = {
		'/usr/libexec/seahorse/ssh-askpass',
		'/usr/libexec/openssh/gnome-ssh-askpass',
	}
	for _, v in ipairs(askpass) do
		if vim.fn.executable(v) then
			nvim.ex.abbrev('w!!', 'w !SUDO_ASKPASS=' .. v .. ' sudo -A tee > /dev/null %')
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
	vim.fn.setline('.', util.trim(ml))
end
map.n('<leader>M', [[<Cmd>lua GenerateModeline()<CR>]])
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
special = { noremap = true, silent = true }
map.n('<leader>f', [[<Cmd>lua require'telescope.builtin'.find_files()<CR>]], special)
map.n('<leader><space>', [[<Cmd>lua require'telescope.builtin'.buffers()<CR>]], special)
map.n('<leader>b', [[<Cmd>lua require'telescope.builtin'.buffers()<CR>]], special)
map.n('<leader>r', [[<Cmd>lua require'telescope.builtin'.registers()<CR>]], special)
map.n('<leader>l', [[<Cmd>lua require'telescope.builtin'.current_buffer_fuzzy_find()<CR>]], special)
map.n('<leader>m', [[<Cmd>lua require'telescope.builtin'.marks()<CR>]], special)
map.n('<leader>t', [[<Cmd>lua require'telescope.builtin'.tags()<CR>]], special)
map.n('<leader>?', [[<Cmd>lua require'telescope.builtin'.oldfiles()<CR>]], special)
map.n('<leader>sd', [[<Cmd>lua require'telescope.builtin'.grep_string()<CR>]], special)
map.n('<leader>sp', [[<Cmd>lua require'telescope.builtin'.live_grep()<CR>]], special)
map.n('<leader>o', [[<Cmd>lua require'telescope.builtin'.tags{ only_current_buffer = true }<CR>]], special)
map.n('<leader>gc', [[<Cmd>lua require'telescope.builtin'.git_commits()<CR>]], special)
map.n('<leader>gb', [[<Cmd>lua require'telescope.builtin'.git_branches()<CR>]], special)
map.n('<leader>gs', [[<Cmd>lua require'telescope.builtin'.git_status()<CR>]], special)
map.n('<leader>gp', [[<Cmd>lua require'telescope.builtin'.git_bcommits()<CR>]], special)

-- Change preview window location
vim.g.splitbelow = true
-- }}}
-- {{{ gutentags
-- vim.g.gutentags_cache_dir = vim.fn.stdpath('cache') .. '/tags'
-- }}}
-- {{{ Compe
-- Set completeopt to have a better completion experience
vim.o.completeopt="menuone,noinsert"
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
-- {{{ Tab completion
local t = function(str)
	return nvim.replace_termcodes(str, true, true, true)
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

nvim.set_keymap("i", "<Tab>", "v:lua.tab_complete()", {expr = true})
nvim.set_keymap("s", "<Tab>", "v:lua.tab_complete()", {expr = true})
nvim.set_keymap("i", "<S-Tab>", "v:lua.s_tab_complete()", {expr = true})
nvim.set_keymap("s", "<S-Tab>", "v:lua.s_tab_complete()", {expr = true})
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
		print 'Hello from Luapad!'
	end,
	context = {
		shout = function(str) return(string.upper(str) .. '!') end
	}
}
-- }}}
-- {{{ Loose autocmd
-- Hide cmdline after entering a command
nvim.exec([[
	augroup cmdline
		autocmd!
		autocmd CmdlineLeave : echo ""
	augroup end
]], false)
-- Highlight on yank
nvim.exec([[
	augroup YankHighlight
		autocmd!
		autocmd TextYankPost * silent! lua vim.highlight.on_yank()
	augroup end
]], false)
-- Remap escape to leave terminal mode
nvim.exec([[
	augroup Terminal
		autocmd!
		au TermOpen * tnoremap <buffer> <Esc> <c-\><c-n>
		au TermOpen * set nonu
	augroup end
]], false)
-- Override parenthese highlighting
nvim.exec([[
	augroup hloverride
		autocmd!
		autocmd VimEnter * highlight MatchParen cterm=underline ctermfg=84 gui=underline guifg=#50FA7B guibg=#ff79c6
	augroup end
]], false)
-- }}}

