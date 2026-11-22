local ufo = require("ufo")

ufo.setup({
  provider_selector = function()
    return { "treesitter", "indent" }
  end,
  preview = {
    win_config = { border = "rounded" },
  },
})

vim.keymap.set("n", "zR", ufo.openAllFolds, { desc = "Open all folds" })
vim.keymap.set("n", "zM", ufo.closeAllFolds, { desc = "Close all folds" })
vim.keymap.set("n", "zK", function()
  ufo.peekFoldedLinesUnderCursor()
end, { desc = "Preview folded code" })
