return {
  -- Support natif pour l'édition des fichiers chezmoi (Go Templates)
  { "alker0/chezmoi.vim", lazy = false },

  -- Configuration des serveurs LSP via Mason
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "bash-language-server",
        "shellcheck",  -- Linter pour Bash
        "shfmt",       -- Formateur pour Bash
      },
    },
  },
}
