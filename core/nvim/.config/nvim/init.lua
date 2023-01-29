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

-- Disable welcome text
vim.opt.shortmess:append { I = true, c = true }
vim.opt.completeopt = { "menuone", "noselect" }

-- Set highlight on search
vim.opt.hlsearch = true
vim.opt.incsearch = true

-- Keep cursor away from screen edge
vim.opt.scrolloff = 5

-- Make line numbers default
vim.opt.number = true
vim.opt.relativenumber = true

--Enable mouse mode
vim.opt.mouse = "a"

-- Use primary clipboard
vim.opt.clipboard = "unnamed"

-- no residual files
vim.opt.undofile = false
vim.opt.backup = false

-- Case insensitive searching UNLESS /C or capital in search
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Tune redraw performance
vim.opt.lazyredraw = true
vim.opt.synmaxcol = 256
vim.opt.wrap = false

-- Window settings
vim.opt.sidescroll = 10
vim.opt.colorcolumn = "80"

--Indentation
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = false
vim.opt.softtabstop = -1
vim.opt.textwidth = 0
vim.opt.copyindent = true

-- Colors
vim.opt.cursorline = false
vim.opt.termguicolors = true
vim.cmd [[ colorscheme slate ]]

vim.api.nvim_set_keymap("n", "<C-q>", ":qa!<CR>", { noremap = true })
