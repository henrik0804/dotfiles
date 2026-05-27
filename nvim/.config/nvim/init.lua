-- Force LazyVim to use Neo-tree as the default explorer instead of Snacks Explorer
vim.g.lazyvim_explorer = "neo-tree"

-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
