return {
  -- Signes git dans la gouttière
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      signs = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "▎" },
        topdelete = { text = "▎" },
        changedelete = { text = "▎" },
      },
      on_attach = function(bufnr)
        local map = function(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
        end
        map("n", "]h", function()
          if vim.wo.diff then return "]" end
          vim.schedule(function() require("gitsigns").next_hunk() end)
          return "<Ignore>"
        end, "Hunk suivant")
        map("n", "[h", function()
          if vim.wo.diff then return "[" end
          vim.schedule(function() require("gitsigns").prev_hunk() end)
          return "<Ignore>"
        end, "Hunk précédent")
        map("n", "<leader>gb", require("gitsigns").blame_line, "Blame")
        map("n", "<leader>gp", require("gitsigns").preview_hunk, "Aperçu hunk")
        map("n", "<leader>gr", require("gitsigns").reset_hunk, "Annuler hunk")
      end,
    },
  },

  -- Terminal intégré + lazygit en flottant
  {
    "akinsho/toggleterm.nvim",
    cmd = { "ToggleTerm" },
    config = function()
      require("toggleterm").setup({
        open_mapping = "<leader>`",
        direction = "horizontal",
        size = 12,
        float_opts = { border = "curved" },
      })
      local Terminal = require("toggleterm.terminal").Terminal
      _G.toggle_lazygit = function()
        Terminal:new({ cmd = "lazygit", direction = "float", hidden = true }):toggle()
      end
    end,
    keys = {
      { "<leader>tl", "<cmd>lua toggle_lazygit()<CR>", desc = "Lazygit" },
      { "<leader>tt", "<cmd>ToggleTerm<CR>", desc = "Terminal" },
    },
  },
}