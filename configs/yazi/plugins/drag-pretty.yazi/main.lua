--- drag-pretty.yazi — prettier drag & drop visuals.
--
-- Drag-out: kitty receives a square-corner PNG card with the filetype color,
--   black filename text, and the themed file icon in a compact tile.
--
-- Drop-in: the "Drop to copy/move here" slots become rounded cards in the
--   CGGX palette — the active one fills with its accent color, the other
--   stays dim.
--
-- Implementation: patches the built-in `Dnd` component, same pattern as
--   `Linemode` patches in folder-count.yazi.

local color_mate = require("color-mate")

local ZONE = {
	copy = { glyph = "    ", fg = "#0a0a0c", bg = "#c8ff00", text = "Drop to copy here" },
	move = { glyph = "    ", fg = "#0a0a0c", bg = "#ff2d55", text = "Drop to move here" },
}
local IDLE = { fg = "#6a6a80", bg = "#151518", edge = "#6a6a80" }

-- Text fallback settings. The normal path is the PNG card below.
local CHIP = { width = 6, height = 4, opacity = 900 }
local CARD = {
	bg = "#e8e8f0",
	fg = "#0a0a0c",
	font = "MonaspiceNe Nerd Font",
	height = 24,
	padding = 4,
	gap = 6,
	font_size = 16,
}
local NAME_MAX = 30

local function str_width(s)
	if utf8 then
		local ok, n = pcall(utf8.len, s)
		if ok then
			return n
		end
	end
	return #s
end

local function truncate(s, n)
	if #s <= n then
		return s
	end

	local t = s:sub(1, n)
	local b = t:byte(-1)
	while b and b >= 0x80 and b < 0xc0 do
		t = t:sub(1, -2)
		b = t:byte(-1)
	end
	if b and b >= 0xc0 then
		t = t:sub(1, -2)
	end
	return t .. "…"
end

local function xml_escape(s)
	return s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"):gsub('"', "&quot;"):gsub("'", "&apos;")
end

local function selected_file()
	-- `cx.active.selected` is a Rust iterator here, not a table — indexing
	-- it throws. Take the first item via pairs(), like the built-in dnd
	-- plugin does.
	local file
	for _, f in pairs(cx.active.selected) do
		file = f
		break
	end
	return file or cx.active.current.hovered
end

local function chip_parts(list)
	local file = selected_file()
	local glyph = ""
	if file and th.icon then
		local icon = th.icon:match(file)
		if icon then
			glyph = (icon.text or ""):gsub("^%s+", ""):gsub("%s+$", "")
		end
	end

	local name = #list > 1 and string.format("%d files", #list) or (file and file.name or "")
	return file, glyph, truncate(name, NAME_MAX)
end

local function chip_label(list)
	local _, glyph, name = chip_parts(list)
	return string.format(" %s  %s ", glyph, name)
end

local function shell_path(path)
	-- os.tmpname() returns a local temporary path without shell metacharacters.
	return "'" .. path .. "'"
end

local function render_drag_card(list)
	local file, glyph, name = chip_parts(list)
	local bg = color_mate.file_color(file)
	local icon = xml_escape(glyph ~= "" and glyph or "•")
	local safe_name = xml_escape(name:gsub("[%c]", " "))
	local text_width = math.max(1, str_width(name)) * CARD.font_size * 0.62
	local icon_width = CARD.font_size
	local width = math.ceil(CARD.padding * 2 + icon_width + CARD.gap + text_width)
	local height = CARD.height
	local icon_x = math.floor(CARD.padding + icon_width / 2)
	local text_x = CARD.padding + icon_width + CARD.gap
	local text_y = math.floor((height - CARD.font_size) / 2 + CARD.font_size * 0.78) + 2
	local svg = ([=[<svg xmlns="http://www.w3.org/2000/svg" width="%d" height="%d" viewBox="0 0 %d %d">
<rect x="1" y="1" width="%d" height="%d" fill="%s" stroke="%s" stroke-width="2"/>
<text x="%d" y="%d" text-anchor="middle" font-family="%s" font-size="%d" font-weight="700" fill="%s">%s</text>
<text x="%d" y="%d" font-family="%s" font-size="%d" font-weight="700" fill="%s">%s</text>
</svg>]=]):format(
	width,
	height,
	width,
	height,
	width - 2,
	height - 2,
	bg,
	CARD.fg,
	icon_x,
	text_y,
	CARD.font,
	CARD.font_size,
	CARD.fg,
	icon,
	text_x,
	text_y,
	CARD.font,
	CARD.font_size,
	CARD.fg,
	safe_name
)

	local stem = os.tmpname()
	local svg_path, png_path = stem .. ".svg", stem .. ".png"
	local file = io.open(svg_path, "wb")
	if not file then
		return nil
	end
	file:write(svg)
	file:close()
	os.remove(stem)

	local function render(command)
		os.execute(command)
		local output = io.open(png_path, "rb")
		if not output then
			return nil
		end
		local data = output:read("*a")
		output:close()
		return data
	end

	local data = render("rsvg-convert -o " .. shell_path(png_path) .. " " .. shell_path(svg_path))
	if not data then
		data = render("magick " .. shell_path(svg_path) .. " " .. shell_path(png_path))
	end
	os.remove(svg_path)
	os.remove(png_path)
	return data, width, height
end

-- Drop slot: 3-row rounded card. Active fills with the accent color and
-- outlines itself in dark; idle is a dim panel.
local function slot(area, label, z, active)
	local bg = active and z.bg or IDLE.bg
	local edge = active and z.fg or IDLE.edge
	local fg = active and z.fg or IDLE.fg
	local inner = math.max(1, area.w - 2)

	local w = str_width(label)
	local pad = math.max(0, math.floor((inner - w) / 2))
	local mid = "│" .. string.rep(" ", pad) .. label .. string.rep(" ", math.max(0, inner - pad - w)) .. "│"

	return {
		ui.Clear(area),
		ui.Text("╭" .. string.rep("─", inner) .. "╮")
			:area(ui.Rect { x = area.x, y = area.y, w = area.w, h = 1 })
			:fg(edge):bg(bg),
		ui.Text(mid)
			:area(ui.Rect { x = area.x, y = area.y + 1, w = area.w, h = 1 })
			:fg(fg):bg(bg):bold(active),
		ui.Text("╰" .. string.rep("─", inner) .. "╯")
			:area(ui.Rect { x = area.x, y = area.y + 2, w = area.w, h = 1 })
			:fg(edge):bg(bg),
	}
end

local function setup(_, opts)
	opts = opts or {}
	if opts.copy then
		ZONE.copy = setmetatable(opts.copy, { __index = ZONE.copy })
	end
	if opts.move then
		ZONE.move = setmetatable(opts.move, { __index = ZONE.move })
	end
	if opts.chip then
		CHIP.width = opts.chip.width or CHIP.width
		CHIP.height = opts.chip.height or CHIP.height
		CHIP.opacity = opts.chip.opacity or CHIP.opacity
	end

	-- Drag-out: exact-color PNG card; text fallback if rendering fails.
	function Dnd.drag(event)
		if event.type == "offer" then
			local list = require("dnd").selected_uri_list()
			if #list == 0 then
				Dnd._dragging = false
				return
			end

			rt.tty:queue("AgreeDrag", { type = "either", mimes = { "text/uri-list" } })
			rt.tty:queue("PresentDrag", { idx = 0, data = table.concat(list, "\r\n") })
			local image, width, height = render_drag_card(list)
			if image then
				rt.tty:queue("PresentDragIcon", {
					format = 100,
					opacity = 1024,
					width = width,
					height = height,
					data = image,
				})
			else
				rt.tty:queue("PresentDragIcon", {
					format = 0,
					opacity = CHIP.opacity,
					width = CHIP.width,
					height = CHIP.height,
					data = chip_label(list),
				})
			end
			rt.tty:queue("StartDrag", {})
			rt.tty:flush()
			Dnd._dragging = true
		elseif event.type == "end" or event.type == "error" then
			Dnd._dragging = false
		end
	end

	-- Drop-in: accent-filled active slot, dim idle one.
	function Dnd:redraw()
		if not Dnd._dropping then
			return {}
		end

		local elements = {}
		for _, item in ipairs(self._items) do
			local z = ZONE[item.op]
			local parts = slot(item.area, z.glyph .. z.text, z, item.op == Dnd._op)
			for _, e in ipairs(parts) do
				elements[#elements + 1] = e
			end
		end
		return elements
	end
end

return { setup = setup }