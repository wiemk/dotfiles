-- vi:set ft=lua ts=4 sw=4 noet ai fdm=marker:
-- {{{1 Disable unused built-in plugins
vim.g.loaded_python_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_node_provider = 0
vim.g.loaded_man = 0
vim.g.loaded_gzip = 0
vim.g.loaded_netrwPlugin = 0
vim.g.loaded_tarPlugin = 0
vim.g.loaded_zipPlugin = 0
vim.g.loaded_2html_plugin = 0
vim.g.loaded_remote_plugins = 0
-- }}}
-- {{{1 Decrease start-up time
vim.cmd [[
	syntax off
	filetype off
	filetype plugin indent off
]]
-- Temporarily disable shada file to improve performance
vim.opt.shadafile = 'NONE'
local async
async = vim.loop.new_async(vim.schedule_wrap(function()
	vim.defer_fn(function()
		vim.opt.shadafile = ''
		vim.defer_fn(function()
			vim.cmd [[
				rshada!
				doautocmd BufRead
				syntax on
				filetype on
				filetype plugin indent on
				silent! bufdo e
			]]
		end, 15)
	end, 0)
	async:close()
end))
async:send()
-- }}}
-- {{{1 Packer plugin manager
local install_path = vim.fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
	vim.fn.system({'git', 'clone', 'https://github.com/wbthomason/packer.nvim', install_path})
	vim.api.nvim_command 'packadd packer.nvim'
end
vim.cmd [[
	augroup Packer
		autocmd!
		autocmd BufWritePost init.lua PackerCompile
	augroup end
]]

local use = require'packer'.use
require'packer'.startup(function()
	use 'wbthomason/packer.nvim'          -- Package manager
	use 'neovim/nvim-lspconfig'           -- Collection of configurations for built-in LSP client
	use 'machakann/vim-sandwich'          -- Surround text objects
	use 'tpope/vim-commentary'            -- 'gc' to comment visual regions/lines
	use 'tpope/vim-fugitive'              -- Git commands in nvim
	use 'tjdevries/astronauta.nvim'       -- Keymap wrapper functions
	use 'ggandor/lightspeed.nvim'         -- Motion plugin
	use { 'williamboman/nvim-lsp-installer',
		config = function() lsp_install_init() end
	}
	-- Automatic tags management
	use { 'ludovicchabant/vim-gutentags',
		setup = function()
			vim.g.gutentags_enabled = true
			vim.g.gutentags_ctags_tagfile = '.tags'
			vim.g.gutentags_file_list_command = 'fd'
		end
	}
	-- Tokyonight theme
	use { 'folke/tokyonight.nvim',
		setup = function()
			vim.g.tokyonight_lualine_bold = false
			vim.g.tokyonight_sidebars = { 'qf', 'terminal', 'packer' }
		end,
		config = function()
			vim.cmd [[colorscheme tokyonight]]
		end
	}
	-- Autocompletion plugin
	use { 'hrsh7th/nvim-cmp',
		requires = {
			{'hrsh7th/cmp-nvim-lsp'},
			{'hrsh7th/cmp-buffer'},
			{'saadparwaiz1/cmp_luasnip', requires = {'L3MON4D3/LuaSnip'}}
		},
		config = function()
			vim.opt.completeopt = {'menuone', 'noselect'}
			vim.opt.shortmess:append({ I = true })
			cmp_init()
		end
	}
	-- Language parser
	use { 'nvim-treesitter/nvim-treesitter',
		run = ':TSUpdate',
		config = function() treesitter_init(); end
	}
	-- Indent guides for spaces
	use { 'glepnir/indent-guides.nvim',
		config = function() indent_init(); end
	}
	-- Lua scratchpad
	use { 'rafcamlet/nvim-luapad',
		cmd = 'Luapad',
		config = function() luapad_init(); end
	}
	-- External linter support
	use { 'mfussenegger/nvim-lint', ft = {'sh', 'bash'},
		config = function() lint_init(); end
	}
	-- Interactive keybind overview
	use { 'folke/which-key.nvim',
		config = function()
			local wk = require'which-key'
			wk.setup {
				triggers = {'<leader>'}
			}
			wk.register({
				c = { "Yank to CLIPBOARD" },
				y = { "Yank to PRIMARY"}
			}, { prefix = '<leader>', mode = 'x'})
		end
	}
	use { 'nvim-lualine/lualine.nvim',
		config = function() lualine_init(); end
	}
	-- Add git related info in the signs columns and popups
	use { 'lewis6991/gitsigns.nvim', requires = {'nvim-lua/plenary.nvim'},
		config = function() gitsigns_init(); end
	}
	-- UI to select things (files, grep results, open buffers...)
	use { 'nvim-telescope/telescope.nvim', requires = {'nvim-lua/plenary.nvim'}}
	-- Native telescope fuzzy sorter
	use { 'nvim-telescope/telescope-fzy-native.nvim',
		requires = {'nvim-telescope/telescope.nvim'},
		cond = function()
			if vim.fn.executable('fzy') == 1 then
				return true
			end
		end,
		config = function() require'telescope'.load_extension('fzy_native'); end
	}
	-- Automatically create parenthesis pairs
	use { 'windwp/nvim-autopairs',
		config = function() autopairs_init(); end,
		disable = true
	}
	-- Bookmarks in QuickFix
	use { 'MattesGroeger/vim-bookmarks',
	setup = function()
		vim.g.bookmark_auto_save_file = vim.fn.stdpath('cache') .. '/bookmarks'
		vim.g.bookmark_save_per_working_dir = false
		vim.g.bookmark_auto_save = false
		vim.g.bookmark_disable_ctrlp = true
		vim.g.bookmark_highlight_lines = true
		vim.g.bookmark_manage_per_buffer = false
	end
	}
	-- Bookmark support for Telescope
	use { 'tom-anders/telescope-vim-bookmarks.nvim',
		requires = {'nvim-telescope/telescope.nvim'},
		config = function() require'telescope'.load_extension('vim_bookmarks'); end
	}
end)
-- }}}
-- {{{1 Utility functions
ex = setmetatable({}, {
	__index = function(t, k)
		local command = k:gsub('_$', '!')
		local f = function(...)
			return vim.api.nvim_command(table.concat(vim.tbl_flatten {command, ...}, ' '))
		end
		rawset(t, k, f)
		return f
	end
});

function _G.dump(...)
	local objects = vim.tbl_map(vim.inspect, {...})
	return unpack(objects)
end

function _G.t(s)
	return vim.api.nvim_replace_termcodes(s, true, true, true)
end

local util = {}
function util.keep_state(callback, ...)
	local view = vim.fn.winsaveview()
	callback(...)
	vim.fn.winrestview(view)
end

function util.trim(s)
	local b = s:find'%S'
	return b and s:match('.*%S', b) or ''
end

function util.tok(s, sep)
	if sep == nil then
		sep = '%s'
	end
	local t = {}
	for str in s:gmatch('([^'..sep..']+)') do
		table.insert(t, str)
	end
	return t
end

-- create mapping functions and add them to globals table for LSP
local globals = (function(modes)
	local map = {}
	modes:gsub('.', function(c)
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
end)('cinostvx')
-- create astronauta mapping functions
do
	local km = require'astronauta.keymap'
	for k,v in pairs(km) do
		if string.match(k, '%Dnoremap') then
			table.insert(globals, k)
			rawset(_G, k, v)
		end
	end
end
-- }}}
-- {{{1 Generic options
-- Disable welcome text
vim.opt.shortmess:append({ c = true })

-- Incremental live completion
vim.o.inccommand = 'nosplit'

-- Set highlight on search
vim.o.hlsearch = true
vim.o.incsearch = true

-- No magic by default
vim.opt.magic = false

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
vim.o.mouse = 'a'

-- Use primary clipboard
vim.o.clipboard = 'unnamed'

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
vim.wo.colorcolumn = '120'

-- Save undo history
vim.opt.undodir = vim.fn.stdpath('cache') .. '/undo'
vim.opt.undofile = true

vim.o.directory = vim.fn.stdpath('cache') .. '/swap'
vim.o.backup = false
vim.o.writebackup = true
vim.o.swapfile = true

-- Show whitespace characters
vim.wo.list = true
vim.o.listchars = 'tab:→ ,eol:↲,nbsp:␣,trail:•,lead:_,extends:⟩,precedes:⟨'
vim.o.showbreak = '↪ '

-- Diff mode options
vim.opt.diffopt = { 'filler', 'vertical', 'internal', 'algorithm:patience', 'indent-heuristic', 'context:3' }

-- Improve performance
vim.o.lz = true
vim.o.synmaxcol = 256

-- Fold method, may be changed by treesitter
vim.o.foldmethod = 'marker'

-- Case insensitive searching UNLESS /C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Eliminate delays
vim.o.timeout = true
vim.o.timeoutlen = 300
vim.o.ttimeout = false
vim.o.ttimeoutlen = 0

-- Decrease update time for CursorHold
vim.o.updatetime = 150

-- Always show diagnostics column
vim.wo.signcolumn = 'yes:1'

-- Change preview window location
vim.o.splitright = true

-- Set colorscheme (order is important here)
vim.o.termguicolors = true
vim.wo.cursorline = true
vim.wo.cursorcolumn = true
-- vim.g.onedark_terminal_italics = 2
vim.g.tokyonight_style='storm'
-- Add map to enter paste mode
vim.o.pastetoggle='<F5>'
-- }}}
-- {{{1 LSP
-- {{{2 Attach
local nvim_lsp = require'lspconfig'
local on_attach = function(client, bufnr)
	vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
	local map = (function(modes)
		local map = {}
		modes:gsub('.', function(c)
			f = function(key, action, opts)
				if opts == nil then
					opts = { noremap = true }
				end
				vim.api.nvim_buf_set_keymap(bufnr, c, key, action, opts)
			end
			rawset(map, c, f)
		end)
		return map
	end)('nvic')

	local opts = { noremap=true, silent=true }
	map.n('<leader>lD', '<Cmd>lua vim.lsp.buf.declaration()<CR>', opts)
	map.n('<leader>ld', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
	map.n('<leader>lh', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
	map.n('<leader>lK', '<Cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
	map.n('<leader>li', '<Cmd>lua vim.lsp.buf.implementation()<CR>', opts)
	map.n('<leader>lt', '<Cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
	map.n('<leader>lR', '<Cmd>lua vim.lsp.buf.rename()<CR>', opts)
	map.n('<leader>lr', '<Cmd>lua vim.lsp.buf.references()<CR>', opts)
	map.n('<leader>la', '<Cmd>lua vim.lsp.buf.code_action()<CR>', opts)
	map.n('<leader>le', '<Cmd>lua vim.lsp.diagnostic.show_line_diagnostics({focusable = false})<CR>', opts)
	map.n('<leader>lq', '<Cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)
	map.n('<leader>lwa', '<Cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
	map.n('<leader>lwr', '<Cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
	map.n('<leader>lwl', '<Cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
	map.n('ö', '<Cmd>lua vim.lsp.diagnostic.goto_prev({popup_opts = {focusable = false}})<CR>', opts)
	map.n('ä', '<Cmd>lua vim.lsp.diagnostic.goto_next({popup_opts = {focusable = false}})<CR>', opts)
	map.n('<M-k>', '<Cmd>lua vim.lsp.buf.hover({focusable = false})<CR>', opts)
	map.n('<M-d>', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
	map.i('<M-k>', '<Cmd>lua vim.lsp.buf.hover({focusable = false})<CR>', opts)
	map.i('<M-d>', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)

	-- Set some keybinds conditional on server capabilities
	if client.resolved_capabilities.document_formatting then
		map.n('<leader>F', '<Cmd>lua vim.lsp.buf.formatting()<CR>', opts)
	elseif client.resolved_capabilities.document_range_formatting then
		map.n('<leader>F', '<Cmd>lua vim.lsp.buf.range_formatting()<CR>', opts)
	end
end
-- 2}}}
-- {{{2 Servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
do
	capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)
	local servers = {
		'clangd',
		'gopls',
	}
	for _, lsp in ipairs(servers) do
		nvim_lsp[lsp].setup {
			on_attach = on_attach,
			capabilities = capabilities,
			flags = {
				debounce_text_changes = 150,
			}
		}
	end
end
-- }}}
-- {{{2 LSP Installer
lsp_install_init = function()
	local lsp_installer = require("nvim-lsp-installer")
	lsp_installer.on_server_ready(function(server)
		local opts = {}
		if server.name == "sumneko_lua" then
			globals = { 'vim', 'use_rocks', table.unpack(globals) }
			opts = { settings = { Lua = {
				diagnostics = {
					globals = globals,
					disable = { 'lowercase-global' }
				},
				telemetry = { enable = false }
			}}}
		end
		server:setup(opts)
		vim.cmd [[ do User LspAttachBuffers ]]
	end)
end
-- }}}
-- {{{2 Features
vim.lsp.handlers['extDocument/publishDiagnostics'] = vim.lsp.with(
	vim.lsp.diagnostic.on_publish_diagnostics, {
		underline = true,
		virtual_text = true,
		signs = true,
		update_in_insert = false,
	})
-- Map :Format to vim.lsp.buf.formatting()
vim.cmd [[command! Format execute 'lua vim.lsp.buf.formatting()']]
-- Allow for virtual text to be toggled
vim.b.lsp_virtual_text_enabled = true

local diagnostic_toggle_virtual_text = function()
	local virtual_text = vim.b.lsp_virtual_text_enabled
	virtual_text = not virtual_text
	vim.b.lsp_virtual_text_enabled = virtual_text
	vim.lsp.diagnostic.display(vim.lsp.diagnostic.get(0, 1), 0, 1, { virtual_text = virtual_text })
end
-- }}}
-- {{{2 Diagnostics
vim.cmd [[
	augroup linediag
		autocmd!
		autocmd CursorHold,CursorHoldI * lua vim.lsp.diagnostic.show_line_diagnostics({focusable = false})
	augroup end
]]
-- 2}}}
-- 1}}}
-- {{{1 Treesitter
treesitter_init = function()
	require'nvim-treesitter.configs'.setup {
		ensure_installed = 'maintained',
		highlight = {
			enable = true,
			-- disable = { 'lua' }
		},
		incremental_selection = {
			enable = true,
			keymaps = {
				init_selection = 'gnn',
				node_incremental = 'grn',
				scope_incremental = 'grc',
				node_decremental = 'grm',
			},
		},
		indent = {
			enable = true
		},
		textobjects = {
			select = {
				enable = true,
				-- Automatically jump forward to textobj, similar to targets.vim
				lookahead = true,
				keymaps = {
					-- You can use the capture groups defined in textobjects.scm
					['af'] = '@function.outer',
					['if'] = '@function.inner',
					['ac'] = '@class.outer',
					['ic'] = '@class.inner',
				},
			},
			move = {
				enable = true,
				-- whether to set jumps in the jumplist
				set_jumps = true,
				goto_next_start = {
					[']m'] = '@function.outer',
					[']]'] = '@class.outer',
				},
				goto_next_end = {
					[']M'] = '@function.outer',
					[']['] = '@class.outer',
				},
				goto_previous_start = {
					['[m'] = '@function.outer',
					['[['] = '@class.outer',
				},
				goto_previous_end = {
					['[M'] = '@function.outer',
					['[]'] = '@class.outer',
				},
			},
		},
	}
end
-- Treesitter folding whitelist
do
	local fold_whitelist = {
		'markdown',
	}
	for _, value in pairs(fold_whitelist) do
		vim.api.nvim_exec('augroup fold | autocmd! fold FileType ' .. value ..
			' setlocal foldmethod=expr | setlocal foldexpr=nvim_treesitter#foldexpr()', false)
	end
end
nmap('<F8>', '<Cmd>setlocal foldmethod=expr | setlocal foldexpr=nvim_treesitter#foldexpr()<CR>')
-- }}}
-- {{{1 Linter
lint_init = function()
	require'lint'.linters.shellcheck.args = {
		'--format', 'json',
		'-s', 'bash',
		'-x',
		'-',
	}
	require'lint'.linters_by_ft = {
		sh = {'shellcheck',},
		bash = {'shellcheck',},
	}
	vim.cmd [[
		augroup Linter
			autocmd! * <buffer>
			autocmd BufWritePost * lua require'lint'.try_lint()
		augroup end
	]]
end
-- }}}
-- {{{1 Indent guides
indent_init = function()
	require'indent_guides'.setup {
		indent_guide_snnn = 1;
		indent_start_level = 1;
		indent_levels = 16;
		indent_enable = true;
		indent_space_guides = true;
		indent_tab_guides = true;
		indent_soft_pattern = '\\s';
		exclude_filetypes = {'help','dashboard','dashpreview','NvimTree','vista','sagahover'};
		odd_colors = { fg='#565f89',bg='bg' };
		even_colors = { fg='#414868',bg='bg' };
	}
end
-- }}}
-- {{{1 Gitsigns init
gitsigns_init = function()
	require'gitsigns'.setup{
		signs = {
			add = { hl = 'GitSignsAdd', text = '+', numhl='GitSignsAddNr' , linehl='GitSignsAddLn' },
			change = { hl = 'GitSignsChange', text = '~', numhl='GitSignsChangeNr', linehl='GitSignsChangeLn' },
			delete = { hl = 'GitSignsDelete', text = '_', numhl='GitSignsDeleteNr', linehl='GitSignsDeleteLn' },
			topdelete = { hl = 'GitSignsTopDelete', text = '‾', numhl='GitSignsDeleteNr', linehl='GitSignsDeleteLn' },
			changedelete = { hl = 'GitSignsChangeDelete', text = '~',  numhl='GitSignsChangeNr', linehl='GitSignsChangeLn' },
		},
		update_debounce = 500,
		numhl = true,
		linehl = false,
	}
end
-- }}}
-- {{{1 Autopairs
autopairs_init = function()
	local npairs = require'nvim-autopairs'
	npairs.setup({
		check_ts = true,
		ts_config = {
			-- it will not add pair on that treesitter node
			lua = {'string'},
			javascript = {'template_string'},
			-- don't check treesitter on java
			java = false,
		},
		fast_wrap = {},
	})
	require('nvim-treesitter.configs').setup {
		autopairs = {enable = true}
	}
	local ts_conds = require('nvim-autopairs.ts-conds')
	local Rule = require('nvim-autopairs.rule')
	-- press % => %% is only inside comment or string
	npairs.add_rules({
		Rule("%", "%", "lua")
			:with_pair(ts_conds.is_ts_node({'string','comment'})),
		Rule("$", "$", "lua")
			:with_pair(ts_conds.is_not_ts_node({'function'}))
	})
end
-- }}}
-- {{{1 Mouse toggle
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
		for k,_ in pairs(t.target) do
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

nmap('<F7>', '<Cmd>lua toggle_mouse()<CR>')
-- }}}
-- {{{1 lualine statusbar
lualine_init = function()
	require'lualine'.setup {
		options = {
			theme = 'tokyonight';
			icons_enabled = false,
			padding = 1,
			left_padding = 1,
			right_padding = 1,
			fmt = string.lower
		},
		sections = {
			lualine_a = { 'mode' },
			lualine_b = {
				{
					(function() return [[NOMOUSE]]; end),
					cond = (function() return nomouse.status; end),
					fmt = string.upper
				},
				{
					(function() return [[PASTE]]; end),
					cond = (function() return vim.o.paste; end),
					fmt = string.upper
				}
			},
			lualine_c = {
				{ 'filename', file_status = true },
				{ 'fugitive#head'},
				{ 'diff' }},
			lualine_y = { 'progress', 'hostname' }
		},
		extension = { 'fzf', 'fugitive' }
	}
end
-- }}}
-- {{{1 Whitespace handling
trim_lines = function()
	util.keep_state(vim.api.nvim_command, [[keeppatterns %s/\s\+$//e]])
end
delete_empty = function()
	util.keep_state(vim.api.nvim_command, [[keeppatterns :v/\_s*\S/d]])
end

vim.cmd [[command! TrimTrailingWhite :lua trim_lines()]]
vim.cmd [[command! TrimTrailingLines :lua delete_empty()]]
vim.cmd [[command! TrimAll :lua trim_lines(); delete_empty()]]
-- }}}
-- {{{1 Custom key bindings
-- Test mapping with lua callback
-- nnoremap { '<leader>hello', function() print('"hello world!" from lua!') end }

-- Remap space as leader key
vim.api.nvim_set_keymap('', '<Space>', '<Nop>', {noremap = true, silent = true})
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Workaround for tmux under kitty
vim.api.nvim_set_keymap('', '<C-a>', '<Home>', {noremap = true, silent = true})
vim.api.nvim_set_keymap('', '<C-e>', '<End>', {noremap = true, silent = true})

opts = { noremap = true, expr = true, silent = true }

nmap('k', "v:count == 0 ? 'gk' : 'k'", opts)
nmap('j', "v:count == 0 ? 'gj' : 'j'", opts)

-- Do not copy when pasting
xmap('p', 'pgvy')

-- J and K to move up and down
nmap('J', '}')
nmap('K', '{')
vmap('J', '}')
vmap('K', '{')

-- H and L to move to the beginning and end of a line
nmap('H', '_')
nmap('L', '$')
vmap('H', '_')
vmap('L', '$')

nmap('<C-f>', '/')
-- nmap('<C-q>', '<Cmd>close<CR>')
nmap('<C-s>', ':w<CR>')
nmap('<C-t>', ':Telescope fd<CR>')
nmap('u', ':undo<CR>')
nmap('U', ':redo<CR>')

-- clear hls
nmap('<C-h>', ':noh<CR>')

-- Create splits with s and S
nmap('<C-w>s', ':vsplit<CR>:wincmd l<CR>')

-- Create, close, and move between tabs
nmap('~', ':tabnew<CR>')
nmap('–', ':tabclose<CR>')
nmap('·', ':tabprevious<CR>')
nmap('…', ':tabnext<CR>')

-- Cycle through open buffers
nmap('<leader>,', ':bprevious<CR>')
nmap('<leader>.', ':bnext<CR>')
nmap('<M-,>', ':bprevious<CR>')
nmap('<M-.>', ':bnext<CR>')
nmap('<M-->', ':bdelete<CR>')
nmap('<M-_>', ':bwipeout<CR>')

-- Change to file directory in current window
nmap('<leader>cd', ':lcd %:p:h<CR>:pwd<CR>')

-- Save all.
nmap('<C-M-s>', ':wa<CR>:echo "All saved!"<CR>')

-- Search and replace using marked text
vmap('<C-r>', '"vy:%s/<C-r>v//gc<left><left><left>')

-- Don't yank when using delete
nmap('<del>', '"_x')
nmap('x', '"_x')

-- Y yank until the end of line
nmap('Y', 'y$')


-- Save session
nmap('<F6>', '<Cmd>wa<Bar>exe "mksession! " . v:this_session<CR><Cmd>echo "Session saved!"<CR>')

-- Update Plugins
nmap('<leader>U', '<Cmd>PackerSync<CR>')

-- Next search result
nmap('<F3>', 'n')
nmap('<F4>', 'N')

-- Transpose lines
opts = { noremap = true, silent = true }
nmap('<M-Up>', '<Cmd>move .-2<CR>', opts)
nmap('<M-Down>', '<Cmd>move .+1<CR>', opts)
-- Need to trigger CmdlineEnter/CmdlineLeave events, so do not use <Cmd>
vmap('<M-Up>', ':move \'<-2<CR>gv=gv', opts)
vmap('<M-Down>', ':move \'>+1<CR>gv=gv', opts);

-- Yank to CLIPBOARD register
xmap('<leader>c', '"+y')
xmap('<C-c>', '"+y')
-- Yank to PRIMARY register
xmap('<leader>y', '"*y')
xmap('<C-y>', '"*y')

-- Keep cursor position when scrolling
nmap('<PageUp>', '<C-U><C-U>')
vmap('<PageUp>', '<C-U><C-U>')
imap('<PageUp>', '<C-\\><C-O><C-U><C-\\><C-O><C-U>')
nmap('<PageDown>', '<C-D><C-D>')
vmap('<PageDown>', '<C-D><C-D>')
imap('<PageDown>', '<C-\\><C-O><C-D><C-\\><C-O><C-D>')


-- nnoremap <silent> <PageDown> <C-D><C-D>
-- vnoremap <silent> <PageDown> <C-D><C-D>
-- inoremap <silent> <PageDown> <C-\><C-O><C-D><C-\><C-O><C-D>

-- }}}
-- {{{1 Abbreviations
-- Force write with sudo, two different approaches
vim.cmd [[com! -bang W lua SudoWrite('<bang>' == '!')]]
SudoWrite = function(bang)
	if not bang then
		print('Add ! to use sudo.')
	else
		vim.cmd [[
			w! /tmp/sudonvim
			bel 2new
			startinsert
			te sudo tee #:S </tmp/sudonvim >/dev/null; rm /tmp/sudonvim
		]]
	end
end
do
	local askpass = {
		'/usr/libexec/seahorse/ssh-askpass',
		'/usr/libexec/openssh/gnome-ssh-askpass',
	}
	for _, v in ipairs(askpass) do
		if vim.fn.executable(v) == 1 then
			ex.abbrev('w!!', 'w !SUDO_ASKPASS=' .. v .. ' sudo -A tee > /dev/null %')
			break
		end
	end
end
-- }}}
-- {{{1 Insert modeline
GenerateModeline = function()
	local expand
	if vim.bo.expandtab ~= 'noexpandtab' then
		expand = 'noet'
	else
		expand = 'et'
	end
	local autoindent
	if vim.bo.autoindent ~= 'noautoindent' then
		autoindent = 'noai'
	else
		autoindent = 'ai'
	end
	local cin = ''; local cout = ''
	if vim.o.commentstring ~= nil then
		local ctok = util.tok(vim.o.commentstring, '%%s')
		if next(ctok) ~= nil then
			cin = util.trim(ctok[1])
			if next(ctok, 1) ~= nil then
				cout = util.trim(ctok[2])
			end
		end
	end
	local ml = cin .. ' vi:set ft=' .. vim.bo.filetype .. ' ts=' .. vim.bo.tabstop ..
		' sw=' .. vim.bo.shiftwidth .. ' ' .. expand .. ' ' .. autoindent .. ': ' .. cout
	vim.api.nvim_put({ util.trim(ml) }, 'l', true, false)
end
nmap('<leader>Z', [[<Cmd>lua GenerateModeline()<CR>]])
-- }}}
-- {{{1 Telescope
local find_cmd
if vim.fn.executable("fd") == 1 then
	find_cmd = { 'fd', '--type', 'f', '--hidden', '--no-ignore', '--exclude', '.git', '--exclude', '.tags' }
end
require'telescope'.setup {
	defaults = {
		mappings = {
			i = {
				['<C-u>'] = false,
				['<C-d>'] = false,
			},
		},
		generic_sorter =  require'telescope.sorters'.get_fzy_sorter,
		file_sorter =  require'telescope.sorters'.get_fzy_sorter,
	},
	pickers = {
		-- Your special builtin config goes in here
		buffers = {
			sort_lastused = true,
			theme = "ivy",
			previewer = false,
			mappings = {
				i = {
					["<c-d>"] = require("telescope.actions").delete_buffer,
				},
				n = {
					["<c-d>"] = require("telescope.actions").delete_buffer,
				}
			}
		},
		find_files = {
			theme = "ivy",
			previewer = false,
			hidden = true,
			find_command = find_cmd
		},
		live_grep = {
			-- extending default values instead of overwriting
			vimgrep_arguments = (function()
				local args = vim.tbl_values(require("telescope.config").values.vimgrep_arguments)
				local ext = { "--hidden", "--glob", "!.git/**" }
				return vim.tbl_flatten({ args, ext })
			end)()
		},
		git_files = {
			theme = "ivy",
			previewer = false,
		},
		oldfiles = {
			theme = "ivy",
			previewer = false,
		},
		builtin = {
			theme = "dropdown",
			previewer = false
		},
		marks = {
			theme = "ivy"
		},
		registers = {
			theme = "ivy"
		},
		tags = {
			only_current_buffer = true
		},
	},
	extensions = {
		-- Your extension config goes in here
	}
}
-- Add leader shortcuts
opts = { noremap = true, silent = true }
nmap('<leader>b', [[<Cmd>lua require'telescope.builtin'.buffers()<CR>]], opts)
nmap('<leader>B', [[<Cmd>lua require'telescope.builtin'.builtin()<CR>]], opts)
nmap('<leader>f', [[<Cmd>lua require'telescope.builtin'.find_files()<CR>]], opts)
nmap('<leader><space>', [[<Cmd>lua require'telescope.builtin'.buffers()<CR>]], opts)
nmap('<leader>r', [[<Cmd>lua require'telescope.builtin'.registers()<CR>]], opts)
nmap('<leader>p', [[<Cmd>lua require'telescope.builtin'.current_buffer_fuzzy_find()<CR>]], opts)
-- nmap('<leader>m', [[<Cmd>lua require'telescope.builtin'.marks()<CR>]], opts)
nmap('<leader>t', [[<Cmd>lua require'telescope.builtin'.tags()<CR>]], opts)
nmap('<leader>?', [[<Cmd>lua require'telescope.builtin'.oldfiles()<CR>]], opts)
nmap('<leader>i', [[<Cmd>lua require'telescope.builtin'.live_grep()<CR>]], opts)
nmap('<leader>s', [[<Cmd>lua require'telescope.builtin'.grep_string()<CR>]], opts)
nmap('<leader>Gc', [[<Cmd>lua require'telescope.builtin'.git_commits()<CR>]], opts)
nmap('<leader>Gb', [[<Cmd>lua require'telescope.builtin'.git_branches()<CR>]], opts)
nmap('<leader>Gs', [[<Cmd>lua require'telescope.builtin'.git_status()<CR>]], opts)
nmap('<leader>Gp', [[<Cmd>lua require'telescope.builtin'.git_bcommits()<CR>]], opts)
nmap('<leader>g', [[<Cmd>lua require'telescope.builtin'.git_files()<CR>]], opts)
nmap('<leader>H', [[<Cmd>lua require'telescope.builtin'.help_tags()<CR>]], opts)
nmap('<leader>m', [[<Cmd>lua require'telescope'.extensions.vim_bookmarks.all()<CR>]], opts)
nmap('<leader>M', [[<Cmd>lua require'telescope'.extensions.vim_bookmarks.current_file()<CR>]], opts)
-- {{{1 cmp
cmp_init = function()
	local cmp = require'cmp'
	local luasnip = require'luasnip'
	cmp.setup {
		snippet = {
			expand = function(args)
				luasnip.lsp_expand(args.body)
			end,
		},
		mapping = {
			['<C-p>'] = cmp.mapping.select_prev_item(),
			['<C-n>'] = cmp.mapping.select_next_item(),
			['<C-d>'] = cmp.mapping.scroll_docs(-4),
			['<C-f>'] = cmp.mapping.scroll_docs(4),
			['<C-Space>'] = cmp.mapping.complete(),
			['<C-e>'] = cmp.mapping.close(),
			['<CR>'] = cmp.mapping.confirm {
				behavior = cmp.ConfirmBehavior.Replace,
				select = true,
			},
			['<Tab>'] = function(fallback)
				if cmp.visible() then
					cmp.select_next_item()
				elseif luasnip.expand_or_jumpable() then
					luasnip.expand_or_jump()
				else
					fallback()
				end
			end,
			['<S-Tab>'] = function(fallback)
				if cmp.visible() then
					cmp.select_prev_item()
				elseif luasnip.jumpable(-1) then
					luasnip.jumpable(-1)
				else
					fallback()
				end
			end,
		},
		sources = {
			{ name = 'nvim_lsp' },
			{ name = 'luasnip' },
			{ name = 'buffer' },
		},
	}
end
-- }}}
-- {{{1 Luapad
luapad_init = function()
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
end
-- }}}
-- {{{1 FileType
-- Change local working dir to current file directory
-- vim.cmd [[
-- 	augroup AutoChdir
-- 		autocmd!
-- 		autocmd BufEnter * silent! lcd %:p:h
-- 	augroup end
-- ]]
-- Open help as vsplit
vim.cmd [[
	augroup VerticalHelp
		autocmd!
		autocmd BufEnter *.txt if &buftype == 'help' | wincmd L | endif
"		autocmd FileType help wincmd L
	augroup end
]]
vim.cmd [[
	augroup FishComment
		autocmd FileType fish setlocal commentstring=#%s
	augroup end
]]
-- }}}
-- {{{1 Loose autocmds
-- Hide cmdline after entering a command
vim.cmd [[
	augroup CmdLine
		autocmd!
		autocmd CmdlineLeave : echo ""
	augroup end
]]
-- Highlight on yank
vim.cmd [[
	augroup YankHighlight
		autocmd!
		autocmd TextYankPost * silent! lua vim.highlight.on_yank { timeout = 100, higroup = "lCursor" }
	augroup end
]]
-- Remap escape to leave terminal mode
vim.cmd [[
	augroup Terminal
		autocmd!
		autocmd TermOpen * tnoremap <buffer> <Esc> <c-\><c-n>
		autocmd TermOpen * set nonu
	augroup end
]]
-- Markdown filetype for bare textfiles
vim.cmd [[
	augroup MarkdownText
		autocmd!
		autocmd BufNewFile,BufRead *.txt setlocal ft=markdown
	augroup end
]]
-- }}}
-- {{{1 Assorted command
-- Vertical split with bigger left window
vim.cmd [[command! Vsplit vsplit | wincmd w | vertical resize 125]]
-- }}}
-- {{{1 Theme/GUI
-- Override highlighting
vim.cmd [[
	function! ColorOverride() abort
		highlight clear MatchParen
		highlight MatchParen cterm=underline ctermfg=84 gui=underline guifg=#50FA7B guibg=#ff79c6
		highlight link String DraculaPurple
		highlight iCursor guifg=white guibg=#50FA7B
	endfunction
	augroup HlOverride
		autocmd!
		autocmd ColorScheme dracula call ColorOverride()
	augroup end
]]
vim.opt.guicursor:append({ 'i:ver100-iCursor', 'i:blinkon2' })
vim.o.guifont = 'Fira Code:h11'
vim.g.neovide_refresh_rate = 120
vim.g.neovide_cursor_antialiasing = false
vim.g.neovide_cursor_vfx_mode = 'pixiedust'
-- }}}
-- {{{1 Legacy VimScript
-- }}}
-- {{{1 Staging area
nmap('<leader>d', [[<Cmd>packadd termdebug | Termdebug<CR>]], opts)
-- }}}

