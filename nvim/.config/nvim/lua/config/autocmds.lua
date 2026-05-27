-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

local single_file_group = vim.api.nvim_create_augroup("single_file_mode", { clear = true })

vim.api.nvim_create_autocmd("BufEnter", {
  group = single_file_group,
  callback = function(args)
    local current = args.buf

    if vim.bo[current].buftype ~= "" or not vim.bo[current].buflisted then
      return
    end

    vim.schedule(function()
      if not vim.api.nvim_buf_is_valid(current) then
        return
      end

      local current_win = vim.api.nvim_get_current_win()

      for _, win in ipairs(vim.api.nvim_list_wins()) do
        if win ~= current_win then
          local buf = vim.api.nvim_win_get_buf(win)
          if vim.bo[buf].buftype == "" then
            pcall(vim.api.nvim_win_close, win, true)
          end
        end
      end

      for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
        if tab ~= vim.api.nvim_get_current_tabpage() then
          pcall(vim.api.nvim_tabpage_close, tab, true)
        end
      end

      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if buf ~= current and vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buflisted and vim.bo[buf].buftype == "" then
          pcall(vim.api.nvim_buf_delete, buf, { force = true })
        end
      end
    end)
  end,
})
