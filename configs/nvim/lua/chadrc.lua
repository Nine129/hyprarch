-- This file needs to have same structure as nvconfig.lua 
-- https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua
-- Please read that file to know all available options :( 

---@type ChadrcConfig
local M = {}

M.base46 = {
	theme = "nvcggx",
	hl_override = {
		-- Lime for ALL selected/active items
		Visual = { bg = "#2a2a35" },
		CurSearch = { bg = "#2a2a35" },
		Substitute = { bg = "#2a2a35" },
		PmenuSel = { bg = "#2a2a35" },
		LineNr = { fg = "#4a4a5a" },
		CursorLineNr = { fg = "#6a6a80" },
		PmenuThumb = { bg = "#C8FF00" },
		CmpItemMenuSelected = { fg = "#C8FF00" },
		CmpItemKindSelected = { fg = "#C8FF00" },
		CmpCursor = { fg = "#C8FF00" },
		TelescopeSelection = { fg = "#C8FF00" },
		TelescopeSelectionCaret = { fg = "#C8FF00" },
		TelescopeMultiSelection = { fg = "#C8FF00" },
		SnacksPickerMatch = { fg = "#C8FF00" },
		SnacksPickerSelected = { fg = "#C8FF00" },
		SnacksDashboardKey = { fg = "#C8FF00" },
		LazyButtonActive = { fg = "#C8FF00" },
		LazyH1 = { fg = "#C8FF00" },
		MiniPickMatchCurrent = { fg = "#C8FF00" },
		MiniPickMatchMark = { fg = "#C8FF00" },
		FzfLuaCursor = { fg = "#C8FF00" },
		FzfLuaMatch = { fg = "#C8FF00" },
		WhichKeySelected = { fg = "#C8FF00" },
		GitSignsAddLn = { fg = "#C8FF00" },
		-- NvimTree filetype colors (matching Yazi)
		NvimTreeImageFile = { fg = "#ff6b00" },       -- yellow (images)
		NvimTreeExecFile = { fg = "#C8FF00" },         -- green (executables)
		NvimTreeSpecialFile = { fg = "#b48cff" },      -- magenta (config/special)
	},
}

-- M.nvdash = { load_on_startup = true }
-- M.ui = {
--       tabufline = {
--          lazyload = false
--      }
-- }

return M
