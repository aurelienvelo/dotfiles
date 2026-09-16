return {
  -- Syntax highlighting via tree-sitter
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPre", "BufNewFile" },
    main = "nvim-treesitter.configs",
    opts = {
      ensure_installed = {
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
      },
      highlight = { enable = true },
      indent = { enable = true },
    },
  },
}