-- ── NvCGGX — CGGX theme for NvChad/base46 ──────────
-- Place at: ~/.config/nvim/lua/themes/nvcggx.lua
-- Palette: kinetic cyberpunk (bg0 #0a0a0c, red #ff2d55,
-- cyan #00e5ff, lime #C8FF00, orange #ff6b00,
-- purple #b48cff, silver #e8e8f0, muted #6a6a80)
--
-- Syntax: aggressive cyberpunk —
--   keywords=red bold, functions=cyan, strings=lime,
--   numbers=orange, tags=red, attributes=cyan,
--   operators=red, builtin-vars=orange,
--   types=purple bold, comments=muted italic
-- UI: flat minimal (like Waybar) — no rounded corners,
--   active=red bg, selection=red bg, borders=muted

local M = {}

-- ── 30-color slot system ───────────────────────────
M.base_30 = {
  white = "#e8e8f0",
  darker_black = "#0a0a0c",
  black = "#151518", -- nvim bg
  black2 = "#0f0f14",
  one_bg = "#151518",
  one_bg2 = "#3a3a48",
  one_bg3 = "#242430",
  grey = "#2a2a35",
  grey_fg = "#4a4a5a",
  grey_fg2 = "#6a6a80",
  light_grey = "#6a6a80",
  red = "#ff2d55",
  baby_pink = "#ff5c7a",
  pink = "#ff2d55",
  line = "#2a2a35", -- vertical splits
  green = "#C8FF00",
  vibrant_green = "#C8FF00",
  blue = "#00e5ff",
  nord_blue = "#00e5ff",
  yellow = "#ff6b00",
  sun = "#ff6b00",
  purple = "#b48cff",
  dark_purple = "#9a6aff",
  teal = "#00e5ff",
  orange = "#ff6b00",
  cyan = "#00e5ff",
  statusline_bg = "#151518",
  lightbg = "#1a1a20",
  pmenu_bg = "#ff2d55",
  folder_bg = "#00e5ff",
}

-- ── 16-color terminal palette ─────────────────────
M.base_16 = {
  base00 = "#151518", -- bg (surface)
  base01 = "#151518",
  base02 = "#3a3a48",
  base03 = "#2a2a35",
  base04 = "#4a4a5a",
  base05 = "#e8e8f0", -- fg
  base06 = "#e8e8f0",
  base07 = "#e8e8f0",
  base08 = "#ff2d55", -- red
  base09 = "#ff6b00", -- orange (variables, numbers, booleans)
  base0A = "#ff6b00", -- orange (tags, types, labels)
  base0B = "#C8FF00", -- lime (strings)
  base0C = "#00e5ff", -- cyan (special, escape, regex)
  base0D = "#00e5ff", -- cyan (functions, includes)
  base0E = "#b48cff", -- purple (keywords, conditionals)
  base0F = "#ff2d55", -- red (delimiters, brackets, punctuation)
}

-- ── Polish: aggressive cyberpunk syntax ────────────
M.polish_hl = {
  -- Treesitter — force aggressive cyberpunk mapping
  treesitter = {
    -- Red bold: control flow keywords, errors, return
    ["@keyword"] = { fg = "#ff2d55", bold = true },
    ["@keyword.function"] = { fg = "#ff2d55", bold = true },
    ["@keyword.return"] = { fg = "#ff2d55", bold = true },
    ["@keyword.import"] = { fg = "#ff2d55", bold = true },
    ["@keyword.conditional"] = { fg = "#ff2d55", bold = true },
    ["@keyword.conditional.ternary"] = { fg = "#ff2d55", bold = true },
    ["@keyword.repeat"] = { fg = "#ff2d55", bold = true },
    ["@keyword.exception"] = { fg = "#ff2d55", bold = true },
    ["@keyword.storage"] = { fg = "#ff2d55", bold = true },
    ["@keyword.directive"] = { fg = "#ff2d55", bold = true },
    ["@keyword.directive.define"] = { fg = "#ff2d55", bold = true },
    ["@keyword.operator"] = { fg = "#ff2d55" },

    -- Cyan: functions, constructors, builtins
    ["@function"] = { fg = "#00e5ff" },
    ["@function.builtin"] = { fg = "#00e5ff" },
    ["@function.macro"] = { fg = "#00e5ff" },
    ["@function.call"] = { fg = "#00e5ff" },
    ["@function.method"] = { fg = "#00e5ff" },
    ["@function.method.call"] = { fg = "#00e5ff" },
    ["@constructor"] = { fg = "#00e5ff" },

    -- Lime: strings
    ["@string"] = { fg = "#C8FF00" },
    ["@string.regex"] = { fg = "#00e5ff" },
    ["@string.escape"] = { fg = "#ff6b00" },

    -- Orange: numbers, constants, variable params
    ["@number"] = { fg = "#ff6b00" },
    ["@number.float"] = { fg = "#ff6b00" },
    ["@constant"] = { fg = "#ff6b00" },
    ["@constant.builtin"] = { fg = "#ff6b00" },
    ["@constant.macro"] = { fg = "#ff6b00" },
    ["@variable.parameter"] = { fg = "#ff6b00" },

    -- Purple: types, classes, enums
    ["@type"] = { fg = "#b48cff", bold = true },
    ["@type.builtin"] = { fg = "#b48cff", bold = true },
    ["@type.qualifier"] = { fg = "#b48cff" },

    -- Tag: red, attribute: cyan (HTML/JSX/XML)
    ["@tag"] = { fg = "#ff2d55" },
    ["@tag.attribute"] = { fg = "#00e5ff" },
    ["@tag.delimiter"] = { fg = "#6a6a80" },

    -- Punctuation: muted (brackets, dots, semicolons)
    ["@punctuation.bracket"] = { fg = "#6a6a80" },
    ["@punctuation.delimiter"] = { fg = "#6a6a80" },
    ["@punctuation.special"] = { fg = "#6a6a80" },

    -- Comments: muted italic
    ["@comment"] = { fg = "#6a6a80", italic = true },
    ["@comment.todo"] = { fg = "#ff6b00", italic = true },
    ["@comment.warning"] = { fg = "#ff6b00", bold = true },
    ["@comment.note"] = { fg = "#00e5ff", italic = true },
    ["@comment.danger"] = { fg = "#ff2d55", bold = true },

    -- Error: red bold with underline
    ["@error"] = { fg = "#ff2d55", bold = true, underline = true },

    -- Diff
    ["@diff.plus"] = { fg = "#C8FF00" },
    ["@diff.minus"] = { fg = "#ff2d55" },
    ["@diff.delta"] = { fg = "#ff6b00" },

    -- Markup
    ["@markup.heading"] = { fg = "#ff2d55", bold = true },
    ["@markup.raw"] = { fg = "#C8FF00" },
    ["@markup.link"] = { fg = "#00e5ff" },
    ["@markup.link.url"] = { fg = "#ff6b00", underline = true },
    ["@markup.link.label"] = { fg = "#00e5ff" },
    ["@markup.list"] = { fg = "#ff2d55" },
    ["@markup.strong"] = { bold = true },
    ["@markup.italic"] = { italic = true },

    -- Module/property
    ["@module"] = { fg = "#e8e8f0" },
    ["@property"] = { fg = "#00e5ff" },
    ["@variable"] = { fg = "#e8e8f0" },
    ["@variable.member"] = { fg = "#e8e8f0" },
    ["@variable.member.key"] = { fg = "#e8e8f0" },
    ["@variable.builtin"] = { fg = "#ff6b00" },
    ["@attribute"] = { fg = "#ff6b00" },
    ["@symbol"] = { fg = "#00e5ff" },
    ["@operator"] = { fg = "#ff2d55" },
    ["@label"] = { fg = "#b48cff" },
    ["@namespace"] = { fg = "#ff6b00" },
    ["@character"] = { fg = "#C8FF00" },
    ["@character.special"] = { fg = "#ff6b00" },
    ["@annotation"] = { fg = "#ff6b00" },
    ["@define"] = { fg = "#b48cff" },
  },
  -- Defaults — lime for all selected/active items
  defaults = {
    -- Core Neovim
    Visual = { bg = "#2a2a35" },
    CurSearch = { bg = "#2a2a35" },
    CurSearch = { bg = "#2a2a35" },
    Substitute = { bg = "#2a2a35" },
    LineNr = { fg = "#4a4a5a" },
    CursorLineNr = { fg = "#6a6a80" },
    -- Popup / Completion menus
    PmenuSel = { fg = "#C8FF00" },
    PmenuThumb = { bg = "#C8FF00" },
    CmpItemMenuSelected = { fg = "#C8FF00" },
    CmpItemKindSelected = { fg = "#C8FF00" },
    CmpCursor = { fg = "#C8FF00" },

    -- Telescope
    TelescopeSelection = { fg = "#C8FF00" },
    TelescopeSelectionCaret = { fg = "#C8FF00" },
    TelescopeMultiSelection = { fg = "#C8FF00" },

    -- Snacks picker (fzf-like)
    SnacksPickerMatch = { fg = "#C8FF00" },
    SnacksPickerSelected = { fg = "#C8FF00" },
    SnacksDashboardKey = { fg = "#C8FF00" },
    SnacksPickerListCursorLine = { fg = "#C8FF00" },
    SnacksPickerPreviewCursorLine = { fg = "#C8FF00" },

    -- Lazy
    LazyButtonActive = { fg = "#C8FF00" },
    LazyH1 = { fg = "#C8FF00" },

    -- Mini.pick
    MiniPickMatchCurrent = { fg = "#C8FF00" },
    MiniPickMatchMark = { fg = "#C8FF00" },

    -- Fzf-lua
    FzfLuaCursor = { fg = "#C8FF00" },
    FzfLuaMatch = { fg = "#C8FF00" },

    -- WhichKey
    WhichKeySelected = { fg = "#C8FF00" },

    -- Git signs
    GitSignsAddLn = { fg = "#C8FF00" },
  },
}

M.type = "dark"

return M
