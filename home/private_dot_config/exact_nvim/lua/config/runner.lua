-- Exécution rapide du fichier courant dans un terminal flottant (toggleterm).
-- Pour un vrai pas-à-pas avec points d'arrêt, voir le débogueur (<F5>, plugins/dap.lua).
-- Pour les tâches de projet (make, scripts npm...), lancer un terminal (<leader>tt)
-- ou lazygit (<leader>tl).
local M = {}

-- Python via `uv run` : respecte le venv et les dépendances déclarées dans
-- pyproject.toml, sans activation manuelle. Repli sur l'interpréteur direct
-- hors projet uv.
local function python_cmd(file)
  if vim.fn.filereadable("pyproject.toml") == 1 or vim.fn.isdirectory(".venv") == 1 then
    return "uv run python " .. file
  end
  return "python3 " .. file
end

-- Commande selon le type de fichier
local function build_cmd()
  local file = vim.fn.expand("%:p")
  if file == "" then
    return nil, "Aucun fichier dans ce buffer"
  end
  local q = vim.fn.shellescape(file)
  local ft = vim.bo.filetype
  local by_ft = {
    python = function() return python_cmd(q) end,
    sh = function() return "bash " .. q end,
    bash = function() return "bash " .. q end,
    lua = function() return "lua " .. q end,
    go = function() return "go run " .. q end,
    rust = function() return "cargo run" end,
    javascript = function() return "node " .. q end,
    typescript = function() return "npx --yes tsx " .. q end,
    javascriptreact = function() return "node " .. q end,
    typescriptreact = function() return "npx --yes tsx " .. q end,
  }
  local builder = by_ft[ft]
  if not builder then
    return nil, "Pas de commande d'exécution pour le type : " .. (ft ~= "" and ft or "aucun")
  end
  return builder()
end

function M.run()
  vim.cmd("silent! write")
  local cmd, err = build_cmd()
  if not cmd then
    vim.notify(err, vim.log.levels.WARN)
    return
  end
  local Terminal = require("toggleterm.terminal").Terminal
  -- Terminal jeté puis recréé à chaque exécution : la commande relance à neuf.
  if M._term then
    M._term:shutdown()
  end
  M._term = Terminal:new({
    cmd = cmd,
    direction = "float",
    float_opts = { border = "curved" },
    close_on_exit = false, -- garde la sortie visible après la fin
  })
  M._term:toggle()
end

return M
