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
	use 'neovim/nvim-lspconfig'           -- Collection of configurations for built-in LSP client
	use 'dracula/vim'                     -- Popular dracula theme
	use 'tpope/vim-commentary'            -- 'gc' to comment visual regions/lines
	use 'tpope/vim-fugitive'              -- Git commands in nvim
	use 'ludovicchabant/vim-gutentags'    -- Automatic tags management
	use 'tjdevries/astronauta.nvim'       -- Keymap wrapper functions
	use 'antoinemadec/FixCursorHold.nvim' -- Temporary fix for neovim #12587
	-- Autocompletion plugin
	use { 'hrsh7th/nvim-compe',
		config = function()
			vim.opt.completeopt = {'menuone', 'noselect'}
			vim.opt.shortmess:append({ I = true })
			compe_init()
		end
	}
	-- Language parser
	use { 'nvim-treesitter/nvim-treesitter',
		config = function() treesitter_init(); end
	}
	use { 'glepnir/indent-guides.nvim',
		config = function() indent_init(); end
	}      -- Indent guides for spaces
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
			require'which-key'.setup {
				triggers = {'<leader>'}
			}
		end
	}
	use { 'hoob3rt/lualine.nvim',
		config = function() lualine_init(); end
	}
	-- Add git related info in the signs columns and popups
	use {'lewis6991/gitsigns.nvim', requires = {'nvim-lua/plenary.nvim'},
		config = function() gitsigns_init(); end
	}
	-- UI to select things (files, grep results, open buffers...)
	use {'nvim-telescope/telescope.nvim',
		requires = {{'nvim-lua/popup.nvim'}, {'nvim-lua/plenary.nvim'}}
	}
	-- Frecency algorithm support for telescope
	use {'nvim-telescope/telescope-frecency.nvim',
		requires = {{'nvim-telescope/telescope.nvim'},
			{'tami5/sql.nvim', config = 'vim.g.sql_clib_path = [[/usr/lib64/libsqlite3.so.0]]'}},
		config = function() require'telescope'.load_extension('frecency'); end
	}
	-- Session management
	use { 'Shatur/neovim-session-manager',
		requires = {'nvim-telescope/telescope.nvim'},
		config = function()
			vim.g.autosave_last_session = false
			vim.g.sessions_dir = vim.fn.stdpath('cache') .. '/sessions/'
			require'telescope'.load_extension('session_manager')
		end,
	}
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
		config = function() autopairs_init(); end }
end)
-- }}}
-- {{{ Utility functions
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
		print(string.rep('\t', indent))
		if type(value) == 'table' and not done[value] then
			done[value] = true
			print(key, ':\n')
			dump(value, indent + 2, done)
			done[value] = nil
		else
			print(key, '\t=\t', value, '\n')
		end
	end
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

-- create mapping functions
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
end)('cinostvx');

(function()
	local km = require'astronauta.keymap'
	for k,v in pairs(km) do
		if string.match(k, '%Dnoremap') then
			table.insert(globals, k)
			rawset(_G, k, v)
		end
	end
end)()
-- }}}
-- {{{ Generic options
-- Disable netrw
vim.g.loaded_netrwPlugin = 1

-- Disable welcome text
vim.opt.shortmess:append({ c = true })

-- Incremental live completion
vim.o.inccommand = 'nosplit'

-- Set highlight on search
vim.o.hlsearch = true
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
vim.o.undodir = vim.fn.stdpath('cache') .. '/undo'
vim.bo.undofile = true

vim.o.directory = vim.fn.stdpath('cache') .. '/swap'
vim.o.backup = false
vim.o.writebackup = true
vim.o.swapfile = true

-- Show whitespace characters
vim.wo.list = true
vim.o.listchars = 'tab:→ ,eol:↲,nbsp:␣,trail:•,lead:_,extends:⟩,precedes:⟨'

vim.o.showbreak = '↪ '

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
vim.wo.signcolumn = 'number'

-- Set colorscheme (order is important here)
vim.o.termguicolors = true
vim.wo.cursorline = true
vim.wo.cursorcolumn = true
-- vim.g.onedark_terminal_italics = 2
-- vim.g.tokyonight_style='storm'
-- Add map to enter paste mode
vim.o.pastetoggle='<F3>'
-- }}}
-- {{{ LSP attach
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
	map.n('ö', '<Cmd>lua vim.lsp.diagnostic.goto_prev({popup_opts = {focusable = false}})<CR>', opts)
	map.n('ä', '<Cmd>lua vim.lsp.diagnostic.goto_next({popup_opts = {focusable = false}})<CR>', opts)
	map.n('<leader>q', '<Cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)

	-- Set some keybinds conditional on server capabilities
	if client.resolved_capabilities.document_formatting then
		map.n('<space>f', '<Cmd>lua vim.lsp.buf.formatting()<CR>', opts)
	elseif client.resolved_capabilities.document_range_formatting then
		map.n('<space>f', '<Cmd>lua vim.lsp.buf.range_formatting()<CR>', opts)
	end
end
-- }}}
-- {{{ LSP servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
;(function()
	capabilities.textDocument.completion.completionItem.snippetSupport = false
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
			on_attach = on_attach,
			capabilities = capabilities,
			flags = {
				debounce_text_changes = 150,
			}
		}
	end
end)()
-- }}}
-- {{{ LSP features
vim.lsp.handlers['textDocument/publishDiagnostics'] = vim.lsp.with(
	vim.lsp.diagnostic.on_publish_diagnostics, {
		underline = true,
		virtual_text = true,
		signs = true,
		update_in_insert = false,
	})
-- Map :Format to vim.lsp.buf.formatting()
vim.cmd([[command! Format execute 'lua vim.lsp.buf.formatting()']])
-- Allow for virtual text to be toggled
vim.b.lsp_virtual_text_enabled = true

local diagnostic_toggle_virtual_text = function()
	local virtual_text = vim.b.lsp_virtual_text_enabled
	virtual_text = not virtual_text
	vim.b.lsp_virtual_text_enabled = virtual_text
	vim.lsp.diagnostic.display(vim.lsp.diagnostic.get(0, 1), 0, 1, { virtual_text = virtual_text })
end
-- }}}
-- {{{ LSP Lua server
;(function(lsp, cap, global, on_attach_cb)
	local sumneko_root_path = vim.fn.getenv('XDG_DATA_HOME') .. '/lua-language-server'
	local sumneko_binary_path = '/bin/Linux/lua-language-server'
	table.insert(global, 'vim')
	table.insert(global, 'use_rocks')
	-- Make runtime files discoverable to the server
	local runtime_path = vim.split(package.path, ';')
	table.insert(runtime_path, 'lua/?.lua')
	table.insert(runtime_path, 'lua/?/init.lua')
	local settings = {
		Lua = {
			runtime = {
				version = 'LuaJIT',
				path = runtime_path,
			},
			completion = {
				enable = true,
				callSnippet = 'Both'
			},
			diagnostics = {
				enable = true,
				globals = global,
				disable = {'lowercase-global'}
			},
			workspace = {
				library = vim.api.nvim_get_runtime_file('', true),
				maxPreload = 2000,
				preloadFileSize = 1000
			},
			telemetry = {
				enable = false,
			}
		}
	}
	lsp.sumneko_lua.setup {
		cmd = { sumneko_root_path .. sumneko_binary_path, '-E', sumneko_root_path .. '/main.lua' };
		on_attach = on_attach_cb,
		capabilities = cap,
		settings = settings
	}
end)(nvim_lsp, capabilities, globals, on_attach)
-- }}}
-- {{{ LSP diagnostics on CursorHold
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
		autocmd CursorHold * lua vim.lsp.diagnostic.show_line_diagnostics({focusable = false})
	augroup end
]], false)
-- }}}
-- {{{ Treesitter
treesitter_init = function()
	require'nvim-treesitter.configs'.setup {
		-- debatable whether this should be commented or not
		-- ensure_installed = 'maintained', -- one of 'all', 'maintained' (parsers with maintainers), or a list of languages
		ensure_installed = 'maintained',
		highlight = {
			enable = true,              -- false will disable the whole extension
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
				lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
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
				set_jumps = true, -- whether to set jumps in the jumplist
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
-- {{{ Linter
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
	vim.api.nvim_exec([[
		augroup Linter
			autocmd! * <buffer>
			autocmd BufWritePost * lua require'lint'.try_lint()
		augroup end
	]], false)
end
-- }}}
-- {{{ Indent guides
indent_init = function()
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
end
-- }}}
-- {{{ Gitsigns init
gitsigns_init = function()
	require'gitsigns'.setup{
		signs = {
			add = { hl = 'GitGutterAdd', text = '+' },
			change = { hl = 'GitGutterChange', text = '~' },
			delete = { hl = 'GitGutterDelete', text = '_' },
			topdelete = { hl = 'GitGutterDelete', text = '‾' },
			changedelete = { hl = 'GitGutterChange', text = '~' },
		},
	}
end
-- }}}
-- {{{ Autopairs
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
	require("nvim-autopairs.completion.compe").setup({
		map_cr = true,
		map_complete = true
	})
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

nmap('<F4>', '<Cmd>lua toggle_mouse()<CR>')
-- }}}
-- {{{ lualine statusbar
lualine_init = function()
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
end
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
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

opts = { noremap = true, expr = true, silent = true }

-- Lua test mapping

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
nmap('<C-g>', ':Rg<CR>')
-- nmap('<C-q>', ':q<CR>')
nmap('<C-s>', ':w<CR>')
nmap('<C-t>', ':Telescope fd<CR>')
nmap('u', ':undo<CR>')
nmap('U', ':redo<CR>')

-- clear hls
nmap('<C-h>', ':noh<CR>')

-- Create splits with s and S
nmap('<C-w>s', ':vsplit<CR>:wincmd l<CR>')

-- Create, close, and move between tabs
nmap('<M-N>', ':tabnew<CR>')
nmap('<M-M>', ':tabclose<CR>')
nmap('<M-b>', ':tabprevious<CR>')
nmap('<M-n>', ':tabnext<CR>')

-- Cycle through open buffers
nmap('<leader>.', ':bnext<CR>')
nmap('<leader>,', ':bprevious<CR>')
nmap('<M-.>', ':bnext<CR>')
nmap('<M-,>', ':bprevious<CR>')

-- Change to file directory in current window
nmap('<leader>cd', ':lcd %:p:h<CR>:pwd<CR>')

-- Save all.
nmap('<C-M-s>', ':wa<CR>')

-- Search and replace using marked text
vmap('<C-r>', '"hy:%s/<C-r>h//gc<left><left><left>')

-- Don't yank when using delete
nmap('<del>', '"_x')
nmap('x', '"_x')

-- Y yank until the end of line
nmap('Y', 'y$')

-- q as b
nmap('q', 'b')
nmap('Q', 'B')

-- Save session
-- nmap('<F6>', '<Cmd>wa<Bar>exe "mksession! " . v:this_session<CR><Cmd>echo "Session saved!"<CR>')
nmap('<F6>', '<Cmd>SaveSession<CR><Cmd>echo "Session saved!"<CR>')

-- Update Plugins
nmap('<leader>U', '<Cmd>PackerUpdate<CR>')
nmap('<leader>C', '<Cmd>PackerCompile<CR><Cmd>echo "Compiled!"<CR>')

-- Transpose lines
opts = { noremap = true, silent = true }
nmap('<S-Up>', '<Cmd>move .-2<CR>', opts)
nmap('<S-Down>', '<Cmd>move .+1<CR>', opts)
-- need to leave visual mode (:) for the mark to be set
vmap('<S-Up>', ':move \'<-2<CR>gv=gv', opts)
vmap('<S-Down>', ':move \'>+1<CR>gv=gv', opts);
-- }}}
-- {{{ Abbreviations
-- Force write with sudo, two different approaches
vim.cmd[[com! -bang W lua SudoWrite('<bang>' == '!')]]
SudoWrite = function(bang)
	if not bang then
		print('Add ! to use sudo.')
	else
		vim.api.nvim_exec([[
			w! /tmp/sudonvim
			bel 2new
			startinsert
			te sudo tee #:S </tmp/sudonvim >/dev/null; rm /tmp/sudonvim
		]], false)
	end
end
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
nmap('<leader>M', [[<Cmd>lua GenerateModeline()<CR>]])
-- }}}
-- {{{ Telescope
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
nmap('<leader>i', [[<Cmd>lua require'telescope.builtin'.live_grep()<CR>]], opts)
nmap('<leader>F', [[<Cmd>lua require'telescope.builtin'.grep_string()<CR>]], opts)
nmap('<leader>o', [[<Cmd>lua require('telescope.builtin').tags{ only_current_buffer = true }<CR>]], opts)
nmap('<leader>Gc', [[<Cmd>lua require'telescope.builtin'.git_commits()<CR>]], opts)
nmap('<leader>Gb', [[<Cmd>lua require'telescope.builtin'.git_branches()<CR>]], opts)
nmap('<leader>Gs', [[<Cmd>lua require'telescope.builtin'.git_status()<CR>]], opts)
nmap('<leader>Gp', [[<Cmd>lua require'telescope.builtin'.git_bcommits()<CR>]], opts)
nmap('<leader>g', [[<Cmd>lua require'telescope.builtin'.git_files()<CR>]], opts)
-- Extensions
nmap('<leader><Tab>', [[<Cmd>lua require'telescope'.extensions.frecency.frecency()<CR>]], opts)
nmap('<leader>S', [[<Cmd>lua require'telescope'.extensions.session_manager.load()<CR>]], opts)
-- Change preview window location
vim.g.splitbelow = true
-- }}}
-- {{{ gutentags
-- vim.g.gutentags_cache_dir = vim.fn.stdpath('cache') .. '/tags'
vim.g.gutentags_ctags_tagfile = '.tags'
-- }}}
-- {{{ Compe
compe_init = function()
	require'compe'.setup {
		enabled = true,
		autocomplete = true,
		debug = false,
		min_length = 2,
		preselect = 'enable',
		throttle_time = 80,
		source_timeout = 200,
		incomplete_delay = 400,
		max_abbr_width = 100,
		max_kind_width = 100,
		max_menu_width = 100,
		documentation = {
			border = { '', '' ,'', ' ', '', '', '', ' ' },
			winhighlight = 'NormalFloat:CompeDocumentation,FloatBorder:CompeDocumentationBorder',
			max_width = 120,
			min_width = 60,
			max_height = math.floor(vim.o.lines * 0.3),
			min_height = 1,
		},
		source = {
			buffer = true,
			calc = false,
			nvim_lua = true,
			nvim_lsp = true,
			path = false,
			tags = true,
			luasnip = false,
			vsnip = false,
			ultisnip = false,
		},
	}
end

-- Insert mode mappings
opts = { silent = true, expr = true  }
imap('<C-Space>', 'compe#complete()', opts)
-- imap('<CR>', "compe#confirm('<CR>')", opts)
imap('<C-e>', "compe#close('<C-e>')", opts)
imap('<C-f>', "compe#scroll({ 'delta': +4 }", opts)
imap('<C-d>', "compe#scroll({ 'delta': -4 }", opts)
-- }}}
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
		return t '<C-n>'
	elseif check_back_space() then
		return t '<Tab>'
	else
		return vim.fn['compe#complete']()
	end
end

_G.s_tab_complete = function()
	if vim.fn.pumvisible() == 1 then
		return t '<C-p>'
	else
		return t '<S-Tab>'
	end
end

imap('<Tab>', 'v:lua.tab_complete()', {expr = true})
smap('<Tab>', 'v:lua.tab_complete()', {expr = true})
imap('<S-Tab>', 'v:lua.s_tab_complete()', {expr = true})
smap('<S-Tab>', 'v:lua.s_tab_complete()', {expr = true})
-- }}}
-- {{{ Luapad
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
		autocmd TermOpen * tnoremap <buffer> <Esc> <c-\><c-n>
		autocmd TermOpen * set nonu
	augroup end
]], false);
-- Markdown filetype for bare textfiles
vim.api.nvim_exec([[
	augroup MarkdownText
		autocmd!
		autocmd BufNewFile,BufRead *.txt setlocal ft=markdown
	augroup end
]], false);
-- }}}
-- {{{ Theme/GUI
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
ex.colorscheme([[dracula]])
vim.opt.guicursor:append({ 'i:ver100-iCursor', 'i:blinkon2' })
vim.o.guifont = 'Fira Code:h14'
-- }}}
-- {{{ Staging area
-- Neovide
vim.g.neovide_refresh_rate = 60
vim.g.neovide_cursor_antialiasing = false
vim.g.neovide_cursor_vfx_mode = 'pixiedust'
-- }}}
