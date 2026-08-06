require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

-- Replace NvChad's nvim-tree bindings (plugin removed) with yazi.nvim
-- YAZI_NO_SESSION=1 skips autosession.yazi restore (same trick as
-- termfilechooser-wrapper.sh), so <leader>e opens a FRESH yazi with the
-- current file hovered/selected (passing the file as the entry makes yazi
-- open its parent dir and select it). Falls back to nvim's cwd for
-- scratch/non-file buffers. jobstart merges the env dict over nvim's
-- environment, so the var survives into the yazi process.
map("n", "<leader>e", function()
  local file = vim.fn.expand "%:p"
  if file == "" or vim.bo.buftype ~= "" or vim.fn.filereadable(file) == 0 then
    file = vim.fn.getcwd()
  end
  vim.env.YAZI_NO_SESSION = "1"
  require("yazi").yazi(nil, file)
  vim.env.YAZI_NO_SESSION = nil
end, { desc = "yazi" })
map("n", "<C-n>", "<cmd>Yazi toggle<cr>", { desc = "Toggle yazi" })

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
-- Override NvChad's <leader>cm to use file's directory (avoids "not a git directory" error)
map("n", "<leader>cm", function()
  require("telescope.builtin").git_commits({ cwd = vim.fn.expand("%:p:h") })
end, { desc = "telescope git commits (from file dir)" })

map("n", "<leader>fW", function()
  require("telescope.builtin").live_grep({ hidden = true })
end, { desc = "live grep (incl. hidden)" })


map("n", "<leader>cp", function()
  vim.fn.setreg("+", vim.fn.expand("%:p"))
end, { desc = "Copy full file path" })
