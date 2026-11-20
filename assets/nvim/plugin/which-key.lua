require("which-key").setup({})
require("which-key").add({
  { "<leader>f", group = "Find" },
  { "<leader>g", group = "Git" },
  { "<leader>o", group = "OpenCode" },
  { "<leader>q", group = "Sessions" },
  { "<leader>u", group = "UI toggles" },
  { "<leader>x", group = "Diagnostics" },
})
