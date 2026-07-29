-- This file needs to have same structure as nvconfig.lua 
-- https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua
-- Please read that file to know all available options :( 

---@type ChadrcConfig
local M = {}

M.base46 = {
	theme = "nvcggx",
	hl_override = {
		-- Panels: slightly darker than editor
		NormalFloat = { bg = "#151518" },
		NvimTreeNormal = { bg = "#151518" },
		NvimTreeNormalNC = { bg = "#151518" },
		TelescopeNormal = { bg = "#151518" },
		TelescopeBorder = { bg = "#151518", fg = "#C8FF00" },
		TelescopePromptBorder = { bg = "#151518", fg = "#ff2d55" },
		TelescopePromptNormal = { bg = "#151518" },
		TelescopeResultsTitle = { bg = "#151518", fg = "#C8FF00" },
		TelescopePreviewTitle = { bg = "#ff6b00", fg = "#000000" },
		-- Text/highlight selection: red bg, black text
		Visual = { bg = "#ff2d55", fg = "#000000" },
		Substitute = { bg = "#ff2d55", fg = "#000000" },
		PmenuSel = { bg = "#ff2d55", fg = "#000000" },
		-- Picker item focus: lime fg, subtle grey bg
		TelescopeSelection = { bg = "#2a2a35", fg = "#C8FF00" },
		LazyH1 = { bg = "#2a2a35", fg = "#C8FF00" },
		LineNr = { fg = "#6a6a80" },
		CursorLineNr = { fg = "#C8FF00" },
		PmenuThumb = { bg = "#C8FF00" },
	},
	hl_add = {
		-- NvimTree filetype colors (matching Yazi)
		NvimTreeImageFile = { fg = "#ff6b00" },
		NvimTreeExecFile = { fg = "#C8FF00" },
		NvimTreeSpecialFile = { fg = "#b48cff" },
		-- Telescope borders not in any base46 integration
		TelescopeResultsBorder = { bg = "#151518", fg = "#C8FF00" },
		TelescopePreviewBorder = { bg = "#151518", fg = "#ff6b00" },
		TelescopeResultsNormal = { bg = "#151518" },
		TelescopePreviewNormal = { bg = "#151518" },
		-- Text search/selection: red bg, black text
		CurSearch = { bg = "#ff2d55", fg = "#000000" },
		-- Picker item focus: lime fg, subtle grey bg
		CmpItemMenuSelected = { bg = "#2a2a35", fg = "#C8FF00" },
		CmpItemKindSelected = { bg = "#2a2a35", fg = "#C8FF00" },
		CmpCursor = { bg = "#2a2a35", fg = "#C8FF00" },
		TelescopeSelectionCaret = { bg = "#2a2a35", fg = "#C8FF00" },
		TelescopeMultiSelection = { bg = "#2a2a35", fg = "#C8FF00" },
		SnacksPickerMatch = { bg = "#2a2a35", fg = "#C8FF00" },
		SnacksPickerSelected = { bg = "#2a2a35", fg = "#C8FF00" },
		SnacksDashboardKey = { fg = "#C8FF00" },
		LazyButtonActive = { bg = "#2a2a35", fg = "#C8FF00" },
		MiniPickMatchCurrent = { bg = "#2a2a35", fg = "#C8FF00" },
		MiniPickMatchMark = { bg = "#2a2a35", fg = "#C8FF00" },
		FzfLuaCursor = { bg = "#2a2a35", fg = "#C8FF00" },
		FzfLuaMatch = { bg = "#2a2a35", fg = "#C8FF00" },
		WhichKeySelected = { bg = "#2a2a35", fg = "#C8FF00" },
		GitSignsAddLn = { fg = "#C8FF00" },
		SnacksPickerListCursorLine = { bg = "#2a2a35", fg = "#C8FF00" },
		SnacksPickerPreviewCursorLine = { bg = "#2a2a35", fg = "#C8FF00" },
	},
}

return M

