--[[
lvim = global options object
]]

-- General
lvim.log.level = "warn"
lvim.format_on_save = false
lvim.colorscheme = "tokyonight"
lvim.use_icons = true

-- Override default options
local opts = {
  cmdheight = 1,
  colorcolumn = "100",
  -- adapt German keyboard layout
  langmap = "zy,yz,ZY,YZ,ö},ä{",
  list = false,
  listchars = "tab:→ ,eol:↲,nbsp:␣,trail:•,lead:_,extends:⟩,precedes:⟨",
  relativenumber = true,
  showbreak = "↪ ",
  spelllang = "en",
  timeoutlen = 250,
}

(function(o)
  for k, v in pairs(o) do
    vim.opt[k] = v
  end
end)(opts);

-- Keymappings [view all the defaults by pressing <leader>Lk]
lvim.leader = "space"

-- tmux bugfix (nvim 0.7 api)
vim.keymap.set({ 'i', 'n', 'v' }, '<C-a>', '<Home>', { noremap = true, silent = true })
vim.keymap.set({ 'i', 'n', 'v' }, '<C-e>', '<End>', { noremap = true, silent = true })

-- Use the default vim behavior for H and L
lvim.keys.normal_mode["<S-l>"] = false
lvim.keys.normal_mode["<S-h>"] = false

-- Remove some default mappings
lvim.keys.normal_mode["<F1>"] = "<Esc>"
lvim.keys.insert_mode["<F1>"] = "<Esc>"

-- Remove highlighting
lvim.keys.normal_mode["<C-h>"] = ":nohlsearch<CR>"

-- In-file navigation
lvim.keys.normal_mode["<C-k>"] = "{"
lvim.keys.normal_mode["<C-j>"] = "}"

-- Arrow keys
lvim.keys.normal_mode["<Up>"] = "<nop>"
lvim.keys.normal_mode["<Down>"] = "<nop>"
lvim.keys.normal_mode["<Left>"] = "<nop>"
lvim.keys.normal_mode["<Right>"] = "<nop>"

-- Arrow key line swapping
lvim.keys.normal_mode["<M-Up>"] = ":m .-2<CR>=="
lvim.keys.normal_mode["<M-Down>"] = ":m .+1<CR>=="
lvim.keys.visual_block_mode["<M-Up>"] = ":m '<-2<CR>gv-gv"
lvim.keys.visual_block_mode["<M-Down>"] = ":m '>+1<CR>gv-gv"

-- Buffer/Tab navigation
lvim.keys.normal_mode["<M-,>"] = ":BufferLineCyclePrev<CR>"
lvim.keys.normal_mode["<M-.>"] = ":BufferLineCycleNext<CR>"

-- which-key
lvim.builtin.which_key.setup.triggers_blacklist = { n = { "g" } }
lvim.builtin.which_key.mappings["<leader>"] = { "<C-^>", "Cycle Buffer" }
lvim.builtin.which_key.mappings["h"] = {
  function() vim.opt.hlsearch = not vim.o.hlsearch end, "Toggle Highlight"
}
lvim.builtin.which_key.mappings["lo"] = { "<Cmd>SymbolsOutline<CR>", "Outline" }
if lvim.builtin.project.active then
  lvim.builtin.which_key.mappings["P"] = { "<Cmd>Telescope projects<CR>", "Projects" }
end
lvim.builtin.which_key.mappings["S"] = {
  function() vim.opt.spell = not vim.o.spell end, "Spellcheck"
}
lvim.builtin.which_key.mappings["W"] = {
  function() vim.opt.list = not vim.o.list end, "Whitespaces"
}

local ok, ts = pcall(require, "telescope.builtin")
if ok then
  lvim.builtin.which_key.mappings["/"] = nil
  lvim.builtin.which_key.mappings["sB"] = { ts.builtin, "Builtins" }
  lvim.builtin.which_key.mappings["B"] = lvim.builtin.which_key.mappings["b"]
  lvim.builtin.which_key.mappings["b"] = { ts.buffers, "Buffers" }
  local gitfiles = { pcall(ts.git_files), "Git Files" }
  lvim.builtin.which_key.mappings["gf"] = gitfiles
  lvim.builtin.which_key.mappings["sg"] = gitfiles
end

-- Remap umlauts mode
lvim.builtin.which_key.mappings["U"] = {
  function()
    local opt = { noremap = true, silent = true }
    vim.keymap.set({ 'i' }, 'ö', '{', opt)
    vim.keymap.set({ 'i' }, 'ä', '}', opt)
    vim.keymap.set({ 'i' }, 'Ö', '[', opt)
    vim.keymap.set({ 'i' }, 'Ä', ']', opt)
    vim.keymap.set({ 'i' }, 'ü', '(', opt)
    vim.keymap.set({ 'i' }, 'Ü', ')', opt)
  end, "Umlaut Remap"
}

-- telescope
-- set ivy as default for all pickers
lvim.builtin.telescope.defaults = vim.tbl_extend("force", lvim.builtin.telescope.defaults or {},
  require "telescope.themes".get_ivy({ prompt_prefix = ">> " }))
-- close buffers with hotkey inside telescope
lvim.builtin.telescope.pickers = vim.tbl_extend("force", lvim.builtin.telescope.pickers or {}, {
  buffers = {
    sort_lastused = true,
    mappings = {
      i = {
        ["<C-d>"] = require("telescope.actions").delete_buffer,
      },
      n = {
        ["<C-d>"] = require("telescope.actions").delete_buffer,
      }
    }
  }
})

-- alpha
lvim.builtin.alpha.active = true
lvim.builtin.alpha.mode = "startify"

-- notify
lvim.builtin.notify.active = true

-- toggleterm
lvim.builtin.terminal.active = true

-- nvimtree
lvim.builtin.nvimtree.active = true
lvim.builtin.nvimtree.setup.view.side = "left"
lvim.builtin.nvimtree.show_icons.git = 0

-- project
lvim.builtin.project.show_hidden = true
lvim.builtin.project.silent_chdir = false

-- lualine
local components = require("lvim.core.lualine.components")

lvim.builtin.lualine.sections.lualine_a = { "mode" }
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
local null_ls = require "null-ls"
lvim.lsp.null_ls.setup.sources = {
  -- null_ls.builtins.diagnostics.shellcheck.with { filetype = "sh", diagnostics_format = "#{m} [#{c}]" },
  -- null_ls.builtins.formatting.sh mt.with({
  --   extra_args = function(params)
  --     return { "-i", vim.api.nvim_buf_get_option(params.bufnr, "shiftwidth") }
  --   end,
  -- })
  null_ls.builtins.diagnostics.shellcheck,
  null_ls.builtins.code_actions.shellcheck,
  null_ls.builtins.formatting.shfmt
}

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
        t = { "<cmd>TroubleToggle<CR>", "trouble" },
        w = { "<cmd>TroubleToggle lsp_workspace_diagnostics<CR>", "workspace" },
        d = { "<cmd>TroubleToggle lsp_document_diagnostics<CR>", "document" },
        q = { "<cmd>TroubleToggle quickfix<CR>", "quickfix" },
        l = { "<cmd>TroubleToggle loclist<CR>", "loclist" },
        r = { "<cmd>TroubleToggle lsp_references<CR>", "references" },
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
  -- scrollbar
  {
    "petertriho/nvim-scrollbar",
    setup = require "scrollbar".setup()
  },
  -- outline
  {
    "simrat39/symbols-outline.nvim",
    cmd = "SymbolsOutline",
  },
}

-- when running in neovide gui
if vim.g.neovide == true then
  vim.o.guifont = "FiraCode Nerd Font Mono Retina:h14"
  vim.g.neovide_cursor_vfx_mode = "sonicboom"
  vim.g.neovide_refresh_rate = 120
end
