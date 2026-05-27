-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Toggle file tree with cmd+o.
-- In terminal Neovim, Ghostty maps cmd+o -> alt+o, so support both.
vim.keymap.set("n", "<D-o>", "<cmd>Neotree toggle<cr>", { desc = "Toggle file tree" })
vim.keymap.set("n", "<M-o>", "<cmd>Neotree toggle<cr>", { desc = "Toggle file tree" })

-- Show the full diagnostic message under the cursor.
vim.keymap.set("n", "gl", function()
  vim.diagnostic.open_float(nil, {
    focus = false,
    border = "rounded",
    scope = "line",
  })
end, { desc = "Line diagnostics" })
