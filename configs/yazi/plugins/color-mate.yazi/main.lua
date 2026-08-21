--- color-mate.yazi — shared filetype-color resolution.
---
--- Uses Yazi's own `file:style()` (THEME.filetype.match_style with mime
--- support) so drag cards and selection highlights track the exact same
--- colors the file list shows — no theme.toml parsing, no duplicated
--- extension mappings.

local M = {}
local FALLBACK = "#e8e8f0"

-- ratatui named colors -> CSS hex (used when a rule references e.g. "blue")
local NAMED = {
	black = "#000000",
	red = "#800000",
	green = "#008000",
	yellow = "#808000",
	blue = "#000080",
	magenta = "#800080",
	cyan = "#008080",
	gray = "#808080",
	darkgray = "#404040",
	lightred = "#ff0000",
	lightgreen = "#00ff00",
	lightyellow = "#ffff00",
	lightblue = "#0000ff",
	lightmagenta = "#ff00ff",
	lightcyan = "#00ffff",
	white = "#c0c0c0",
}

local function color_to_hex(v)
	if type(v) == "string" then
		if v:match("^#[0-9a-fA-F]+$") then
			return v
		end
		return NAMED[v:lower()]
	elseif type(v) == "table" then
		local r, g, b = v[1], v[2], v[3]
		if r and g and b then
			return string.format("#%02x%02x%02x", r, g, b)
		end
	end
	return nil
end

--- The filetype color (hex string) for a file, or CGGX silver when unmatched.
--- @param file File
--- @return string
function M.file_color(file)
	if not file then
		return FALLBACK
	end

	local ok, style = pcall(function() return file:style() end)
	if not ok or not style then
		return FALLBACK
	end

	local okr, raw = pcall(function() return style:raw() end)
	if not okr or not raw then
		return FALLBACK
	end

	return color_to_hex(raw.fg) or color_to_hex(raw.bg) or FALLBACK
end

return M