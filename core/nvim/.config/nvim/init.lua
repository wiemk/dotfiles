-- https://github.com/mjlbach/defaults.nvim/blob/master/init.lua
--
-- vim: ft=lua ts=4 sw=4 sts=-1 et
--
-- Install packer
local install_path = vim.fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'

if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
    vim.fn.system({'git', 'clone', 'https://github.com/wbthomason/packer.nvim', install_path})
    vim.api.nvim_command 'packadd packer.nvim'
end

function _G.dump(...)
    local objects = vim.tbl_map(vim.inspect, {...})
    print(unpack(objects))
end

vim.api.nvim_exec([[
    augroup Packer
        autocmd!
        autocmd BufWritePost init.lua PackerCompile
    augroup end
]], false)

local use = require('packer').use
require('packer').startup(function()
    use 'wbthomason/packer.nvim'          -- Package manager
    use 'tpope/vim-fugitive'              -- Git commands in nvim
    use 'tpope/vim-commentary'            -- "gc" to comment visual regions/lines
    use 'ludovicchabant/vim-gutentags'    -- Automatic tags management
    -- UI to select things (files, grep results, open buffers...)
    use {'nvim-telescope/telescope.nvim', requires = {{'nvim-lua/popup.nvim'}, {'nvim-lua/plenary.nvim'}} }
    use 'joshdick/onedark.vim'            -- Theme inspired by Atom
    use { 'hoob3rt/lualine.nvim', requires = {'kyazdani42/nvim-web-devicons', opt = true} }
    -- Add git related info in the signs columns and popups
    use {'lewis6991/gitsigns.nvim', requires = {'nvim-lua/plenary.nvim'} }
    use 'neovim/nvim-lspconfig'           -- Collection of configurations for built-in LSP client
    use 'hrsh7th/nvim-compe'              -- Autocompletion plugin
    use 'nvim-treesitter/nvim-treesitter' -- Language parser
    use 'mfussenegger/nvim-lint'          -- External linter support
	use 'glepnir/indent-guides.nvim'      -- Indent guides for spaces
end)

-- Disable netrw
vim.g.loaded_netrwPlugin = 1

-- Do not show the startup message
vim.o.shortmess = vim.o.shortmess .. "I"

-- Incremental live completion
vim.o.inccommand = "nosplit"

-- Set highlight on search
vim.o.hlsearch = false
vim.o.incsearch = true

-- Make line numbers default
vim.wo.number = true

-- Do not save when switching buffers
vim.o.hidden = true

--Do not show x on last line
vim.o.showmode = false
vim.o.showcmd = false

--Enable mouse mode
vim.o.mouse = "a"

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
vim.wo.wrap = true
vim.wo.linebreak = true
vim.bo.textwidth = 100
vim.o.textwidth = 100
vim.wo.colorcolumn = "+1"

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
vim.g.onedark_terminal_italics = 2
vim.wo.cursorline = true
vim.wo.cursorcolumn = true
vim.api.nvim_command([[colorscheme onedark]])

-- Add map to enter paste mode
vim.o.pastetoggle="<F3>"

-- Toggle to disable mouse mode and indentlines for easier paste
local signbak = vim.wo.signcolumn
local numbak = vim.wo.number
local wlistbak = vim.wo.list
local nomouse = false

ToggleMouse = function()
    if vim.o.mouse == 'a' then
        vim.wo.signcolumn = 'no'
        vim.o.mouse = 'v'
        vim.wo.number = false
        vim.wo.list = false
        nomouse = true
    else
        vim.wo.signcolumn = signbak
        vim.o.mouse = 'a'
        vim.wo.number = numbak
        vim.wo.list = wlistbak
        nomouse = false
    end
end

-- Local utility functions
local _bindkey = function(table, bind, action, special)
    if special == nil then
        special = { noremap = true }
    end
    vim.api.nvim_set_keymap(table, bind, action, special)
end
local nn = function(bind, action, special)
    _bindkey('n', bind, action, special)
end
local vn = function(bind, action, special)
    _bindkey('v', bind, action, special)
end
local xn = function(bind, action, special)
    _bindkey('x', bind, action, special)
end


nn('<F4>', '<CMD>lua ToggleMouse()<CR>')

-- LSP settings
local nvim_lsp = require('lspconfig')
local on_attach = function(client, bufnr)
    vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

    local function buf_set_keymap(...)
        vim.api.nvim_buf_set_keymap(bufnr, ...)
    end
    local function buf_set_option(...)
        vim.api.nvim_buf_set_option(bufnr, ...)
    end

    local opts = { noremap=true, silent=true }
    buf_set_keymap('n', 'gD', '<Cmd>lua vim.lsp.buf.declaration()<CR>', opts)
    buf_set_keymap('n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
    buf_set_keymap('n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
    buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
    buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
    buf_set_keymap('n', '<leader>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
    buf_set_keymap('n', '<leader>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
    buf_set_keymap('n', '<leader>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
    buf_set_keymap('n', '<leader>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
    buf_set_keymap('n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
    buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
    buf_set_keymap('n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
    buf_set_keymap('n', '<leader>e', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)
    buf_set_keymap('n', '[d', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
    buf_set_keymap('n', ']d', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
    buf_set_keymap('n', '<leader>q', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)

    -- Set some keybinds conditional on server capabilities
    if client.resolved_capabilities.document_formatting then
        buf_set_keymap("n", "<space>f", "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)
    elseif client.resolved_capabilities.document_range_formatting then
        buf_set_keymap("n", "<space>f", "<cmd>lua vim.lsp.buf.range_formatting()<CR>", opts)
    end

end

-- Enable the following language servers
local servers = {
--    'clangd',
--    'dockerls',
--    'bashls',
--    'cmake',
--    'gopls',
--    'rust_analyzer',
--    'pyright',
--    'tsserver'
}
for _, lsp in ipairs(servers) do
    nvim_lsp[lsp].setup {
        on_attach = on_attach
    }
end

vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
    vim.lsp.diagnostic.on_publish_diagnostics, {
        underline = true,
        virtual_text = true,
        signs = true,
        update_in_insert = true,
    }
)

-- Lua language server
local sumneko_root_path = vim.fn.getenv("XDG_DATA_HOME") .. "/lua-language-server"
local sumneko_binary_path = "/bin/Linux/lua-language-server" -- Change to your OS specific output folder
nvim_lsp.sumneko_lua.setup {
    cmd = {sumneko_root_path .. sumneko_binary_path, "-E", sumneko_root_path .. "/main.lua" };
    on_attach = on_attach,
    settings = {
        Lua = {
            runtime = {
                version = 'LuaJIT',
                path = vim.split(package.path, ';'),
            },
            diagnostics = {
                globals = {'vim'},
            },
            workspace = {
                library = {
                    [vim.fn.expand('$VIMRUNTIME/lua')] = true,
                    [vim.fn.expand('$VIMRUNTIME/lua/vim/lsp')] = true,
                },
            },
        },
    },
}

-- Map :Format to vim.lsp.buf.formatting()
vim.cmd([[command! Format vim.api.nvim_command 'lua vim.lsp.buf.formatting()']])

-- Treesitter
require'nvim-treesitter.configs'.setup {
    -- debatable whether this should be commented or not
    -- ensure_installed = "maintained", -- one of "all", "maintained" (parsers with maintainers), or a list of languages
    ensure_installed = "maintained",
    highlight = {
        enable = true,              -- false will disable the whole extension
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
}

-- nvim-lint for external linting
local lint = require('lint')
lint.linters_by_ft = {
    sh = {'shellcheck',},
    bash = {'shellcheck',},
}

vim.api.nvim_exec([[
    augroup Linter
        autocmd!
        autocmd BufWritePost <buffer> lua require('lint').try_lint()
    augroup end
]], false)

-- Set statusbar
require('lualine').setup({
    options = {
        theme = 'onedark';
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
})

-- Remap space as leader key
vim.api.nvim_set_keymap('', '<Space>', '<Nop>', {noremap = true, silent = true})
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Remap for dealing with word wrap
local special = { noremap = true, expr = true, silent = true }
nn('k', "v:count == 0 ? 'gk' : 'k'", special)
nn('j', "v:count == 0 ? 'gj' : 'j'", special) 

-- Remap escape to leave terminal mode
vim.api.nvim_exec([[
    augroup Terminal
        autocmd!
        au TermOpen * tnoremap <buffer> <Esc> <c-\><c-n>
        au TermOpen * set nonu
    augroup end
]], false)

KeepState = function(callback, ...)
    local view = vim.fn.winsaveview()
    callback(...)
    vim.fn.winrestview(view)
end

WhiteTrimLines = function()
    KeepState(vim.api.nvim_command, [[keeppatterns %s/\s\+$//e]])
end
WhiteTrimEmpty = function()
    KeepState(vim.api.nvim_command, [[keeppatterns :v/\_s*\S/d]])
end

-- White handling
vim.cmd([[command! TrimTrailingWhite lua WhiteTrimLines()]])
vim.cmd([[command! TrimTralingLines lua WhiteTrimEmpty()]])
vim.cmd([[command! TrimAll lua WhiteTrimEmpty(); WhiteTrimLines()]])

-- Do not copy when pasting
xn("p", "pgvy")

-- J and K to move up and down
nn("J", "}")
nn("K", "{")
vn("J", "}")
vn("K", "{")

-- H and L to move to the beginning and end of a line
nn("H", "_")
nn("L", "$")
vn("H", "_")
vn("L", "$")

nn("<C-f>", "/")
nn("<C-g>", ":Rg<CR>")
nn("<C-q>", ":q<CR>")
nn("<C-s>", ":w<CR>")
nn("<C-t>", ":Telescope fd<CR>")
nn("u", ":undo<CR>")
nn("U", ":redo<CR>")

-- Create splits with s and S
nn("<C-w>s", ":vsplit<CR>:wincmd l<CR>")

-- Create, close, and move between tabs
nn("<M-N>", ":tabnew<CR>")
nn("<M-n>", ":tabprevious<CR>")
nn("<M-m>", ":tabnext<CR>")
nn("<M-M>", ":tabclose<CR>")

-- Cycle through open buffers
nn("<leader>.", ":bnext<CR>")
nn("<leader>,", ":bprevious<CR>")
nn("<leader>- ", ":bdelete<CR>")

-- Change to file directory in current window
nn("<leader>cd", ":lcd %:p:h<CR>:pwd<CR>")

-- Save all.
nn("<C-M-s>", ":wa<CR>")

-- Search and replace using marked text
vn("<C-r>", "\"hy:%s/<C-r>h//gc<left><left><left>")

-- Hide cmdline after entering a command
vim.api.nvim_exec([[
    augroup cmdline
        autocmd!
        autocmd CmdlineLeave : echo ""
    augroup end
]], false)

-- Show diagnostics on CursorHold
vim.cmd([[autocmd CursorHold * lua vim.lsp.diagnostic.show_line_diagnostics()]])

-- Telescope
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
nn('<leader>f', [[<cmd>lua require('telescope.builtin').find_files()<cr>]], special)
nn('<leader>b', [[<cmd>lua require('telescope.builtin').buffers()<cr>]], special)
nn('<leader>r', [[<cmd>lua require('telescope.builtin').registers()<cr>]], special)
nn('<leader>l', [[<cmd>lua require('telescope.builtin').current_buffer_fuzzy_find()<cr>]], special)
nn('<leader><space>', [[<cmd>lua require('telescope.builtin').marks()<cr>]], special)
nn('<leader>m', [[<cmd>lua require('telescope.builtin').marks()<cr>]], special)
nn('<leader>t', [[<cmd>lua require('telescope.builtin').tags()<cr>]], special)
nn('<leader>?', [[<cmd>lua require('telescope.builtin').oldfiles()<cr>]], special)
nn('<leader>sd', [[<cmd>lua require('telescope.builtin').grep_string()<cr>]], special)
nn('<leader>sp', [[<cmd>lua require('telescope.builtin').live_grep()<cr>]], special)
nn('<leader>o', [[<cmd>lua require('telescope.builtin').tags{ only_current_buffer = true }<cr>]], special)
nn('<leader>gc', [[<cmd>lua require('telescope.builtin').git_commits()<cr>]], special)
nn('<leader>gb', [[<cmd>lua require('telescope.builtin').git_branches()<cr>]], special)
nn('<leader>gs', [[<cmd>lua require('telescope.builtin').git_status()<cr>]], special)
nn('<leader>gp', [[<cmd>lua require('telescope.builtin').git_bcommits()<cr>]], special)

-- Change preview window location
vim.g.splitbelow = true

-- Highlight on yank
vim.api.nvim_exec([[
    augroup YankHighlight
        autocmd!
        autocmd TextYankPost * silent! lua vim.highlight.on_yank()
    augroup end
]], false)

-- Y yank until the end of line
vim.api.nvim_set_keymap('n', 'Y', 'y$', { noremap = true})

-- gutentags setup
vim.g.gutentags_cache_dir = vim.fn.stdpath('cache') .. '/tags'

-- Set completeopt to have a better completion experience
vim.o.completeopt="menuone,noinsert"
vim.o.shortmess = vim.o.shortmess .. "c"

-- Compe setup
require'compe'.setup {
    enabled = true;
    autocomplete = true;
    debug = false;
    min_length = 1;
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
        nvim_lsp = true;
        path = true;
    };
}

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

vim.api.nvim_set_keymap("i", "<Tab>", "v:lua.tab_complete()", {expr = true})
vim.api.nvim_set_keymap("s", "<Tab>", "v:lua.tab_complete()", {expr = true})
vim.api.nvim_set_keymap("i", "<S-Tab>", "v:lua.s_tab_complete()", {expr = true})
vim.api.nvim_set_keymap("s", "<S-Tab>", "v:lua.s_tab_complete()", {expr = true})

-- indent-guides
require('indent_guides').setup({
    indent_guide_size = 1;
    indent_start_level = 1;
    indent_levels = 16;
    indent_enable = true;
    indent_space_guides = true;
    indent_tab_guides = true;
    indent_soft_pattern = '\\s';
    exclude_filetypes = {'help','dashboard','dashpreview','NvimTree','vista','sagahover'};
    -- even_colors = { fg ='#2a3834',bg='#332b36' };
    -- odd_colors = { fg='#332b36',bg='#2a3834' };
})

