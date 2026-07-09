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
               if cmd == "files" then
                  fzf.files(opts)
               elseif cmd == "live_grep" then
                  fzf.live_grep(opts)
               elseif cmd == "oldfiles" then
                  fzf.oldfiles(opts)
               end
            end,
            keys = {
               { icon = "󰝒 ", key = "f", icon_hl = "CGGXKeyR", key_hl = "CGGXKeyR", desc_hl = "CGGXKeyR", desc = "Find File",  action = ":lua Snacks.dashboard.pick('files')" },
               { icon = "󰝒 ", key = "n", icon_hl = "CGGXKeyO", key_hl = "CGGXKeyO", desc_hl = "CGGXKeyO", desc = "New File",   action = ":ene | startinsert" },
               { icon = " ", key = "g", icon_hl = "CGGXKeyL", key_hl = "CGGXKeyL", desc_hl = "CGGXKeyL", desc = "Find Text",  action = ":lua Snacks.dashboard.pick('live_grep')" },
               { icon = " ", key = "r", icon_hl = "CGGXKeyC", key_hl = "CGGXKeyC", desc_hl = "CGGXKeyC", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
               { icon = " ", key = "c", icon_hl = "CGGXKeyP", key_hl = "CGGXKeyP", desc_hl = "CGGXKeyP", desc = "Config",     action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})" },
               { icon = " ", key = "s", icon_hl = "CGGXKeyR", key_hl = "CGGXKeyR", desc_hl = "CGGXKeyR", desc = "Restore Session", section = "session" },
               { icon = "󰒲 ", key = "l", icon_hl = "CGGXKeyO", key_hl = "CGGXKeyO", desc_hl = "CGGXKeyO", desc = "Lazy",       action = ":Lazy", enabled = package.loaded.lazy ~= nil },
               { icon = " ", key = "q", icon_hl = "CGGXKeyR", key_hl = "CGGXKeyR", desc_hl = "CGGXKeyR", desc = "Quit",       action = ":qa" },
            },

            -- Header rendered via terminal section with ANSI (see sections below)
            header = "",
         },

         -- ============================================================
         -- FORMATS: key bracket + icon + file display
         -- ============================================================
         formats = {
            key = function(item)
               return { item.key, hl = item.key_hl or "key" }
            end,
            desc = function(item)
               return { item.desc, hl = item.desc_hl or "desc" }
            end,
            footer = function(item)
               -- "Neovim loaded X/Y plugins in Zms" → text=lime, numbers=orange
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
            icon = function(item)
               if item.file and (item.icon == "file" or item.icon == "directory") then
                  local icon, _ = require("nvim-web-devicons").get_icon(item.file, nil, { default = true })
                  return { { icon or " ", hl = "CGGXFileIcon" } }
               end
               local hl = item.icon_hl or "CGGXIcon"
               return { { item.icon, hl = hl } }
            end,
         },

         -- ============================================================
         -- SECTIONS: two-pane layout
         -- ============================================================
         sections = {
            { pane = 2, text = " ", padding = -10 },
            -- Left: NEOVIM header via ANSI terminal (per-letter CGGX colors)
            {
               section = "terminal",
               cmd = [[printf '     \033[38;2;255;45;85m███╗   ██╗\033[38;2;255;107;0m███████╗\033[38;2;200;255;0m ██████╗\033[38;2;0;229;255m ██╗   ██╗\033[38;2;180;140;255m██╗\033[38;2;255;45;85m███╗   ███╗\033[0m\n     \033[38;2;255;45;85m████╗  ██║\033[38;2;255;107;0m██╔════╝\033[38;2;200;255;0m██╔═══██\033[38;2;0;229;255m╗██║   ██║\033[38;2;180;140;255m██║\033[38;2;255;45;85m████╗ ████║\033[0m\n     \033[38;2;255;45;85m██╔██╗ ██║\033[38;2;255;107;0m█████╗  \033[38;2;200;255;0m██║   ██\033[38;2;0;229;255m║██║   ██║\033[38;2;180;140;255m██║\033[38;2;255;45;85m██╔████╔██║\033[0m\n     \033[38;2;255;45;85m██║╚██╗██║\033[38;2;255;107;0m██╔══╝  \033[38;2;200;255;0m██║   ██\033[38;2;0;229;255m║╚██╗ ██╔╝\033[38;2;180;140;255m██║\033[38;2;255;45;85m██║╚██╔╝██║\033[0m\n     \033[38;2;255;45;85m██║ ╚████║\033[38;2;255;107;0m███████╗\033[38;2;200;255;0m╚██████╔\033[38;2;0;229;255m╝ ╚████╔╝ \033[38;2;180;140;255m██║\033[38;2;255;45;85m██║ ╚═╝ ██║\033[0m\n     \033[38;2;255;45;85m╚═╝  ╚═══╝\033[38;2;255;107;0m╚══════╝\033[38;2;200;255;0m ╚═════╝\033[38;2;0;229;255m   ╚═══╝  \033[38;2;180;140;255m╚═╝\033[38;2;255;45;85m╚═╝     ╚═╝\033[0m']],
               height = 6,
               padding = 2,
            },

            -- Right: spacer for visual alignment with header
            {
               pane = 2,
               text = " ",
               padding = 1,
            },

            -- Left: menu keys
            {
               section = "keys",
               gap = 1,
               padding = 1,
            },

            -- Right: recent files
            {
               pane = 2,
               icon = " ",
               title = "Recent Files",
               section = "recent_files",
               indent = 2,
               padding = { 1, 1 },
               limit = 5,
            },

            -- Right: projects
            {
               pane = 2,
               icon = "󰉓 ",
               title = "Projects",
               section = "projects",
               indent = 2,
               padding = { 1, 1 },
               limit = 4,
            },

            -- Right: git status
            {
               pane = 2,
               icon = " ",
               title = "Git Status",
               section = "terminal",
               enabled = function()
                  return Snacks.git.get_root() ~= nil
               end,
               cmd = "echo '' && git status --short --branch --renames",
               height = 6,
               padding = { 1, 1 },
               ttl = 5 * 60,
               indent = 3,
            },

            -- Footer
            { section = "startup" },
         },
      },

      -- Other snacks features
      git = { enabled = true },
      gitbrowse = { enabled = true },
      bigfile = { enabled = true },
      notifier = {
         enabled = true,
         timeout = 3000,
      },
      quickfile = { enabled = true },
      statuscolumn = { enabled = false },
      words = { enabled = true },
      styles = {
         notification = {
            wo = { wrap = true },
         },
      },
   },

   -- ============================================================
   -- KEYMAPS
   -- ============================================================
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

   -- ============================================================
   -- INIT: CGGX highlight groups (must exist BEFORE dashboard renders)
   -- ============================================================
   init = function()
      -- ========================================================
      -- CGGX CYBERPUNK PALETTE
      -- ========================================================
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

      -- Dashboard UI highlight groups
      vim.api.nvim_set_hl(0, "key",                         { fg = c.red,    bold = true })
      vim.api.nvim_set_hl(0, "desc",                        { fg = c.fg })
      vim.api.nvim_set_hl(0, "CGGXIcon",                    { fg = "#ff2d55" })
      vim.api.nvim_set_hl(0, "CGGXFooterText",              { fg = c.lime })
      vim.api.nvim_set_hl(0, "CGGXFooterVal",               { fg = c.orange, bold = true })
      vim.api.nvim_set_hl(0, "CGGXFileIcon",                { fg = "#ff2d55" })
      vim.api.nvim_set_hl(0, "CGGXFile",                    { fg = c.lime })
      vim.api.nvim_set_hl(0, "CGGXDir",                     { fg = c.muted })
      vim.api.nvim_set_hl(0, "SnacksDashboardSpecial",      { fg = c.purple })
      vim.api.nvim_set_hl(0, "SnacksDashboardTitle",        { fg = c.red,    bold = true })

      -- Per-key dashboard colors
      vim.api.nvim_set_hl(0, "CGGXKeyR", { fg = c.red,    bold = true })
      vim.api.nvim_set_hl(0, "CGGXKeyO", { fg = c.orange, bold = true })
      vim.api.nvim_set_hl(0, "CGGXKeyL", { fg = c.lime,   bold = true })
      vim.api.nvim_set_hl(0, "CGGXKeyC", { fg = c.cyan,   bold = true })
      vim.api.nvim_set_hl(0, "CGGXKeyP", { fg = c.purple, bold = true })

      -- ========================================================
      -- TOGGLES + DEBUG (needs Snacks loaded, so defer to VeryLazy)
      -- ========================================================
      vim.api.nvim_create_autocmd("User", {
         pattern = "VeryLazy",
         callback = function()
            _G.dd = function(...)
               Snacks.debug.inspect(...)
            end
            _G.bt = function()
               Snacks.debug.backtrace()
            end
            vim.print = _G.dd

            Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
            Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
            Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>uL")
            Snacks.toggle.diagnostics():map("<leader>ud")
            Snacks.toggle.line_number():map("<leader>ul")
            Snacks.toggle
               .option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 })
               :map("<leader>uc")
            Snacks.toggle.treesitter():map("<leader>uT")
            Snacks.toggle
               .option("background", { off = "light", on = "dark", name = "Dark Background" })
               :map("<leader>ub")
            Snacks.toggle.inlay_hints():map("<leader>uh")
         end,
      })
   end,
}
