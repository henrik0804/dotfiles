require("which-key").setup()

require("which-key").add({
  { "<leader>s", group = "Search" },
  { "<leader>g", group = "Git" },
  {
    "<leader>?",
    function()
      require("which-key").show({ global = false })
    end,
    desc = "Buffer keymaps",
  },
})
