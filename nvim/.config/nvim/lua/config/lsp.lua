local servers = {
  "cssls",
  "html",
  "intelephense",
  "jsonls",
  "lua_ls",
  "tailwindcss",
  "vue_ls",
  "vtsls",
}

require("mason").setup()

vim.diagnostic.config({
  virtual_text = true,
  severity_sort = true,
  float = { source = true },
})

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("lsp", { clear = true }),
  callback = function(event)
    local map = function(lhs, rhs, desc)
      vim.keymap.set("n", lhs, rhs, { buffer = event.buf, desc = desc })
    end
    map("gd", vim.lsp.buf.definition, "Go to definition")
    map("gD", vim.lsp.buf.declaration, "Go to declaration")
  end,
})

vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      runtime = { version = "LuaJIT" },
      workspace = {
        checkThirdParty = false,
        library = { vim.env.VIMRUNTIME },
      },
    },
  },
})

-- Vue hybrid mode: vtsls owns TypeScript in .vue files via the Vue plugin.
local vue_language_server = vim.fn.expand("$MASON/packages/vue-language-server/node_modules/@vue/language-server")
vim.lsp.config("vtsls", {
  filetypes = {
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact",
    "vue",
  },
  settings = {
    vtsls = {
      tsserver = {
        globalPlugins = {
          {
            name = "@vue/typescript-plugin",
            location = vue_language_server,
            languages = { "vue" },
            configNamespace = "typescript",
          },
        },
      },
    },
  },
})

-- Official Laravel LSP is not in the Mason registry.
vim.lsp.config("laravel_lsp", {
  cmd = { "laravel-lsp" },
  filetypes = { "php", "blade" },
  root_dir = function(bufnr, on_dir)
    local root = vim.fs.root(bufnr, "artisan")
    if root then
      on_dir(root)
    end
  end,
})
vim.lsp.enable("laravel_lsp")

require("mason-lspconfig").setup({
  ensure_installed = servers,
})
