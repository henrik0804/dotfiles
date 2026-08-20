require("telescope").setup({})

local builtin = require("telescope.builtin")

local recent_files = function()
  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local make_entry = require("telescope.make_entry")

  local current = vim.api.nvim_buf_get_name(0)
  local cwd = vim.uv.cwd() or ""
  if cwd:sub(-1) ~= "/" then
    cwd = cwd .. "/"
  end

  local seen, results = {}, {}
  local add = function(file)
    if file == "" or seen[file] or not vim.uv.fs_stat(file) then
      return
    end
    if file:sub(1, #cwd) ~= cwd then
      return
    end
    seen[file] = true
    table.insert(results, file)
  end

  add(current)

  local bufs = vim.fn.getbufinfo({ buflisted = 1 })
  table.sort(bufs, function(a, b)
    return a.lastused > b.lastused
  end)
  for _, info in ipairs(bufs) do
    add(info.name)
  end
  for _, file in ipairs(vim.v.oldfiles) do
    add(file)
  end

  pickers
    .new({}, {
      prompt_title = "Recent files",
      finder = finders.new_table({
        results = results,
        entry_maker = make_entry.gen_from_file({}),
      }),
      sorter = conf.file_sorter({}),
      previewer = conf.file_previewer({}),
      default_selection_index = (current ~= "" and #results >= 2) and 2 or 1,
    })
    :find()
end

vim.keymap.set("n", "<leader><leader>", builtin.find_files, { desc = "Find files" })
vim.keymap.set("n", "<leader>/", builtin.live_grep, { desc = "Search in files" })
vim.keymap.set("n", "<leader>e", recent_files, { desc = "Recent files" })
vim.keymap.set("n", "<leader>ss", builtin.lsp_document_symbols, { desc = "Document symbols" })
vim.keymap.set("n", "<leader>sw", builtin.lsp_dynamic_workspace_symbols, { desc = "Workspace symbols" })
vim.keymap.set("n", "<leader>sd", builtin.diagnostics, { desc = "Diagnostics" })
vim.keymap.set("n", "<leader>gs", builtin.git_status, { desc = "Git status" })
