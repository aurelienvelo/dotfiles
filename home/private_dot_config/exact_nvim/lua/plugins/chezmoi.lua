return {
  -- Support de l'édition des fichiers chezmoi (Go templates, .tmpl, etc.)
  {
    -- Ne pas lazy-loader : le plugin doit être chargé avant la détection
    -- du filetype des fichiers .tmpl (cf. README de chezmoi.vim)
    "alker0/chezmoi.vim",
    lazy = false,
    init = function()
      vim.g["chezmoi#use_tmp_buffer"] = true
    end,
  },
}