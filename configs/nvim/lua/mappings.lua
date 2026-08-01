require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

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
