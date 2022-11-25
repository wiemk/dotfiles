local term = require "wezterm"
local mux = term.mux

local myfont = "JetBrainsMonoNL NFM"
local tabwidth = 16
local fontsize = 14.0

local sc = {
  foreground = "#c0caf5",
  background = "#24283b",
  cursor_bg = "#c0caf5",
  cursor_border = "#c0caf5",
  cursor_fg = "#24283b",
  selection_bg = "#364A82",
  selection_fg = "#c0caf5",

  ansi = { "#1D202F", "#f7768e", "#9ece6a", "#e0af68", "#7aa2f7", "#bb9af7", "#7dcfff", "#a9b1d6" },
  brights = { "#414868", "#f7768e", "#9ece6a", "#e0af68", "#7aa2f7", "#bb9af7", "#7dcfff", "#c0caf5" },
}

local fallback = function(name, params)
  -- $ wezterm ls-fonts --list-system
  -- font_dirs = { "/home/zeno/.local/share/fonts" },
  local names = { name, "CaskaydiaCove Nerd Font Mono", "FiraCode Nerd Font Mono", "monospace" }
  return term.font_with_fallback(names, params)
end

term.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
  local title = " " .. term.truncate_right(tab.active_pane.title, tabwidth) .. " "
  if tab.is_active then
    return {
      { Attribute = { Italic = true } },
      { Text = title },
    }
  end
  return {
    { Attribute = { Italic = false } },
    { Text = title },
  }
end)

term.on("gui-startup", function(cmd)
  local tab, pane, window = mux.spawn_window(cmd or {})
  window:gui_window():maximize()
end)

local options = {
  adjust_window_size_when_changing_font_size = false,
  animation_fps = 1,
  audible_bell = "SystemBeep",
  automatically_reload_config = true,
  check_for_updates = false,
  cursor_blink_ease_in = "Constant",
  cursor_blink_ease_out = "Constant",
  hide_tab_bar_if_only_one_tab = true,
  initial_cols = 180,
  initial_rows = 40,
  scrollback_lines = 10000,
  warn_about_missing_glyphs = false,
  window_close_confirmation = "NeverPrompt",
  window_decorations = "RESIZE",

  color_scheme = "Tokyonight Storm",
  color_schemes = {
    ["Tokyonight Storm"] = sc,
  },

  font = fallback(myfont),
  font_size = fontsize,
  font_rules = {
    {
      intensity = "Normal",
      italic = false,
      strikethrough = false,
      underline = "None",
      font = fallback(myfont, { weight = "Regular" }),
    },
  },

  window_frame = {
    font = fallback(myfont, { weight = "Regular" }),
    font_size = fontsize - 3.0,
    active_titlebar_bg = sc.background,
    active_titlebar_fg = sc.background,
    inactive_titlebar_bg = sc.background,
    inactive_titlebar_fg = sc.background,
  },

  colors = {
    tab_bar = {
      background = sc.background,
      active_tab = {
        bg_color = sc.background,
        fg_color = "#a9b1d6",
      },
      inactive_tab = {
        bg_color = "#2b2c37",
        fg_color = "#a9b1d6",
      },
      inactive_tab_hover = {
        bg_color = sc.background,
        fg_color = sc.foreground,
      },
    },
  },

  mouse_bindings = {
    -- Change the default click behavior so that it only selects
    -- text and doesn't open hyperlinks
    {
      event = { Up = { streak = 1, button = "Left" } },
      action = { CompleteSelection = "PrimarySelection" },
    },
    -- Bind 'Up' event of CTRL-Click to open hyperlinks
    {
      event = { Up = { streak = 1, button = "Left" } },
      mods = "CTRL",
      action = "OpenLinkAtMouseCursor",
    },
    -- Disable the 'Down' event of CTRL-Click to avoid weird program behaviors
    {
      event = { Down = { streak = 1, button = "Left" } },
      mods = "CTRL",
      action = "Nop",
    },
    -- Mimic alacritty text selection
    {
      event = { Down = { streak = 1, button = "Left" } },
      mods = "SHIFT",
      action = "Nop",
    },
    {
      event = { Up = { streak = 1, button = "Left" } },
      mods = "SHIFT",
      action = "Nop",
    },
    {
      event = { Down = { streak = 1, button = "Right" } },
      mods = "SHIFT",
      action = { ExtendSelectionToMouseCursor = "Cell" },
    },
    --
    {
      event = { Down = { streak = 1, button = "Left" } },
      mods = "SHIFT|ALT",
      action = "Nop",
    },
    {
      event = { Up = { streak = 1, button = "Right" } },
      mods = "SHIFT|ALT",
      action = "Nop",
    },
    {
      event = { Down = { streak = 1, button = "Right" } },
      mods = "ALT",
      action = { ExtendSelectionToMouseCursor = "Block" },
    },
    {
      event = { Up = { streak = 1, button = "Right" } },
      mods = "ALT",
      action = { CompleteSelection = "PrimarySelection" },
    },
    {
      event = { Down = { streak = 1, button = "Left" } },
      mods = "SHIFT",
      action = { SelectTextAtMouseCursor = "Cell" },
    },
    {
      event = { Drag = { streak = 1, button = "Left" } },
      mods = "SHIFT",
      action = { ExtendSelectionToMouseCursor = "Cell" },
    },
    {
      event = { Up = { streak = 1, button = "Left" } },
      mods = "SHIFT",
      action = { CompleteSelection = "PrimarySelection" },
    },
    {
      event = { Up = { streak = 1, button = "Middle" } },
      action = "Nop",
    },
    {
      event = { Down = { streak = 1, button = "Middle" } },
      mods = "SHIFT",
      action = { PasteFrom = "PrimarySelection" },
    },
    {
      event = { Down = { streak = 1, button = "Middle" } },
      action = { SelectTextAtMouseCursor = "Block" },
    },
    {
      event = { Drag = { streak = 1, button = "Middle" } },
      action = { ExtendSelectionToMouseCursor = "Block" },
    },
    {
      event = { Up = { streak = 1, button = "Middle" } },
      action = { CompleteSelection = "PrimarySelection" },
    },
  },

  keys = {
    -- Clipboard handling
    { key = "Insert", mods = "CTRL|SHIFT", action = "Paste" },
    { key = "Insert", mods = "SHIFT", action = "PastePrimarySelection" },
    -- Remove crap
    { key = "m", mods = "SUPER", action = "DisableDefaultAssignment" },
    { key = "n", mods = "SUPER", action = "DisableDefaultAssignment" },
    { key = "t", mods = "SUPER", action = "DisableDefaultAssignment" },
    { key = "w", mods = "SUPER", action = "DisableDefaultAssignment" },
    { key = "1", mods = "SUPER", action = "DisableDefaultAssignment" },
    { key = "2", mods = "SUPER", action = "DisableDefaultAssignment" },
    { key = "3", mods = "SUPER", action = "DisableDefaultAssignment" },
    { key = "4", mods = "SUPER", action = "DisableDefaultAssignment" },
    { key = "5", mods = "SUPER", action = "DisableDefaultAssignment" },
    { key = "6", mods = "SUPER", action = "DisableDefaultAssignment" },
    { key = "7", mods = "SUPER", action = "DisableDefaultAssignment" },
    { key = "8", mods = "SUPER", action = "DisableDefaultAssignment" },
    { key = "9", mods = "SUPER", action = "DisableDefaultAssignment" },
    { key = "r", mods = "SUPER", action = "DisableDefaultAssignment" },
    { key = "h", mods = "SUPER", action = "DisableDefaultAssignment" },
    { key = "k", mods = "SUPER", action = "DisableDefaultAssignment" },
    { key = "f", mods = "SUPER", action = "DisableDefaultAssignment" },
    { key = "t", mods = "SUPER|SHIFT", action = "DisableDefaultAssignment" },

    { key = "/", mods = "CTRL|SHIFT", action = { Search = "CurrentSelectionOrEmptyString" } },
  },

  key_tables = {
    search_mode = {
      { key = "n", mods = "CTRL|SHIFT", action = { CopyMode = "PriorMatch" } },
    },
  },
}

if term.target_triple == "x86_64-pc-windows-msvc" then
  options.default_prog = { "wsl.exe", "--cd", "~" }
end

return options
