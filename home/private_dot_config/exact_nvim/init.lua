--
-- init.lua — point d'entrée Neovim (vanilla + lazy.nvim)
--
vim.loader.enable()

require("config.options")
require("config.keymaps")
require("config.autocmds")
require("config.lazy")