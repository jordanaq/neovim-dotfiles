local settings = require("dotfiles.settings")

for name, value in pairs(settings.editor.globals) do
  vim.g[name] = value
end
for name, value in pairs(settings.editor.options) do
  vim.o[name] = value
end

vim.cmd.colorscheme(settings.colorscheme)
vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", { noremap = true, silent = true })

-- Save gutter options per window so toggling never changes other splits.
vim.keymap.set("n", "<leader>un", function()
  local saved = vim.w._saved_gutter_options
  if saved then
    vim.wo.number = saved.number
    vim.wo.relativenumber = saved.relativenumber
    vim.wo.foldcolumn = saved.foldcolumn
    vim.w._saved_gutter_options = nil
  else
    vim.w._saved_gutter_options = {
      number = vim.wo.number,
      relativenumber = vim.wo.relativenumber,
      foldcolumn = vim.wo.foldcolumn,
    }
    vim.wo.number = false
    vim.wo.relativenumber = false
    vim.wo.foldcolumn = "0"
  end
end, { desc = "Toggle line numbers and fold gutter (current window)" })

vim.cmd("filetype plugin indent on")
vim.cmd("syntax enable")
vim.filetype.add(settings.editor.filetypes)

vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.hl.on_yank(settings.editor.yankHighlight)
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = settings.editor.cIndent.filetypes,
  callback = function(event)
    for name, value in pairs(settings.editor.cIndent.options) do
      vim.bo[event.buf][name] = value
    end
  end,
})
