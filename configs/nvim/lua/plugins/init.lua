return {
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
  -- Telescope media preview (images, PDFs, video, etc.)
  {
    "nvim-telescope/telescope-media-files.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("telescope").setup({
        extensions = {
          media_files = {
            filetypes = { "png", "webp", "jpg", "jpeg", "gif", "pdf", "mp4", "webm" },
            find_cmd = "rg",
            previewer = "kitty",
          },
        },
      })
      require("telescope").load_extension("media_files")
    end,
  },
}
