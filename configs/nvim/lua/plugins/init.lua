-- Captured in on_yazi_ready (fast-event context: assignments only, no API
-- calls there); used by the ESC-dismiss ModeChanged callback to quit yazi
-- via DDS (ya emit-to <id> quit).
local yazi_dismiss_api

return {
  -- Snappier which-key popup on leader press
  {
    "folke/which-key.nvim",
    keys = { "<leader>", "<c-w>", '"', "'", "`", "c", "v", "V", "g" },
    opts = { delay = 200 },
  },
  -- Quick navigation — jump to any visible character in 2 keystrokes
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {
      modes = {
        char = {
          enabled = true,
          jump_labels = true,
        },
      },
      highlight = { backdrop = false },
      label = { uppercase = false },
    },
    keys = {
      {
        "s",
        mode = { "n", "x", "o" },
        function()
          require("flash").jump()
        end,
        desc = "Flash — jump to anywhere",
      },
      {
        "S",
        mode = { "n", "x", "o" },
        function()
          require("flash").treesitter()
        end,
        desc = "Flash Treesitter — jump to node",
      },
      {
        "r",
        mode = "o",
        function()
          require("flash").remote()
        end,
        desc = "Flash Remote — select jump target then operate",
      },
      {
        "R",
        mode = { "n", "x", "o" },
        function()
          require("flash").treesitter_search()
        end,
        desc = "Flash Treesitter Search — search with Treesitter scope",
      },
      {
        "<leader>s",
        mode = { "n", "x", "o" },
        function()
          require("flash").toggle()
        end,
        desc = "Toggle Flash search highlight",
      },
    },
  },

  {
    "stevearc/conform.nvim",
    -- event = 'BufWritePre', -- uncomment for format on save
    opts = require "configs.conform",
  },

  -- These are some examples, uncomment them if you want to see them work!
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },

  -- test new blink
  -- { import = "nvchad.blink.lazyspec" },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "vim", "lua", "vimdoc",
        "html", "css",
        "go",
      },
    },
  },
  -- telescope image preview patched in cggx.lua (buffer_previewer_maker override)

  -- Yazi: floating file manager (replaces nvim-tree)
  -- Disable nvim-tree from NvChad's default plugins
  { "nvim-tree/nvim-tree.lua", enabled = false },
  {
    "mikavilpas/yazi.nvim",
    version = "*",
    event = "VeryLazy",
    dependencies = {
      { "nvim-lua/plenary.nvim", lazy = true },
    },
    ---@type YaziConfig | {}
    opts = {
      yazi_floating_window_border = "single",
      keymaps = {
        show_help = "<f1>",
      },
      hooks = {
        -- on_yazi_ready fires inside a FAST EVENT context (vim.system
        -- callback): only capture the api here, no API calls allowed.
        on_yazi_ready = function(_, _, process_api)
          yazi_dismiss_api = process_api
        end,
        -- ESC dismisses yazi: Lua callback mappings don't fire in terminal
        -- mode, so use the documented string-RHS form (tnoremap <Esc>
        -- <C-\><C-N>) to exit terminal mode; the ModeChanged autocmd then
        -- tells yazi to quit via DDS (ya emit-to <id> quit) - clean exit 0,
        -- works even with a custom-shell subshell open, doesn't type into
        -- the terminal, skips autosession save (right for a dismiss). If
        -- yazi hasn't exited within 1.5s, hard-kill the job and delete the
        -- buffer. Also covers <C-\><C-N> pressed directly.
        yazi_opened = function(_, buf)
          vim.keymap.set("t", "<Esc>", [[<C-\><C-N>]], {
            buffer = buf,
            desc = "Exit terminal mode (dismiss yazi)",
          })
          vim.api.nvim_create_autocmd("ModeChanged", {
            buffer = buf,
            callback = function()
              local ev = vim.v.event
              -- dismiss ONLY on the explicit terminal -> terminal-normal
              -- transition (ESC via the <C-\><C-N> mapping, or <C-\><C-N>
              -- directly). The t -> n transition happens when switching
              -- windows and must NOT dismiss ("closes by itself").
              if ev.old_mode == "t" and (ev.new_mode == "tn" or ev.new_mode == "nt") then
                if yazi_dismiss_api then
                  pcall(yazi_dismiss_api.emit_to_yazi, yazi_dismiss_api, { "quit" })
                end
                vim.defer_fn(function()
                  if vim.api.nvim_buf_is_valid(buf) then
                    local chan = vim.bo[buf].channel
                    if chan and chan > 0 then
                      vim.fn.jobstop(chan)
                    end
                    pcall(vim.api.nvim_buf_delete, buf, { force = true })
                  end
                end, 1500)
              end
            end,
          })
        end,
      },
    },
  },

}

