-- ── CGGX Neovim ──────────────────────
-- Uses catppuccin as base, overrides palette

require("catppuccin").setup({
  color_overrides = {
    mocha = {
      base        = "#0a0a0c",
      mantle      = "#111115",
      crust       = "#0d0d10",
      text        = "#e8e8f0",
      subtext1    = "#9090a8",
      subtext0    = "#6a6a80",
      red         = "#ff2d55",
      green       = "#c8ff00",
      yellow      = "#ff6b00",
      blue        = "#00e5ff",
      mauve       = "#b48cff",
      peach       = "#ff6b00",
    }
  },
  integrations = {
    cmp        = true,
    treesitter = true,
    telescope  = { enabled = true },
  }
})
vim.cmd.colorscheme "catppuccin-mocha"

-- Status line accent
vim.api.nvim_set_hl(0,"StatusLine",{
  bg="#ff2d55", fg="#0a0a0c", bold=true
})