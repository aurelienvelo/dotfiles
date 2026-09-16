return {
  -- Intégration de l'assistant opencode (CLI)
  {
    "opencode-ai/opencode.nvim",
    cmd = { "OpenCode", "OpenCodeChat" },
    keys = {
      { "<leader>oa", "<cmd>OpenCodeChat<CR>", desc = "OpenCode: chat" },
      { "<leader>oc", "<cmd>OpenCode<CR>", desc = "OpenCode: assistant" },
    },
    config = function()
      local ok, opencode = pcall(require, "opencode")
      if ok then
        opencode.setup({})
      end
    end,
  },
}