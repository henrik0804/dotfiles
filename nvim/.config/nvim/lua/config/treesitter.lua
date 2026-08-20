local parsers = {
  "bash",
  "blade",
  "css",
  "dockerfile",
  "gitcommit",
  "gitignore",
  "html",
  "javascript",
  "jsdoc",
  "json",
  "lua",
  "luadoc",
  "markdown",
  "markdown_inline",
  "php",
  "php_only",
  "phpdoc",
  "query",
  "regex",
  "sql",
  "toml",
  "tsx",
  "typescript",
  "vim",
  "vimdoc",
  "vue",
  "yaml",
}

local ts = require("nvim-treesitter")
local installed = require("nvim-treesitter.config").get_installed()
local missing = vim.tbl_filter(function(parser)
  return not vim.tbl_contains(installed, parser)
end, parsers)
if #missing > 0 then
  ts.install(missing):wait(5 * 60 * 1000)
end

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("treesitter", { clear = true }),
  callback = function(event)
    if not pcall(vim.treesitter.start) then
      return
    end
    vim.bo[event.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  end,
})
