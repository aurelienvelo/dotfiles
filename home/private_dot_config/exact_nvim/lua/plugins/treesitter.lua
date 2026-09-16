return {
  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    build = function()
      return require("nvim-treesitter").install({
        "bash",
        "lua",
        "vim",
        "vimdoc",
        "python",
        "typescript",
        "javascript",
        "json",
        "yaml",
        "toml",
        "go",
        "rust",
        "markdown",
        "markdown_inline",
        "fish",
        "diff",
        "gitcommit",
        "dockerfile",
      }):wait(300000)
    end,
    config = function()
      require("nvim-treesitter").setup({})
      vim.api.nvim_create_autocmd("FileType", {
        callback = function()
          if pcall(vim.treesitter.start) then
            vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })
    end,
  },
}