local map = vim.keymap.set
local nopts = { noremap = true, silent = true }

-- Général
map("n", "<leader>w", "<cmd>write<CR>", { desc = "Enregistrer" })
map("n", "<leader>q", "<cmd>quit<CR>", { desc = "Quitter" })
map("n", "<leader><space>", "<cmd>noh<CR>", { desc = "Effacer la recherche" })

-- Insertion / édition
map("i", "jj", "<Esc>", nopts)
map("n", "<A-j>", "<cmd>m .+1<CR>==", nopts)
map("n", "<A-k>", "<cmd>m .-2<CR>==", nopts)
map("x", "<A-j>", ":m '>+1<CR>gv=gv", nopts)
map("x", "<A-k>", ":m '<-2<CR>gv=gv", nopts)

-- Splits
map("n", "<leader>s|", "<cmd>vsplit<CR>", { desc = "Split vertical" })
map("n", "<leader>s-", "<cmd>split<CR>", { desc = "Split horizontal" })

-- Arborescence (nvim-tree)
map("n", "<leader>u", "<cmd>NvimTreeToggle<CR>", { desc = "Basculer l'arborescence" })
map("n", "<leader>uf", "<cmd>NvimTreeFindFile<CR>", { desc = "Révéler le fichier" })

-- Recherche floue (fzf-lua)
map("n", "<leader>ff", "<cmd>FzfLua files<CR>", { desc = "Fichiers" })
map("n", "<leader>fg", "<cmd>FzfLua live_grep<CR>", { desc = "Grep en direct" })
map("n", "<leader>fb", "<cmd>FzfLua buffers<CR>", { desc = "Buffers" })
map("n", "<leader>fr", "<cmd>FzfLua lsp_references<CR>", { desc = "Références LSP" })
map("n", "<leader>fh", "<cmd>FzfLua helptags<CR>", { desc = "Tags d'aide" })
map("n", "<leader>fd", "<cmd>FzfLua lsp_document_symbols<CR>", { desc = "Symboles" })
map("v", "<leader>fs", "<cmd>FzfLua grep_visual<CR>", { desc = "Grep sur la sélection" })