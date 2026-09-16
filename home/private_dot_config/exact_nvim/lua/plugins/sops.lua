return {
  -- Édition transparente des fichiers chiffrés SOPS
  {
    "lemarsu/sops.nvim",
    cmd = "Sops",
    config = function()
      local config = require("sops.config")
      config.binary = "sops"
    end,
    keys = {
      { "<leader>se", "<cmd>Sops toggle<CR>", desc = "Sops: éditer/déverrouiller" },
      { "<leader>sc", "<cmd>Sops close<CR>", desc = "Sops: verrouiller" },
    },
  },
}