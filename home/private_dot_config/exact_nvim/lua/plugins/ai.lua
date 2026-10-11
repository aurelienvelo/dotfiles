return {
  -- Claude Code (CLI) intégré comme l'extension IDE : même protocole WebSocket
  -- que l'extension VS Code (sélection envoyée comme contexte, diffs rendus
  -- dans Neovim). Le binaire `claude` vient du paquet AUR claude-code.
  -- provider = "native" : terminal intégré de Neovim, pas de dépendance snacks.
  {
    "coder/claudecode.nvim",
    cmd = {
      "ClaudeCode",
      "ClaudeCodeFocus",
      "ClaudeCodeSend",
      "ClaudeCodeAdd",
      "ClaudeCodeTreeAdd",
      "ClaudeCodeSelectModel",
      "ClaudeCodeDiffAccept",
      "ClaudeCodeDiffDeny",
    },
    opts = {
      terminal = {
        provider = "native",
        split_side = "right",
        split_width_percentage = 0.35,
      },
    },
    keys = {
      { "<leader>a", nil, desc = "Claude" },
      { "<leader>ac", "<cmd>ClaudeCode<CR>", desc = "Claude: ouvrir/fermer" },
      { "<leader>af", "<cmd>ClaudeCodeFocus<CR>", desc = "Claude: focus" },
      { "<leader>ar", "<cmd>ClaudeCode --resume<CR>", desc = "Claude: reprendre" },
      { "<leader>am", "<cmd>ClaudeCodeSelectModel<CR>", desc = "Claude: choisir le modèle" },
      -- Envoie la sélection visuelle comme contexte
      { "<leader>as", "<cmd>ClaudeCodeSend<CR>", mode = "v", desc = "Claude: envoyer la sélection" },
      -- Ajoute le fichier sous le curseur (nvim-tree) au contexte
      { "<leader>as", "<cmd>ClaudeCodeTreeAdd<CR>", ft = "NvimTree", desc = "Claude: ajouter le fichier" },
      -- Accepter / refuser un diff proposé par Claude
      { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<CR>", desc = "Claude: accepter le diff" },
      { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<CR>", desc = "Claude: refuser le diff" },
    },
  },
}
