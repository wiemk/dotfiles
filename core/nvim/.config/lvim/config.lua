--[[
lvim = global options object
]]

-- General
lvim.log.level = "warn"
lvim.format_on_save = true
lvim.colorscheme = "tokyonight"

-- Override default options
local opts = {
  cmdheight = 1,
  colorcolumn = "100",
  -- adapt German keyboard layout
  langmap = "zy,yz,ZY,YZ,[ö,]ä",
  list = true,
  listchars = "tab:→ ,eol:↲,nbsp:␣,trail:•,lead:_,extends:⟩,precedes:⟨",
  relativenumber = true,
  showbreak = "↪ ",
  spelllang = "en",
  timeoutlen = 50,
}

-- Keymappings [view all the defaults by pressing <leader>Lk]
lvim.leader = "space"

-- tmux bugfix (nvim 0.7 api)
vim.keymap.set({ 'n', 'v' }, '<C-a>', '<Home>', { noremap = true, silent = true })
vim.keymap.set({ 'n', 'v' }, '<C-e>', '<End>', { noremap = true, silent = true })

-- Remove some annoying default mappings
lvim.keys.normal_mode["<F1>"] = "<Esc>"
lvim.keys.insert_mode["<F1>"] = "<Esc>"

-- Annoy people
lvim.keys.normal_mode["<Up>"] = "<nop>"
lvim.keys.normal_mode["<Down>"] = "<nop>"
lvim.keys.normal_mode["<Left>"] = "<nop>"
lvim.keys.normal_mode["<Right>"] = "<nop>"

-- Arrow key line swapping
lvim.keys.normal_mode["<M-Up>"] = ":m .-2<cr>=="
lvim.keys.normal_mode["<M-Down>"] = ":m .+1<cr>=="
lvim.keys.visual_block_mode["<M-Up>"] = ":m '<-2<cr>gv-gv"
lvim.keys.visual_block_mode["<M-Down>"] = ":m '>+1<cr>gv-gv"

-- Save
lvim.keys.normal_mode["<C-s>"] = ":w<cr>"
lvim.keys.normal_mode["<C-x>"] = ":BufferKill<cr>"

-- Buffer/Tab navigation
lvim.keys.normal_mode["<M-,>"] = ":BufferLineCyclePrev<cr>"
lvim.keys.normal_mode["<M-.>"] = ":BufferLineCycleNext<cr>"

-- which-key bindings
lvim.builtin.which_key.mappings["<leader>"] = { "<C-^>", "Previous Buffer" }

lvim.builtin.which_key.mappings["S"] = {
  function() vim.opt.spell = not vim.o.spell end, "Spellcheck"
}
lvim.builtin.which_key.mappings["W"] = {
  function() vim.opt.list = not vim.o.list end, "Whitespaces"
}

-- which-key telescope
local ok, _ = pcall(require, "telescope.builtin")
if ok then
  lvim.builtin.which_key.mappings["/"] = nil
  lvim.builtin.which_key.mappings["G"] = lvim.builtin.which_key.mappings["g"]
  do
    local git_files = { function() pcall(require('telescope.builtin').git_files) end, "Git Files" }
    lvim.builtin.which_key.mappings["g"] = git_files
    lvim.builtin.which_key.mappings["sg"] = git_files
  end
  lvim.builtin.which_key.mappings["sB"] = {
    function() require('telescope.builtin').builtin() end,
    "Builtins",
  }
  lvim.builtin.which_key.mappings["B"] = {
    function() require('telescope.builtin').buffers() end,
    "Buffers",
  }
  lvim.builtin.which_key.mappings["P"] = {
    function() require('telescope.builtin').live_grep() end,
    "Live Grep",
  }
  lvim.builtin.which_key.mappings["/"] = {
    function() require('telescope.builtin').grep_string() end,
    "String Grep",
  }
end

-- alpha
lvim.builtin.alpha.active = true
lvim.builtin.alpha.mode = "dashboard"
-- notify
lvim.builtin.notify.active = true
-- toggleterm
lvim.builtin.terminal.active = true
-- nvimtree
lvim.builtin.nvimtree.setup.view.side = "left"
lvim.builtin.nvimtree.show_icons.git = 0
-- project
lvim.builtin.project.show_hidden = true
lvim.builtin.project.silent_chdir = false
-- lualine
local components = require("lvim.core.lualine.components")
-- lvim.builtin.lualine.sections.lualine_a = { "mode" }
lvim.builtin.lualine.sections.lualine_y = {
  components.spaces,
  components.location
}
-- tree-sitter
lvim.builtin.treesitter.ensure_installed = {
  "bash",
  "c",
  "cmake",
  "comment",
  "cpp",
  "css",
  "dockerfile",
  "go",
  "help",
  "java",
  "javascript",
  "json",
  "lua",
  "make",
  "markdown",
  "python",
  "regex",
  "rust",
  "toml",
  "typescript",
  "vim",
  "yaml",
  "zig",
}
lvim.builtin.treesitter.ignore_install = { "haskell" }
lvim.builtin.treesitter.highlight.enabled = true

-- Generic LSP settings
lvim.lsp.automatic_servers_installation = false

-- Custom linters
local linters = require "lvim.lsp.null-ls.linters"
linters.setup {
  {
    command = "shellcheck",
    args = { "--shell", "bash", "--external-sources" },
    filetypes = { "sh", "bash" },
  },
}

-- when running in neovide gui
if vim.g.neovide == true then
  vim.o.guifont = "FiraCode Nerd Font Mono Retina:h14"
  vim.g.neovide_cursor_vfx_mode = "sonicboom"
  vim.g.neovide_refresh_rate = 120
end

-- Additional Plugins
lvim.plugins = {
  -- Theme
  { "folke/tokyonight.nvim" },
  -- diagnostics, references, telescope results, quickfix and location lists
  {
    "folke/trouble.nvim",
    cmd = "TroubleToggle",
    setup = function()
      lvim.builtin.which_key.mappings["t"] = {
        name = "Diagnostics",
        t = { "<cmd>TroubleToggle<cr>", "trouble" },
        w = { "<cmd>TroubleToggle lsp_workspace_diagnostics<cr>", "workspace" },
        d = { "<cmd>TroubleToggle lsp_document_diagnostics<cr>", "document" },
        q = { "<cmd>TroubleToggle quickfix<cr>", "quickfix" },
        l = { "<cmd>TroubleToggle loclist<cr>", "loclist" },
        r = { "<cmd>TroubleToggle lsp_references<cr>", "references" },
      }
    end,
    config = function()
      require "trouble".setup {
        mode = "document_diagnostics",
      }
    end
  },
  -- indentation guides for every line
  {
    "lukas-reineke/indent-blankline.nvim",
    event = "BufRead",
    setup = function()
      vim.g.indentLine_enabled = 1
      vim.g.indent_blankline_char = "▏"
      vim.g.indent_blankline_filetype_exclude = { "help", "terminal", "dashboard" }
      vim.g.indent_blankline_buftype_exclude = { "terminal" }
      vim.g.indent_blankline_show_trailing_blankline_indent = false
      vim.g.indent_blankline_show_first_indent_level = false
    end
  },
  -- rainbow parentheses
  {
    "p00f/nvim-ts-rainbow",
  },
  -- git wrapper
  {
    "tpope/vim-fugitive",
    cmd = {
      "G",
      "Git",
      "Gdiffsplit",
      "Gread",
      "Gwrite",
      "Ggrep",
      "GMove",
      "GDelete",
      "GBrowse",
      "GRemove",
      "GRename",
      "Glgrep",
      "Gedit"
    },
    ft = { "fugitive" }
  },

}

-- helper functions
(function()
  for k, v in pairs(opts) do
    vim.opt[k] = v
  end
end)();
