-- Henrik's Neovim config
-- Built incrementally. No LazyVim.

vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.o.number = true
vim.o.relativenumber = true
vim.o.mouse = "a"
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.expandtab = true
vim.o.shiftwidth = 2
vim.o.tabstop = 2
vim.o.undofile = true
vim.o.termguicolors = true
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.signcolumn = "yes"
vim.o.clipboard = "unnamedplus"
vim.o.winborder = "rounded"

vim.filetype.add({
  pattern = {
    [".*%.blade%.php"] = "blade",
  },
})

vim.keymap.set("n", "<leader>w", "<cmd>write<cr>", { desc = "Write file" })
vim.keymap.set("n", "<esc>", "<cmd>nohlsearch<cr>")

vim.api.nvim_create_autocmd("FileType", {
  pattern = "qf",
  callback = function(event)
    vim.keymap.set("n", "<CR>", "<CR><Cmd>cclose<CR>", {
      buffer = event.buf,
      silent = true,
      desc = "Jump and close quickfix",
    })
  end,
})

require("config.pack")
require("config.colorscheme")
require("config.treesitter")
require("config.which-key")
require("config.completion")
require("config.lsp")
require("config.telescope")
