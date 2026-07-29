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

  -- NvimTree: Yazi-like icon colors and git on filenames
  {
    "nvim-tree/nvim-tree.lua",
    opts = function()
      local config = require "nvchad.configs.nvimtree"
      config.renderer.highlight_git = "name"
      config.renderer.icons = config.renderer.icons or {}
      config.renderer.icons.web_devicons = {
        file = { enable = true, color = true },
        folder = { enable = true, color = true },
      }
      return config
    end,
  },

}

