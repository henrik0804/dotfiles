local function move_to_level_edge(state, edge)
  local renderer = require("neo-tree.ui.renderer")
  local node = state.tree:get_node()
  if not node then
    return
  end

  local siblings = state.tree:get_nodes(node:get_parent_id())
  if not siblings or #siblings == 0 then
    return
  end

  local target = edge == "first" and siblings[1] or siblings[#siblings]
  if target then
    renderer.focus_node(state, target:get_id())
  end
end

local function open_keep_focus(state)
  local winid = state.winid
  require("neo-tree.sources.filesystem.commands").open(state)
  vim.schedule(function()
    if vim.api.nvim_win_is_valid(winid) then
      vim.api.nvim_set_current_win(winid)
    end
  end)
end

return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = {
    filesystem = {
      filtered_items = {
        visible = true,
        hide_dotfiles = false,
        hide_gitignored = false,
      },
      window = {
        mappings = {
          ["j"] = function()
            vim.cmd("normal! j")
          end,
          ["k"] = function()
            vim.cmd("normal! k")
          end,
          ["J"] = {
            function(state)
              move_to_level_edge(state, "last")
            end,
            desc = "Jump to last item on this level",
          },
          ["K"] = {
            function(state)
              move_to_level_edge(state, "first")
            end,
            desc = "Jump to first item on this level",
          },
          ["o"] = { "open", nowait = true },
          ["oc"] = "noop",
          ["od"] = "noop",
          ["og"] = "noop",
          ["om"] = "noop",
          ["on"] = "noop",
          ["os"] = "noop",
          ["ot"] = "noop",
          ["O"] = {
            open_keep_focus,
            desc = "Open without leaving the tree",
            nowait = true,
          },
        },
      },
    },
  },
}
