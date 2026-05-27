return {
  {
    "adalessa/laravel.nvim",
    ft = { "php", "blade" },
    event = { "BufEnter composer.json" },
    dependencies = {
      "MunifTanjim/nui.nvim",
      "nvim-lua/plenary.nvim",
      "nvim-neotest/nvim-nio",
      "saghen/blink.compat",
    },
    keys = {
      { "<leader>ll", function() Laravel.pickers.laravel() end, desc = "Laravel Picker" },
      { "<leader>la", function() Laravel.pickers.artisan() end, desc = "Laravel Artisan" },
      { "<leader>lr", function() Laravel.pickers.routes() end, desc = "Laravel Routes" },
      { "<leader>lm", function() Laravel.pickers.make() end, desc = "Laravel Make" },
      { "<leader>lc", function() Laravel.pickers.commands() end, desc = "Laravel Commands" },
      { "<leader>lo", function() Laravel.pickers.resources() end, desc = "Laravel Resources" },
      { "<leader>lt", function() Laravel.commands.run("actions") end, desc = "Laravel Actions" },
      { "<leader>lu", function() Laravel.commands.run("hub") end, desc = "Laravel Hub" },
      {
        "gf",
        function()
          local ok, res = pcall(function()
            if Laravel.app("gf").cursorOnResource() then
              return "<cmd>lua Laravel.commands.run('gf')<cr>"
            end
          end)
          if not ok or not res then
            return "gf"
          end
          return res
        end,
        expr = true,
        noremap = true,
        desc = "Laravel goto file",
      },
    },
    opts = {
      lsp_server = "phpactor",
      eloquent_generate_doc_blocks = false,
      features = {
        pickers = {
          enable = true,
          provider = "snacks",
        },
      },
      extensions = {
        diagnostic = {
          enable = false,
        },
        route_info = {
          enable = true,
          view = "top",
        },
        model_info = {
          enable = false,
        },
        override = {
          enable = false,
        },
      },
    },
    config = true,
  },
  {
    "saghen/blink.cmp",
    optional = true,
    dependencies = { "saghen/blink.compat" },
    opts = function(_, opts)
      opts.sources = opts.sources or {}
      opts.sources.compat = opts.sources.compat or {}
      if not vim.tbl_contains(opts.sources.compat, "laravel") then
        table.insert(opts.sources.compat, "laravel")
      end
      opts.sources.providers = opts.sources.providers or {}
      opts.sources.providers.laravel = vim.tbl_deep_extend("force", opts.sources.providers.laravel or {}, {
        name = "laravel",
        module = "blink.compat.source",
        score_offset = 95,
      })
    end,
  },
}
