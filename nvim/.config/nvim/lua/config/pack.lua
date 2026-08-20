local gh = function(repo)
  return "https://github.com/" .. repo
end

-- Hooks must exist before the first vim.pack.add() so lockfile installs run them.
vim.api.nvim_create_autocmd("PackChanged", {
  group = vim.api.nvim_create_augroup("pack-changed", { clear = true }),
  callback = function(event)
    local spec, kind = event.data.spec, event.data.kind
    if spec.name == "nvim-treesitter" and (kind == "install" or kind == "update") then
      if not event.data.active then
        vim.cmd.packadd("nvim-treesitter")
      end
      vim.cmd.TSUpdate()
    end
  end,
})

vim.pack.add({
  { src = gh("rose-pine/neovim"), name = "rose-pine" },
  { src = gh("nvim-treesitter/nvim-treesitter"), version = "main" },
  gh("mason-org/mason.nvim"),
  gh("neovim/nvim-lspconfig"),
  gh("mason-org/mason-lspconfig.nvim"),
  gh("nvim-lua/plenary.nvim"),
  gh("nvim-telescope/telescope.nvim"),
  gh("folke/which-key.nvim"),
  gh("rafamadriz/friendly-snippets"),
  { src = gh("saghen/blink.cmp"), version = vim.version.range("^1") },
}, { confirm = false })
