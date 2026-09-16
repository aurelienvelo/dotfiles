return {
  -- Intégration de l'assistant opencode (CLI)
  {
    "nickjvandyke/opencode.nvim",
    version = "*",
    keys = {
      { "<leader>oa", function() require("opencode").ask("@this: ") end, desc = "OpenCode: ask" },
      { "<leader>oc", function() require("opencode").select() end, desc = "OpenCode: select" },
    },
    config = function()
      vim.g.opencode_opts = {}
      vim.keymap.set({ "n", "x" }, "go", function()
        return require("opencode").operator("@this ")
      end, { desc = "OpenCode: append", expr = true })
      vim.keymap.set({ "n" }, "goo", function()
        return require("opencode").operator("@this ") .. "_"
      end, { desc = "OpenCode: append line", expr = true })
    end,
  },
}