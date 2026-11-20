require("which-key").setup({})

local groups = {}
for key, group in pairs(require("dotfiles.settings").whichKeyGroups) do
  groups[#groups + 1] = { "<leader>" .. key, group = group }
end
require("which-key").add(groups)
