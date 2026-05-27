-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Disable netrw so Neo-tree is the only file explorer when opening directories
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Single tab only - prevent multiple tabs
vim.opt.tabpagemax = 1
vim.opt.showtabline = 0 -- Never show tabline
