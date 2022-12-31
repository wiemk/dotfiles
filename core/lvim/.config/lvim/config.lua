-- vi: set ft=lua ts=2 sw=2 sts=-1 nosr et nosi tw=0 fdm=manual:
--[[
lvim = global options object
]]

-- General
lvim.log.level = "error"
lvim.format_on_save = false
lvim.builtin.theme.tokyonight.options.style = "moon"
lvim.colorscheme = "tokyonight-moon"
lvim.use_icons = true

-- Don't redraw during macro execution
vim.opt.lazyredraw = true
vim.opt.synmaxcol = 256

-- Use ANSI OSC 52 support when running inside tmux
if os.getenv "TMUX" then
  vim.g.clipboard = {
    cache_enabled = 1,
    copy = {
      ["*"] = { "tmux", "load-buffer", "-w", "-" },
      ["+"] = { "tmux", "load-buffer", "-w", "-" },
    },
    name = "myClipboard",
    paste = {
      ["*"] = { "tmux", "save-buffer", "-" },
      ["+"] = { "tmux", "save-buffer", "-" },
    },
  }
end

-- Override default options
(function()
  local opts = {
    colorcolumn = "100",
    list = true,
    listchars = "tab:→ ,eol:↲,nbsp:␣,trail:•,extends:⟩,precedes:⟨",
    relativenumber = true,
    showbreak = "↪ ",
    spelllang = "en",
    timeoutlen = 250,
    updatetime = 100,
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

-- tmux bugfix
vim.keymap.set({ "i", "n", "v" }, "<C-a>", "<Home>", { noremap = true, silent = true })
vim.keymap.set({ "i", "n", "v" }, "<C-e>", "<End>", { noremap = true, silent = true })

-- Don't yank on backspace or x
lvim.keys.normal_mode["<Del>"] = '"_x'
lvim.keys.normal_mode["x"] = '"_x'

-- Don't move the cursor on *
lvim.keys.normal_mode["*"] = "*<C-o>"

lvim.keys.normal_mode["<F1>"] = ":make<CR>"
lvim.keys.insert_mode["<F1>"] = ":make<CR>"

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
-- lvim.keys.term_mode["<Esc>"] = "<C-\\><C-n>"
lvim.keys.term_mode["<C-h>"] = false
lvim.keys.term_mode["<C-j>"] = false
lvim.keys.term_mode["<C-k>"] = false
lvim.keys.term_mode["<C-l>"] = false

-- which-key
lvim.builtin.which_key.mappings["w"] = nil
lvim.builtin.which_key.mappings["<leader>"] = { "<C-^>", "Cycle Buffer" }
lvim.builtin.which_key.mappings["h"] = {
  function()
    vim.opt.hlsearch = not vim.o.hlsearch
  end,
  "Toggle Highlight",
}
lvim.builtin.which_key.mappings["P"] = lvim.builtin.which_key.mappings["p"]
if lvim.builtin.project.active then
  lvim.builtin.which_key.mappings["p"] = { "<Cmd>Telescope projects theme=ivy<CR>", "Projects" }
end

local ok, builtin = pcall(require, "telescope.builtin")
if ok then
  lvim.builtin.which_key.mappings["/"] = {
    function()
      builtin.current_buffer_fuzzy_find { layout_config = { width = 0.5 } }
    end,
    "Buffer Fuzzy",
  }
  lvim.builtin.which_key.mappings["sB"] = { builtin.builtin, "Builtins" }
  lvim.builtin.which_key.mappings["F"] = { builtin.live_grep, "Text" }
  lvim.builtin.which_key.mappings["B"] = lvim.builtin.which_key.mappings["b"]
  -- Close all but current buffer
  lvim.builtin.which_key.mappings["Bo"] = { ':%bd!|e #|bd #|normal`"<CR>', "Close inactive buffers" }
  lvim.builtin.which_key.mappings["b"] = { builtin.buffers, "Buffers" }
end
lvim.builtin.which_key.mappings["sF"] = { "<Cmd>Telescope frecency<CR>", "Frecency" }
lvim.builtin.which_key.mappings["R"] = { "<Cmd>Telescope frecency<CR>", "Frecency" }
lvim.builtin.which_key.mappings["C"] = { "<Cmd>ProjectRoot<CR>", "Project Root" }
lvim.builtin.which_key.mappings["u"] = {
  name = "Utilities",
  c = { "<Cmd>lcd %:p:h|lua print('Window working directory changed to ' .. vim.fn.getcwd())<CR>", "lcd %:p:h" },
  S = {
    [[
      :%s/\(.\+\)\n/\1@/
      :sort
      :%s/@/\r/g<CR>
    ]],
    "Sort Paragraphs",
  },
  s = {
    function()
      vim.opt.spell = not vim.o.spell
    end,
    "Spellcheck",
  },
  w = {
    function()
      vim.opt.list = not vim.o.list
    end,
    "Show whitespaces",
  },
}

-- telescope
-- change default navigation mappings
local actions = require "telescope.actions"
lvim.builtin.telescope.defaults.mappings = vim.tbl_deep_extend("force", lvim.builtin.telescope.defaults.mappings, {
  i = {
    ["<C-k>"] = actions.move_selection_previous,
    ["<C-j>"] = actions.move_selection_next,
    ["<C-p>"] = actions.cycle_history_prev,
    ["<C-n>"] = actions.cycle_history_next,
  },
})
-- close buffers with hotkey inside telescope
lvim.builtin.telescope.theme = "ivy"
lvim.builtin.telescope.pickers = vim.tbl_deep_extend("force", lvim.builtin.telescope.pickers or {}, {
  buffers = {
    sort_lastused = true,
    mappings = {
      i = {
        ["<C-d>"] = require("telescope.actions").delete_buffer,
      },
      n = {
        ["<C-d>"] = require("telescope.actions").delete_buffer,
      },
    },
    theme = "ivy",
  },
  builtin = {
    previewer = false,
  },
})
-- extensions
lvim.builtin.telescope.extensions = vim.tbl_deep_extend("force", lvim.builtin.telescope.extensions or {}, {
  frecency = {
    db_root = get_cache_dir(),
  },
})

-- autopairs
lvim.builtin.autopairs.active = false

-- alpha
lvim.builtin.alpha.active = false
lvim.builtin.alpha.mode = "startify"

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
lvim.builtin.lualine.sections.lualine_a = { "mode" }

-- tree-sitter
lvim.builtin.treesitter.auto_install = false
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
  "nix",
  "python",
  "regex",
  "rust",
  "toml",
  "typescript",
  "v",
  "vim",
  "yaml",
  "zig",
}
lvim.builtin.treesitter.highlight.enabled = true
lvim.builtin.treesitter.matchup.enable = true

-- Generic LSP settings
lvim.lsp.installer.setup.automatic_installation = false
vim.list_extend(lvim.lsp.automatic_configuration.skipped_servers, { "rust_analyzer", "bashls" })

-- Custom linters
if vim.fn.executable "shellcheck" == 1 then
  local null_ls = require "null-ls"
  lvim.lsp.null_ls.setup.sources = {
    null_ls.builtins.diagnostics.shellcheck,
    null_ls.builtins.code_actions.shellcheck,
    null_ls.builtins.formatting.shfmt,
  }
end
-- Additional Plugins
lvim.plugins = {
  { "p00f/nvim-ts-rainbow" },
  { "machakann/vim-sandwich" },
  { "gpanders/editorconfig.nvim" },
  {
    url = "https://betaco.de/strom/modeline.nvim",
    cmd = "InsertModeline",
    init = function()
      lvim.builtin.which_key.mappings["M"] = {
        function()
          require("modeline").insertModeline()
        end,
        "Insert Modeline",
      }
      lvim.builtin.which_key.mappings["uM"] = lvim.builtin.which_key.mappings["M"]
    end,
  },
  {
    "mbbill/undotree",
    cmd = "UndotreeToggle",
    init = function()
      lvim.builtin.which_key.mappings["uU"] = { "<cmd>UndotreeToggle<CR>", "UndoTree" }
    end,
  },
  {
    "nvim-telescope/telescope-frecency.nvim",
    config = function()
      require("telescope").load_extension "frecency"
    end,
    dependencies = { "tami5/sqlite.lua" },
  },
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
      "Gedit",
    },
    ft = { "fugitive" },
  },
  {
    "andymass/vim-matchup",
    event = "CursorMoved",
    config = function()
      vim.g.matchup_matchparen_offscreen = { method = "popup" }
    end,
  },
}
