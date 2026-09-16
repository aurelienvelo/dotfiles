return {
  -- Raccourcis contextuels
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      spec = {
        { "<leader>f", group = "Recherche" },
        { "<leader>g", group = "Git" },
        { "<leader>l", group = "LSP" },
        { "<leader>u", group = "UI" },
        { "<leader>s", group = "Splits" },
        { "<leader>t", group = "Terminal/Lazygit" },
        { "<leader>o", group = "OpenCode" },
      },
    },
  },
}