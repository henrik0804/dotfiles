local function has_phpstan_config(ctx)
  local filename = ctx and ctx.filename or vim.api.nvim_buf_get_name(0)
  return vim.fs.find({ "phpstan.neon", "phpstan.neon.dist", "phpstan.dist.neon" }, {
    path = filename,
    upward = true,
  })[1] ~= nil
end

return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "php", "blade" })
    end,
  },

  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        phpactor = {},
      },
    },
  },

  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "phpactor", "pint", "phpstan" })
    end,
  },

  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters_by_ft = {
        php = { "pint" },
      },
    },
  },

  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = {
      linters_by_ft = {
        php = { "phpstan" },
      },
      linters = {
        phpstan = {
          condition = function(ctx)
            return has_phpstan_config(ctx)
          end,
        },
      },
    },
  },
}
