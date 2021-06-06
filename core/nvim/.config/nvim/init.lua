-- https://github.com/mjlbach/defaults.nvim/blob/master/init.lua
--
-- Install packer
local execute = vim.api.nvim_command
local fn = vim.fn

local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'

if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({'git', 'clone', 'https://github.com/wbthomason/packer.nvim', install_path})
    execute 'packadd packer.nvim'
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
    use 'tpope/vim-rhubarb'               -- Fugitive-companion to interact with github
    use 'tpope/vim-commentary'            -- "gc" to comment visual regions/lines
    use 'ludovicchabant/vim-gutentags'    -- Automatic tags management
    -- UI to select things (files, grep results, open buffers...)
    use {'nvim-telescope/telescope.nvim', requires = {{'nvim-lua/popup.nvim'}, {'nvim-lua/plenary.nvim'}} }
    use 'joshdick/onedark.vim'            -- Theme inspired by Atom
    use 'itchyny/lightline.vim'           -- Fancier statusline
    -- Add indentation guides even on blank lines
    use { 'lukas-reineke/indent-blankline.nvim', branch="lua" }
    -- Add git related info in the signs columns and popups
    use {'lewis6991/gitsigns.nvim', requires = {'nvim-lua/plenary.nvim'} }
    use 'neovim/nvim-lspconfig'           -- Collection of configurations for built-in LSP client
    use 'hrsh7th/nvim-compe'              -- Autocompletion plugin
    use 'nvim-treesitter/nvim-treesitter' -- Language parser
    use 'mfussenegger/nvim-lint'          -- External linter support
    use 'kyazdani42/nvim-tree.lua'        -- File explorer
end)

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
vim.o.shiftwidth = 4;
vim.bo.expandtab = true;
vim.o.expandtab = true;
vim.bo.softtabstop = -1;
vim.o.softtabstop = -1;
vim.bo.copyindent = true;

-- Autoreload files changed outside vim
vim.o.autoread = true

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undodir = fn.stdpath('cache') .. '/undo'
vim.bo.undofile = true

vim.o.directory = fn.stdpath('cache') .. '/swap'
vim.o.backup = false
vim.o.writebackup = true
vim.o.swapfile = true

-- Show whitespace characters
vim.wo.list = true
vim.o.listchars = "space:·,tab:» ,eol:¬"

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
vim.cmd[[colorscheme onedark]]

-- Set statusbar
vim.g.lightline = { colorscheme = 'onedark';
    active = { left = { { 'mode', 'paste' }, { 'gitbranch', 'readonly', 'filename', 'modified' } } };
    component_function = { gitbranch = 'fugitive#head', };
}

-- Remap space as leader key
vim.api.nvim_set_keymap('', '<Space>', '<Nop>', { noremap = true, silent=true})
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Remap for dealing with word wrap
vim.api.nvim_set_keymap('n', 'k', "v:count == 0 ? 'gk' : 'k'", {noremap=true, expr = true, silent = true})
vim.api.nvim_set_keymap('n', 'j', "v:count == 0 ? 'gj' : 'j'", {noremap= true, expr = true, silent = true})

-- Remap escape to leave terminal mode
vim.api.nvim_exec([[
    augroup Terminal
        autocmd!
        au TermOpen * tnoremap <buffer> <Esc> <c-\><c-n>
        au TermOpen * set nonu
    augroup end
]], false)

-- Add map to enter paste mode
vim.o.pastetoggle="<F3>"

-- Map blankline
vim.g.indent_blankline_char = "┊"
vim.g.indent_blankline_filetype_exclude = { 'help', 'packer' }
vim.g.indent_blankline_buftype_exclude = { 'terminal', 'nofile'}
vim.g.indent_blankline_char_highlight = 'LineNr'

-- Toggle to disable mouse mode and indentlines for easier paste
local signbak = vim.wo.signcolumn
local numbak = vim.wo.number
local wlistbak = vim.wo.list

ToggleMouse = function()
    if vim.o.mouse == 'a' then
        vim.cmd[[IndentBlanklineDisable]]
        vim.wo.signcolumn = 'no'
        vim.o.mouse = 'v'
        vim.wo.number = false
        vim.wo.list = false
        print("Mouse disabled")
    else
        vim.cmd[[IndentBlanklineEnable]]
        vim.wo.signcolumn = signbak
        vim.o.mouse = 'a'
        vim.wo.number = numbak
        vim.wo.list = wlistbak
        print("Mouse enabled")
    end
end

vim.api.nvim_set_keymap('n', '<F10>', '<cmd>lua ToggleMouse()<cr>', { noremap = true })

-- Do not copy when pasting
vim.api.nvim_set_keymap("x", "p", "pgvy", { noremap = true })

-- J and K to move up and down
vim.api.nvim_set_keymap("n", "J", "}", { noremap = true })
vim.api.nvim_set_keymap("n", "K", "{", { noremap = true })
vim.api.nvim_set_keymap("v", "J", "}", { noremap = true })
vim.api.nvim_set_keymap("v", "K", "{", { noremap = true })

-- H and L to move to the beginning and end of a line
vim.api.nvim_set_keymap("n", "H", "_", { noremap = true })
vim.api.nvim_set_keymap("n", "L", "$", { noremap = true })
vim.api.nvim_set_keymap("v", "H", "_", { noremap = true })
vim.api.nvim_set_keymap("v", "L", "$", { noremap = true })

vim.api.nvim_set_keymap("n", "<C-f>", "/", { noremap = true })
vim.api.nvim_set_keymap("n", "<C-g>", ":Rg<CR>", { noremap = true })
vim.api.nvim_set_keymap("n", "<C-q>", ":q<CR>", { noremap = true })
vim.api.nvim_set_keymap("n", "<C-s>", ":w<CR>", { noremap = true })
vim.api.nvim_set_keymap("n", "<C-t>", ":Telescope fd<CR>", { noremap = true })
vim.api.nvim_set_keymap("n", "u", ":undo<CR>", { noremap = true })
vim.api.nvim_set_keymap("n", "U", ":redo<CR>", { noremap = true })

-- Create splits with s and S
vim.api.nvim_set_keymap("n", "<C-w>s", ":vsplit<CR>:wincmd l<CR>", { noremap = true })

-- Move between splits.
--vim.g.tmux_navigator_no_mappings = 1
--vim.api.nvim_set_keymap("n", "<M-h>", "TmuxNavigateLeft<CR>", { noremap = true })
--vim.api.nvim_set_keymap("n", "<M-j>", "TmuxNavigateDown<CR>", { noremap = true })
--vim.api.nvim_set_keymap("n", "<M-k>", "TmuxNavigateUp<CR>", { noremap = true })
--vim.api.nvim_set_keymap("n", "<M-l>", "TmuxNavigateRight<CR>", { noremap = true })

-- Create, close, and move between tabs
vim.api.nvim_set_keymap("n", "<M-N>", ":tabnew<CR>", { noremap = true })
vim.api.nvim_set_keymap("n", "<M-n>", ":tabprevious<CR>", { noremap = true })
vim.api.nvim_set_keymap("n", "<M-m>", ":tabnext<CR>", { noremap = true })
vim.api.nvim_set_keymap("n", "<M-M>", ":tabclose<CR>", { noremap = true })

-- Save all.
vim.api.nvim_set_keymap("n", "<C-M-s>", ":wa<CR>", { noremap = true })

-- Hide cmdline after entering a command
vim.cmd([[
    augroup cmdline
        autocmd!
        autocmd CmdlineLeave : echo ""
    augroup end
]])

-- Disable filetype detection.
--vim.cmd [[
--  filetype off
--  filetype plugin indent off
--]]

-- Show diagnostics on CursorHold
vim.cmd [[
    autocmd CursorHold * lua vim.lsp.diagnostic.show_line_diagnostics()
]]

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
vim.api.nvim_set_keymap('n', '<leader>f', [[<cmd>lua require('telescope.builtin').find_files()<cr>]], { noremap = true, silent = true})
vim.api.nvim_set_keymap('n', '<leader><space>', [[<cmd>lua require('telescope.builtin').buffers()<cr>]], { noremap = true, silent = true})
vim.api.nvim_set_keymap('n', '<leader>l', [[<cmd>lua require('telescope.builtin').current_buffer_fuzzy_find()<cr>]], { noremap = true, silent = true})
vim.api.nvim_set_keymap('n', '<leader>t', [[<cmd>lua require('telescope.builtin').tags()<cr>]], { noremap = true, silent = true})
vim.api.nvim_set_keymap('n', '<leader>?', [[<cmd>lua require('telescope.builtin').oldfiles()<cr>]], { noremap = true, silent = true})
vim.api.nvim_set_keymap('n', '<leader>sd', [[<cmd>lua require('telescope.builtin').grep_string()<cr>]], { noremap = true, silent = true})
vim.api.nvim_set_keymap('n', '<leader>sp', [[<cmd>lua require('telescope.builtin').live_grep()<cr>]], { noremap = true, silent = true})
vim.api.nvim_set_keymap('n', '<leader>o', [[<cmd>lua require('telescope.builtin').tags{ only_current_buffer = true }<cr>]], { noremap = true, silent = true})
vim.api.nvim_set_keymap('n', '<leader>gc', [[<cmd>lua require('telescope.builtin').git_commits()<cr>]], { noremap = true, silent = true})
vim.api.nvim_set_keymap('n', '<leader>gb', [[<cmd>lua require('telescope.builtin').git_branches()<cr>]], { noremap = true, silent = true})
vim.api.nvim_set_keymap('n', '<leader>gs', [[<cmd>lua require('telescope.builtin').git_status()<cr>]], { noremap = true, silent = true})
vim.api.nvim_set_keymap('n', '<leader>gp', [[<cmd>lua require('telescope.builtin').git_bcommits()<cr>]], { noremap = true, silent = true})

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

-- LSP settings
local nvim_lsp = require('lspconfig')
local on_attach = function(_client, bufnr)
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
    'clangd',
    'dockerls',
    'bashls',
    'cmake',
    'gopls',
    'rust_analyzer',
    'pyright',
    'tsserver'
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
local sumneko_root_path = fn.getenv("HOME").."/.local/bin/sumneko_lua" -- Change to your sumneko root installation
local sumneko_binary_path = "/bin/linux/lua-language-server" -- Change to your OS specific output folder
nvim_lsp.sumneko_lua.setup {
    cmd = {sumneko_root_path .. sumneko_binary_path, "-E", sumneko_root_path.."/main.lua" };
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
                    [fn.expand('$VIMRUNTIME/lua')] = true,
                    [fn.expand('$VIMRUNTIME/lua/vim/lsp')] = true,
                },
            },
        },
    },
}

-- Map :Format to vim.lsp.buf.formatting()
vim.cmd([[ command! Format execute 'lua vim.lsp.buf.formatting()' ]])

-- gutentags setup
vim.g.gutentags_cache_dir = fn.stdpath('cache') .. '/tags' 

-- Set completeopt to have a better completion experience
vim.o.completeopt="menuone,noinsert"

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
        path = true;
        nvim_lsp = true;
    };
}

local t = function(str)
    return vim.api.nvim_replace_termcodes(str, true, true, true)
end

local check_back_space = function()
    local col = fn.col('.') - 1
    if col == 0 or fn.getline('.'):sub(col, col):match('%s') then
        return true
    else
        return false
    end
end

-- Use (s-)tab to:
--- move to prev/next item in completion menuone
--- jump to prev/next snippet's placeholder
_G.tab_complete = function()
    if fn.pumvisible() == 1 then
        return t "<C-n>"
    elseif check_back_space() then
        return t "<Tab>"
    else
        return fn['compe#complete']()
    end
end
_G.s_tab_complete = function()
    if fn.pumvisible() == 1 then
        return t "<C-p>"
    else
        return t "<S-Tab>"
    end
end

vim.api.nvim_set_keymap("i", "<Tab>", "v:lua.tab_complete()", {expr = true})
vim.api.nvim_set_keymap("s", "<Tab>", "v:lua.tab_complete()", {expr = true})
vim.api.nvim_set_keymap("i", "<S-Tab>", "v:lua.s_tab_complete()", {expr = true})
vim.api.nvim_set_keymap("s", "<S-Tab>", "v:lua.s_tab_complete()", {expr = true})

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
require('lint').linters_by_ft = {
    sh = {'shellcheck',},
    bash = {'shellcheck',}
}

vim.api.nvim_exec([[
    augroup Linter
        autocmd!
        autocmd BufWritePost <buffer> lua require('lint').try_lint()
    augroup end
]], false)

-- nvim-tree
vim.g.nvim_tree_side = "left"
vim.g.nvim_tree_width = 24
vim.g.nvim_tree_ignore = {".git", "node_modules", ".cache"}
vim.g.nvim_tree_auto_open = 0
vim.g.nvim_tree_auto_close = 0
vim.g.nvim_tree_quit_on_open = 0
vim.g.nvim_tree_follow = 1
vim.g.nvim_tree_indent_markers = 1
vim.g.nvim_tree_hide_dotfiles = 0
vim.g.nvim_tree_git_hl = 1
vim.g.nvim_tree_root_folder_modifier = ":~"
vim.g.nvim_tree_tab_open = 1
vim.g.nvim_tree_allow_resize = 1
vim.g.nvim_tree_add_trailing = 1

vim.g.nvim_tree_show_icons = {
    git = 1,
    folders = 1,
    files = 1,
    folder_arrows = 1
}

vim.g.nvim_tree_icons = {
    default = "",
    symlink = "",
    git = {
        unstaged = "✗",
        staged = "✓",
        unmerged = "",
        renamed = "➜",
        untracked = "★"
    },
    folder = {
        default = "",
        open = "",
        symlink = ""
    }
}

vim.api.nvim_set_keymap("n", "<C-n>", ":NvimTreeToggle<CR>", { noremap = true })
vim.api.nvim_set_keymap("n", "<leader>r", ":NvimTreeRefresh<CR>", { noremap = true })
vim.api.nvim_set_keymap("n", "<leader>n", ":NvimTreeFindFile<CR>", { noremap = true })

