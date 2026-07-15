if os.getenv("YAZI_NO_SESSION") ~= "1" then
    require("autosession"):setup()
end
require("full-border"):setup()
require("git"):setup {
	-- Order of status signs showing in the linemode
	order = 1500,
}
require("copy-file-contents"):setup({
	append_char = "\n",
	notification = true,
})
require("yatline"):setup({
	section_separator = { open = "", close = "" },
	part_separator = { open = "", close = "" },
	inverse_separator = { open = "", close = "" },
	padding = { inner = 1, outer = 1 },

	style_a = {
		bg = "#c8ff00",
		fg = "#0a0a0c",
		bg_mode = {
			normal = "#00e5ff",
			select = "#C8FF00",
			un_set = "#6a6a80",
		},
	},
	style_b = { bg = "brightblack", fg = "brightwhite" },
	style_c = { bg = "black", fg = "brightwhite" },

	permissions_t_fg = "green",
	permissions_r_fg = "yellow",
	permissions_w_fg = "red",
	permissions_x_fg = "cyan",
	permissions_s_fg = "white",

	tab_width = 20,

	selected = { icon = "󰻭", fg = "yellow" },
	copied = { icon = "", fg = "green" },
	cut = { icon = "", fg = "red" },

	files = { icon = "", fg = "blue" },
	filtereds = { icon = "", fg = "magenta" },

	total = { icon = "󰮍", fg = "yellow" },
	success = { icon = "", fg = "green" },
	failed = { icon = "", fg = "red" },

	show_background = true,

	display_header_line = true,
	display_status_line = true,

	component_positions = { "header", "tab", "status" },

	header_line = {
		left = {
			section_a = {
				{ type = "line", name = "tabs", style = { bg = "#ff2d55", fg = "#0a0a0c" } },
			},
			section_b = {},
			section_c = {},
		
    },
		right = {
			section_a = {
				{ type = "string", name = "date", params = { "%A, %d %B %Y" }, style = { bg = "#ff6b00", fg = "#0a0a0c" } },
			},
			section_b = {
				{ type = "string", name = "date", params = { "%X" } },
			},
			section_c = {},
		},
	},

	status_line = {
		left = {
			section_a = {
				{ type = "string", name = "tab_mode" },
			},
			section_b = {
				{ type = "string", name = "hovered_size" },
			},
			section_c = {
				{ type = "string", name = "hovered_path" },
        {type = "coloreds", custom = false, name = "count", params = { true }},
			},
		},
		right = {
			section_a = {
				{ type = "string", name = "cursor_position", style = { bg = "#C8FF00", fg = "#0a0a0c" } },
			},
			section_b = {
				{ type = "string", name = "cursor_percentage" },
			},
			section_c = {
				{ type = "coloreds", name = "permissions" },
			},
		},
	},
})
