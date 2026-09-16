return {
  -- Formatage à la sauvegarde
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        python = { "ruff_fix", "ruff_format" },
        sh = { "shfmt" },
        bash = { "shfmt" },
        yaml = { "yamlfmt" },
        go = { "gofmt" },
        rust = { "rustfmt" },
        ["*"] = { "trim_whitespace" },
      },
      format_on_save = { timeout_ms = 1500, lsp_fallback = true },
    },
  },

  -- Linting à la sauvegarde
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("nvim-lint").linters_by_ft = {
        bash = { "shellcheck" },
        sh = { "shellcheck" },
        lua = { "luacheck" },
      }
      vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
        callback = function()
          require("nvim-lint").try_lint()
        end,
      })
    end,
  },
}