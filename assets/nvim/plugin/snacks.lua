require("snacks").setup(require("dotfiles.settings").snacks)

-- Remember the most recently focused editing window. Explorer is a sidebar,
-- so opening a file from it should replace the buffer in that editor window.
local last_editor_win

local function is_editor_window(win)
  if not win or not vim.api.nvim_win_is_valid(win) then
    return false
  end
  if vim.api.nvim_win_get_tabpage(win) ~= vim.api.nvim_get_current_tabpage() then
    return false
  end
  if vim.api.nvim_win_get_config(win).relative ~= "" or vim.w[win].snacks_layout then
    return false
  end
  return vim.bo[vim.api.nvim_win_get_buf(win)].buftype == ""
end

local function remember_editor_window()
  local win = vim.api.nvim_get_current_win()
  if is_editor_window(win) then
    last_editor_win = win
  end
end

vim.api.nvim_create_autocmd("WinEnter", { callback = remember_editor_window })
remember_editor_window()

local function explorer_confirm(picker, item, action)
  -- Leave directory expansion and search-mode confirmations to Explorer.
  if item and not item.dir and not picker.input.filter.meta.searching and is_editor_window(last_editor_win) then
    picker.main = last_editor_win
  end
  require("snacks.explorer.actions").actions.confirm(picker, item, action)
end

local map = function(keys, fn, desc)
  vim.keymap.set("n", keys, fn, { desc = desc })
end

map("<leader>e", function()
  remember_editor_window()
  Snacks.explorer({
    actions = { open_in_last_editor = explorer_confirm },
    win = {
      list = { keys = { ["<CR>"] = "open_in_last_editor", l = "open_in_last_editor" } },
      input = { keys = { ["<CR>"] = "open_in_last_editor" } },
    },
  })
end, "File explorer")
map("<leader>ff", function() Snacks.picker.files() end, "Find files")
map("<leader>fg", function() Snacks.picker.grep() end, "Search project text")
map("<leader>fb", function() Snacks.picker.buffers() end, "Find buffers")
map("<leader>fh", function() Snacks.picker.help() end, "Find help")
