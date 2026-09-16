return {
  -- Recherche floue basée sur le binaire fzf (rapide)
  {
    "ibhagwan/fzf-lua",
    cmd = {
      "FzfLua",
      "FzfLuaFiles",
      "FzfLuaLiveGrep",
      "FzfLuaBuffers",
      "FzfLuaLspReferences",
      "FzfLuaLspDocumentSymbols",
      "FzfLuaGrepVisual",
    },
    opts = {
      winopts = {
        height = 0.85,
        width = 0.85,
        preview = { default = "bat --color=always --style=numbers --line-range=:500 {}" },
      },
      fzf_opts = { ["--layout"] = "reverse", ["--border"] = "rounded" },
    },
    config = function(_, opts)
      if vim.fn.executable("bat") == 1 then
        opts.winopts = vim.tbl_deep_extend("force", opts.winopts or {}, {
          preview = { default = "bat --color=always --style=numbers --line-range=:500 {}" },
        })
      end
      require("fzf-lua").setup(opts)
    end,
  },
}