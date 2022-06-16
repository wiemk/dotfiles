--[[
lvim = global options object
]]

-- General
lvim.log.level = "warn"
lvim.format_on_save = false
lvim.colorscheme = "tokyonight"
lvim.use_icons = true

-- Override default options
(function()
  local opts = {
    cmdheight = 1,
    colorcolumn = "100",
    list = true,
    listchars = "tab:→ ,eol:↲,nbsp:␣,trail:•,extends:⟩,precedes:⟨",
    relativenumber = true,
    showbreak = "↪ ",
    spelllang = "en",
    timeoutlen = 250,
  }

  for k, v in pairs(opts) do
    vim.opt[k] = v
  end
end)()

-- Highlight trailing whitespaces
vim.fn.matchadd("ErrorMsg", [[\s\+$]])

-- Keymappings [view all the defaults by pressing <leader>Lk]
lvim.leader = "space"

-- Arrow keys
lvim.keys.normal_mode["<Up>"] = "<NOP>"
lvim.keys.normal_mode["<Down>"] = "<NOP>"
lvim.keys.normal_mode["<Left>"] = "<NOP>"
lvim.keys.normal_mode["<Right>"] = "<NOP>"

-- tmux bugfix (nvim 0.7 api)
vim.keymap.set({ 'i', 'n', 'v' }, '<C-a>', '<Home>', { noremap = true, silent = true })
vim.keymap.set({ 'i', 'n', 'v' }, '<C-e>', '<End>', { noremap = true, silent = true })

-- Use the default vim behavior for H and L
lvim.keys.normal_mode["<S-l>"] = false
lvim.keys.normal_mode["<S-h>"] = false
-- vim.keymap.del("n", "<S-l>")
-- vim.keymap.del("n", "<S-h:")

-- Don't yank on backspace or x
lvim.keys.normal_mode["<Del>"] = '"_x'
lvim.keys.normal_mode["x"] = '"_x'

-- Don't move the cursor on *
lvim.keys.normal_mode["*"] = "*<C-o>"

-- Remove some default mappings
lvim.keys.normal_mode["<F1>"] = "<Esc>"
lvim.keys.insert_mode["<F1>"] = "<Esc>"

-- Remove highlighting
lvim.keys.normal_mode["<C-h>"] = ":nohlsearch<CR>"

-- In-file navigation
lvim.keys.normal_mode["<C-k>"] = "{"
lvim.keys.normal_mode["<C-j>"] = "}"

-- Map useless tabulator
lvim.keys.normal_mode["<Tab>"] = "%"

-- Arrow key line swapping
lvim.keys.normal_mode["<M-Up>"] = ":m .-2<CR>=="
lvim.keys.normal_mode["<M-Down>"] = ":m .+1<CR>=="
lvim.keys.visual_block_mode["<M-Up>"] = ":m '<-2<CR>gv-gv"
lvim.keys.visual_block_mode["<M-Down>"] = ":m '>+1<CR>gv-gv"

-- Buffer/Tab navigation
lvim.keys.normal_mode["<C-x>"] = ":BufferKill<CR>"
lvim.keys.normal_mode["<M-,>"] = ":BufferLineCyclePrev<CR>"
lvim.keys.normal_mode["<M-.>"] = ":BufferLineCycleNext<CR>"

-- Terminal Mappings
lvim.keys.term_mode["<Esc>"] = "<C-\\><C-n>"
lvim.keys.term_mode["<C-h>"] = false
lvim.keys.term_mode["<C-j>"] = false
lvim.keys.term_mode["<C-k>"] = false
lvim.keys.term_mode["<C-l>"] = false

-- which-key
-- lvim.builtin.which_key.setup.triggers_blacklist = { n = { "g" } }
lvim.builtin.which_key.mappings["<leader>"] = { "<C-^>", "Cycle Buffer" }
lvim.builtin.which_key.mappings["h"] = {
  function() vim.opt.hlsearch = not vim.o.hlsearch end, "Toggle Highlight"
}
lvim.builtin.which_key.mappings["lo"] = { "<Cmd>SymbolsOutline<CR>", "Outline" }
lvim.builtin.which_key.mappings["P"] = lvim.builtin.which_key.mappings["p"]
if lvim.builtin.project.active then
  lvim.builtin.which_key.mappings["p"] = { "<Cmd>Telescope projects<CR>", "Projects" }
end

local ok, builtin = pcall(require, "telescope.builtin")
if ok then
  lvim.builtin.which_key.mappings["/"] = nil
  lvim.builtin.which_key.mappings["sB"] = { builtin.builtin, "Builtins" }
  lvim.builtin.which_key.mappings["B"] = lvim.builtin.which_key.mappings["b"]
  lvim.builtin.which_key.mappings["b"] = { builtin.buffers, "Buffers" }
end

lvim.builtin.which_key.mappings["F"] = { "<Cmd>Telescope frecency<CR>", "Frecency" }
lvim.builtin.which_key.mappings["C"] = { "<Cmd>ProjectRoot<CR>", "Project Root" }
lvim.builtin.which_key.mappings["u"] = {
  name = "Utilities",
  S = {
    [[
      :%s/\(.\+\)\n/\1@/
      :sort
      :%s/@/\r/g<CR>
    ]],
    "Sort Paragraphs"
  },
  s = { function() vim.opt.spell = not vim.o.spell end, "Spellcheck" },
  w = { function() vim.opt.list = not vim.o.list end, "Whitespaces" },
  t = { "<Cmd>Twilight<CR>", "Twilight Mode" },
}
lvim.builtin.which_key.mappings["Z"] = { "<cmd>ZenMode<CR>", "Zen Mode" }

-- telescope
-- change default navigation mappings
local actions = require("telescope.actions")
lvim.builtin.telescope.defaults.mappings = vim.tbl_deep_extend("force",
  lvim.builtin.telescope.defaults.mappings, {
  i = {
    ["<C-k>"] = actions.move_selection_previous,
    ["<C-j>"] = actions.move_selection_next,
    ["<C-p>"] = actions.cycle_history_prev,
    ["<C-n>"] = actions.cycle_history_next,
  }
})
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
-- extensions
lvim.builtin.telescope.extensions = vim.tbl_deep_extend("force",
  lvim.builtin.telescope.extensions or {}, {
  frecency = { db_root = get_cache_dir() }
})

-- alpha
lvim.builtin.alpha.active = true
lvim.builtin.alpha.mode = "startify"

-- notify
lvim.builtin.notify.active = true

-- toggleterm
lvim.builtin.terminal.active = true
lvim.builtin.terminal.shading_factor = 1

-- nvimtree
lvim.builtin.nvimtree.active = true
lvim.builtin.nvimtree.setup.view.side = "left"

-- project
lvim.builtin.project.show_hidden = true
lvim.builtin.project.silent_chdir = false
-- do change project root automagically, require :ProjectRoot
lvim.builtin.project.manual_mode = false

-- DAP
lvim.builtin.dap.active = false

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
lvim.builtin.treesitter.highlight.enabled = true
lvim.builtin.treesitter.matchup.enable = true

-- Generic LSP settings
lvim.lsp.automatic_servers_installation = false
vim.list_extend(lvim.lsp.automatic_configuration.skipped_servers, { "rust_analyzer" })

-- Custom linters
if vim.fn.executable("shellcheck") == 1 then
  local null_ls = require "null-ls"
  lvim.lsp.null_ls.setup.sources = {
    null_ls.builtins.diagnostics.shellcheck,
    null_ls.builtins.code_actions.shellcheck,
    null_ls.builtins.formatting.shfmt
  }
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
      vim.g.indent_blankline_filetype_exclude = { "help", "terminal", "dashboard", "alpha" }
      vim.g.indent_blankline_buftype_exclude = { "terminal", "nofile" }
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
  -- outline
  {
    "simrat39/symbols-outline.nvim",
    cmd = "SymbolsOutline",
  },
  -- matchup
  {
    "andymass/vim-matchup",
    event = "CursorMoved",
    config = function()
      vim.g.matchup_matchparen_offscreen = { method = "popup" }
    end,
  },
  -- telescope-frecency
  {
    "nvim-telescope/telescope-frecency.nvim",
    config = function()
      require "telescope".load_extension("frecency")
    end,
    requires = { "tami5/sqlite.lua" }
  },
  {
    "simrat39/rust-tools.nvim",
    config = function()
      local lsp_installer_servers = require "nvim-lsp-installer.servers"
      local _, requested_server = lsp_installer_servers.get_server "rust_analyzer"
      require("rust-tools").setup({
        tools = {
          autoSetHints = true,
          hover_with_actions = true,
          runnables = {
            use_telescope = true,
          },
        },
        server = {
          cmd_env = requested_server._default_options.cmd_env,
          on_attach = require("lvim.lsp").common_on_attach,
          on_init = require("lvim.lsp").common_on_init,
        },
      })
    end,
    ft = { "rust", "rs" },
  },
  -- lazy loaded
  {
    "folke/zen-mode.nvim",
    event = "BufRead",
    cmd = "ZenMode",
    config = function()
      require("zen-mode").setup({
        window = {
          backdrop = 1,
          height = 0.85,
          options = {
            signcolumn = "no",
            number = false,
            relativenumber = false,
            -- cursorline = false,
            -- cursorcolumn = false,
            -- foldcolumn = "0",
            -- list = false,
          },
        },
        plugins = {
          gitsigns = { enabled = false },
        },
      })
    end,
  },
  {
    "folke/twilight.nvim",
    event = "BufRead",
    config = function()
      require("twilight").setup({
        dimming = {
          alpha = 0.25,
          color = { "Normal", "#ffffff" },
        },
        context = 20,
        expand = {
          "function",
          "method",
          "table",
          "if_statement",
        },
        exclude = {},
      })
    end,
  },
  -- spectre
  {
    "windwp/nvim-spectre",
    event = "BufRead",
    config = function()
      require "spectre".setup()
    end,
    setup = function()
      lvim.builtin.which_key.mappings["S"] = {
        name = "Spectre",
        t = { "<cmd>lua require('spectre').open()<CR>", "Spectre" },
        w = { "<cmd>lua require('spectre').open_visual({select_word=true})<CR>", "Word" },
        v = { "<cmd>lua require('spectre').open_visual()<CR>", "Visual" },
        f = { "<cmd>sp viw:lua require('spectre').open_file_search()<CR>", "Current File" },
      }
    end,
  },
}
