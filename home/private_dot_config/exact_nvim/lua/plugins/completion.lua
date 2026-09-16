return {
  -- Complétion moderne et rapide
  {
    "saghen/blink.cmp",
    version = "v0.*",
    event = { "InsertEnter", "CmdlineEnter" },
    dependencies = {
      "rafamadriz/friendly-snippets",
    },
    opts = {
      keymap = {
        preset = "default",
        ["<C-n>"] = { "select_next", "fallback" },
        ["<C-p>"] = { "select_prev", "fallback" },
        ["<C-space>"] = { "show", "fallback" },
        ["<C-e>"] = { "hide", "fallback" },
        ["<CR>"] = { "accept", "fallback" },
        ["<Tab>"] = { "snippet_forward", "fallback" },
        ["<S-Tab>"] = { "snippet_backward", "fallback" },
      },
      sources = {
        default = { "lsp", "snippets", "path", "buffer" },
        providers = {
          path = { score_offset = 3 },
          snippets = { score_offset = 2 },
        },
      },
      completion = {
        documentation = { auto_show = true, window = { border = "rounded" } },
        menu = { border = "rounded", scrollbar = true },
      },
      signature = { enabled = true, window = { border = "rounded" } },
      appearance = { use_nvim_cmp_as_default = false, nerd_font_variant = "mono" },
    },
  },
}