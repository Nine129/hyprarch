--- adaptive-select.yazi — hover highlight follows filetype theme colors.
---
--- When an item is hovered:
---   - Current pane: adaptive filetype color bg, black text, bold
---   - Parent (left) pane: adaptive filetype color bg, black text, bold
---   - Preview pane: NO highlight (base style only)
---   - Else: default indicator styles

local color_mate = require("color-mate")

local function hook_entity()
	if not Entity or type(Entity) ~= "table" or not Entity.style then
		return
	end
	local old_style = Entity.style
	function Entity:style()
		-- Preview pane: return base style WITHOUT any indicator patch
		if self._file and self._file.is_hovered and self._file.in_preview then
			return self._file:style() or ui.Style()
		end

		-- Current/Parent: adaptive filetype highlight
		local s = old_style(self)
		if self._file and self._file.is_hovered then
			if self._file.in_current or (not self._file.in_current and not self._file.in_preview) then
				local c = color_mate.file_color(self._file)
				if c then
					s = s:patch(ui.Style():bg(c):fg("#0a0a0c"):bold())
				end
			end
		end
		return s
	end
end

return {
	setup = function()
		hook_entity()
	end,
}