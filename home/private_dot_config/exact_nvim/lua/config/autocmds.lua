local aug = vim.api.nvim_create_augroup("UserConfig", { clear = true })

-- Retour au dernier emplacement de curseur
vim.api.nvim_create_autocmd("BufReadPost", {
  group = aug,
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local count = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= count then
      pcall(vim.api.nvim_win_set_cursor, 0, { mark[1], mark[2] })
    end
  end,
})

-- Wrap pour les formats texte
vim.api.nvim_create_autocmd({ "FileType" }, {
  group = aug,
  pattern = { "markdown", "text", "gitcommit", "tex" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = false
  end,
})

-- Re-sélection après indentation (mode visuel)
vim.api.nvim_create_autocmd("FileType", {
  group = aug,
  callback = function()
    vim.api.nvim_buf_set_keymap(0, "v", "<", "<gv", { noremap = true })
    vim.api.nvim_buf_set_keymap(0, "v", ">", ">gv", { noremap = true })
  end,
})

-- YAML : abréviation para défaut 2 espaces
vim.api.nvim_create_autocmd("FileType", {
  group = aug,
  pattern = { "yaml", "yml" },
  callback = function()
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop = 2
    vim.opt_local.softtabstop = 2
  end,
})