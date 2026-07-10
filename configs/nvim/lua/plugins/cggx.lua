-- ============================================================================
-- FILE:  ~/.config/nvim/lua/plugins/cggx.lua
-- ============================================================================
-- Dashboard using snacks.nvim — CGGX cyberpunk palette

return {
   "folke/snacks.nvim",
   priority = 1000,
   lazy = false,
   dependencies = {
      "nvim-tree/nvim-web-devicons",
   },
   ---@type snacks.Config
   opts = {
      dashboard = {
         enabled = true,
         width = 60,
         row = 4,
         col = nil,
         pane_gap = 10,
         preset = {
            pick = function(cmd, opts)
               local fzf = require("fzf-lua")
               opts = opts or {}
               if cmd == "files" then fzf.files(opts)
               elseif cmd == "live_grep" then fzf.live_grep(opts)
               elseif cmd == "oldfiles" then fzf.oldfiles(opts) end
            end,
            keys = {
               { icon = "󰝒 ", key = "f", icon_hl = "CGGXKeyR", key_hl = "CGGXKeyR", desc_hl = "CGGXKeyR", desc = "Find File",  action = ":lua Snacks.dashboard.pick('files')" },
               { icon = "󰝒 ", key = "n", icon_hl = "CGGXKeyO", key_hl = "CGGXKeyO", desc_hl = "CGGXKeyO", desc = "New File",   action = ":ene | startinsert" },
               { icon = " ", key = "g", icon_hl = "CGGXKeyL", key_hl = "CGGXKeyL", desc_hl = "CGGXKeyL", desc = "Find Text",  action = ":lua Snacks.dashboard.pick('live_grep')" },
               { icon = " ", key = "r", icon_hl = "CGGXKeyC", key_hl = "CGGXKeyC", desc_hl = "CGGXKeyC", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
               { icon = " ", key = "c", icon_hl = "CGGXKeyP", key_hl = "CGGXKeyP", desc_hl = "CGGXKeyP", desc = "Config",     action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})" },
               { icon = " ", key = "s", icon_hl = "CGGXKeyR", key_hl = "CGGXKeyR", desc_hl = "CGGXKeyR", desc = "Restore Session", section = "session" },
               { icon = "󰒲 ", key = "l", icon_hl = "CGGXKeyO", key_hl = "CGGXKeyO", desc_hl = "CGGXKeyO", desc = "Lazy",       action = ":Lazy", enabled = package.loaded.lazy ~= nil },
               { icon = " ", key = "q", icon_hl = "CGGXKeyL", key_hl = "CGGXKeyL", desc_hl = "CGGXKeyL", desc = "Quit",       action = ":qa" },
            },
            header = {
               -- Row 1
               { "███╗   ██╗", hl = "CGGXHeaderN" },
               { "███████╗", hl = "CGGXHeaderE" },
               { " ██████╗", hl = "CGGXHeaderO" },
               { " ██╗   ██╗", hl = "CGGXHeaderV" },
               { "██╗", hl = "CGGXHeaderI" },
               { "███╗   ███╗", hl = "CGGXHeaderM" },
               { "\n" },
               -- Row 2
               { "████╗  ██║", hl = "CGGXHeaderN" },
               { "██╔════╝", hl = "CGGXHeaderE" },
               { "██╔═══██", hl = "CGGXHeaderO" },
               { "╗██║   ██║", hl = "CGGXHeaderV" },
               { "██║", hl = "CGGXHeaderI" },
               { "████╗ ████║", hl = "CGGXHeaderM" },
               { "\n" },
               -- Row 3
               { "██╔██╗ ██║", hl = "CGGXHeaderN" },
               { "█████╗  ", hl = "CGGXHeaderE" },
               { "██║   ██", hl = "CGGXHeaderO" },
               { "║██║   ██║", hl = "CGGXHeaderV" },
               { "██║", hl = "CGGXHeaderI" },
               { "██╔████╔██║", hl = "CGGXHeaderM" },
               { "\n" },
               -- Row 4
               { "██║╚██╗██║", hl = "CGGXHeaderN" },
               { "██╔══╝  ", hl = "CGGXHeaderE" },
               { "██║   ██", hl = "CGGXHeaderO" },
               { "║╚██╗ ██╔╝", hl = "CGGXHeaderV" },
               { "██║", hl = "CGGXHeaderI" },
               { "██║╚██╔╝██║", hl = "CGGXHeaderM" },
               { "\n" },
               -- Row 5
               { "██║ ╚████║", hl = "CGGXHeaderN" },
               { "███████╗", hl = "CGGXHeaderE" },
               { "╚██████╔", hl = "CGGXHeaderO" },
               { "╝ ╚████╔╝ ", hl = "CGGXHeaderV" },
               { "██║", hl = "CGGXHeaderI" },
               { "██║ ╚═╝ ██║", hl = "CGGXHeaderM" },
               { "\n" },
               -- Row 6
               { "╚═╝  ╚═══╝", hl = "CGGXHeaderN" },
               { "╚══════╝", hl = "CGGXHeaderE" },
               { " ╚═════╝", hl = "CGGXHeaderO" },
               { "   ╚═══╝  ", hl = "CGGXHeaderV" },
               { "╚═╝", hl = "CGGXHeaderI" },
               { "╚═╝     ╚═╝", hl = "CGGXHeaderM" },
            },

         },

         formats = {
            key = function(item)
               return { item.key, hl = item.key_hl or "key" }
            end,
            desc = function(item)
               return { item.desc, hl = item.desc_hl or "desc" }
            end,
            icon = function(item)
               if item.file and (item.icon == "file" or item.icon == "directory") then
                  local icon, _ = require("nvim-web-devicons").get_icon(item.file, nil, { default = true })
                  return { { icon or " ", hl = "CGGXFileIcon" } }
               end
               local hl = item.icon_hl or "CGGXIcon"
               return { { item.icon, hl = hl } }
            end,
            footer = function(item)
               local parts = {}
               for word, num in item.footer:gmatch("([%a%s]+)(%d+[/%dms]+)") do
                  table.insert(parts, { word, hl = "CGGXFooterText" })
                  table.insert(parts, { num,  hl = "CGGXFooterVal" })
               end
               if #parts == 0 then
                  return { item.footer, hl = "CGGXFooterText" }
               end
               return parts
            end,
            file = function(item, ctx)
               local fname = vim.fn.fnamemodify(item.file, ":~")
               fname = ctx.width and #fname > ctx.width and vim.fn.pathshorten(fname) or fname
               local dir, file = fname:match("^(.*)/(.+)$")
               return dir and { { dir .. "/", hl = "CGGXDir" }, { file, hl = "CGGXFile" } } or { { fname, hl = "CGGXFile" } }
            end,
         },

         sections = {
            { section = "header", align = "center" },
            { pane = 2, text = " ", padding = 1 },
            { section = "keys", gap = 1, padding = 1 },
            { pane = 2, icon = " ", title = "Recent Files", section = "recent_files", indent = 2, padding = { 1, 1 }, limit = 5 },
            { pane = 2, icon = "󰉓 ", title = "Projects", section = "projects", indent = 2, padding = { 1, 1 }, limit = 4 },
         },
      },
      git = { enabled = true },
      gitbrowse = { enabled = true },
      bigfile = { enabled = true },
      notifier = { enabled = true, timeout = 3000 },
      quickfile = { enabled = true },
      statuscolumn = { enabled = false },
      words = { enabled = true },
      styles = { notification = { wo = { wrap = true } } },
   },

   keys = {
      { "<leader>.",  function() Snacks.scratch() end,              desc = "Toggle Scratch Buffer" },
      { "<leader>S",  function() Snacks.scratch.select() end,       desc = "Select Scratch Buffer" },
      { "<leader>n",  function() Snacks.notifier.show_history() end, desc = "Notification History" },
      { "<leader>bd", function() Snacks.bufdelete() end,            desc = "Delete Buffer" },
      { "<leader>gg", function() Snacks.lazygit() end,              desc = "Lazygit" },
      { "<leader>gb", function() Snacks.git.blame_line() end,       desc = "Git Blame Line" },
      { "<leader>gB", function() Snacks.gitbrowse() end,            desc = "Git Browse" },
      { "<leader>gf", function() Snacks.lazygit.log_file() end,     desc = "Lazygit Current File History" },
      { "<leader>gl", function() Snacks.lazygit.log() end,          desc = "Lazygit Log (cwd)" },
      { "<leader>cR", function() Snacks.rename() end,               desc = "Rename File" },
      { "<c-/>",      function() Snacks.terminal() end,             desc = "Toggle Terminal" },
      { "<c-_>",      function() Snacks.terminal() end,             desc = "which_key_ignore" },
      { "]]",         function() Snacks.words.jump(vim.v.count1) end,      desc = "Next Reference" },
      { "[[",         function() Snacks.words.jump(-vim.v.count1) end,     desc = "Prev Reference" },
   },

   init = function()
      local c = {
         bg      = "#151518",
         fg      = "#e8e8f0",
         red     = "#ff2d55",
         cyan    = "#00e5ff",
         lime    = "#C8FF00",
         orange  = "#ff6b00",
         purple  = "#b48cff",
         muted   = "#6a6a80",
      }

      vim.api.nvim_set_hl(0, "CGGXKeyR",       { fg = c.red,    bold = true })
      vim.api.nvim_set_hl(0, "CGGXKeyO",       { fg = c.orange, bold = true })
      vim.api.nvim_set_hl(0, "CGGXKeyL",       { fg = c.lime,   bold = true })
      vim.api.nvim_set_hl(0, "CGGXKeyC",       { fg = c.cyan,   bold = true })
      vim.api.nvim_set_hl(0, "CGGXKeyP",       { fg = c.purple, bold = true })
      vim.api.nvim_set_hl(0, "CGGXHeaderN", { fg = c.red,    bold = true })
      vim.api.nvim_set_hl(0, "CGGXHeaderE", { fg = c.orange, bold = true })
      vim.api.nvim_set_hl(0, "CGGXHeaderO", { fg = c.lime,   bold = true })
      vim.api.nvim_set_hl(0, "CGGXHeaderV", { fg = c.cyan,   bold = true })
      vim.api.nvim_set_hl(0, "CGGXHeaderI", { fg = c.purple, bold = true })
      vim.api.nvim_set_hl(0, "CGGXHeaderM", { fg = c.red,    bold = true })
      vim.api.nvim_set_hl(0, "CGGXIcon",       { fg = c.red })
      vim.api.nvim_set_hl(0, "CGGXFooterText", { fg = c.lime })
      vim.api.nvim_set_hl(0, "CGGXFooterVal",  { fg = c.orange, bold = true })
      vim.api.nvim_set_hl(0, "CGGXFileIcon",   { fg = c.red })
      vim.api.nvim_set_hl(0, "CGGXFile",       { fg = c.lime })
      vim.api.nvim_set_hl(0, "CGGXDir",        { fg = c.muted })
      vim.api.nvim_set_hl(0, "key",            { fg = c.red, bold = true })
      vim.api.nvim_set_hl(0, "SnacksDashboardSpecial", { fg = c.purple })
      vim.api.nvim_set_hl(0, "SnacksDashboardTitle",   { fg = c.red, bold = true })
      vim.api.nvim_set_hl(0, "desc",           { fg = c.fg })
      -- Lime for ALL selected/active items
      -- Deferred to run AFTER base46 cache loads (init.lua line 29: dofile after lazy.setup)
      vim.defer_fn(function()
         vim.api.nvim_set_hl(0, "Visual",                       { bg = "#2a2a35" })
         vim.api.nvim_set_hl(0, "CurSearch",                    { bg = "#2a2a35" })
         vim.api.nvim_set_hl(0, "Substitute",                   { bg = "#2a2a35" })
         vim.api.nvim_set_hl(0, "PmenuSel",                     { bg = "#2a2a35" })
         vim.api.nvim_set_hl(0, "LineNr",                       { fg = "#4a4a5a" })
         vim.api.nvim_set_hl(0, "CursorLineNr",                 { fg = "#6a6a80" })
         vim.api.nvim_set_hl(0, "PmenuThumb",                   { bg = c.lime })
         vim.api.nvim_set_hl(0, "CmpItemMenuSelected",          { fg = c.lime })
         vim.api.nvim_set_hl(0, "CmpItemKindSelected",          { fg = c.lime })
         vim.api.nvim_set_hl(0, "CmpCursor",                    { fg = c.lime })
         vim.api.nvim_set_hl(0, "TelescopeSelection",           { fg = c.lime })
         vim.api.nvim_set_hl(0, "TelescopeSelectionCaret",      { fg = c.lime })
         vim.api.nvim_set_hl(0, "TelescopeMultiSelection",      { fg = c.lime })
         vim.api.nvim_set_hl(0, "SnacksPickerMatch",            { fg = c.lime })
         vim.api.nvim_set_hl(0, "SnacksPickerSelected",         { fg = c.lime })
         vim.api.nvim_set_hl(0, "SnacksDashboardKey",           { fg = c.lime })
         vim.api.nvim_set_hl(0, "LazyButtonActive",             { fg = c.lime })
         vim.api.nvim_set_hl(0, "LazyH1",                       { fg = c.lime })
         vim.api.nvim_set_hl(0, "MiniPickMatchCurrent",         { fg = c.lime })
         vim.api.nvim_set_hl(0, "MiniPickMatchMark",            { fg = c.lime })
         vim.api.nvim_set_hl(0, "FzfLuaCursor",                 { fg = c.lime })
         vim.api.nvim_set_hl(0, "FzfLuaMatch",                  { fg = c.lime })
         vim.api.nvim_set_hl(0, "WhichKeySelected",             { fg = c.lime })
         vim.api.nvim_set_hl(0, "GitSignsAddLn",                { fg = c.lime })
         vim.api.nvim_set_hl(0, "CursorLine",                   { fg = c.lime })
         vim.api.nvim_set_hl(0, "SnacksPickerListCursorLine",   { fg = c.lime })
         vim.api.nvim_set_hl(0, "SnacksPickerPreviewCursorLine",{ fg = c.lime })
      end, 100)

      vim.api.nvim_create_autocmd("User", {
         pattern = "VeryLazy",
         callback = function()
            if not Snacks then return end
            _G.dd = function(...) Snacks.debug.inspect(...) end
            _G.bt = function() Snacks.debug.backtrace() end
            vim.print = _G.dd

            Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
            Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
            Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>uL")
            Snacks.toggle.diagnostics():map("<leader>ud")
            Snacks.toggle.line_number():map("<leader>ul")
            Snacks.toggle.option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 }):map("<leader>uc")
            Snacks.toggle.treesitter():map("<leader>uT")
            Snacks.toggle.option("background", { off = "light", on = "dark", name = "Dark Background" }):map("<leader>ub")
            Snacks.toggle.inlay_hints():map("<leader>uh")
         end,
      })
   end,
}
