local opt = vim.opt

vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- netrw désactivé (remplacé par nvim-tree)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Apparence
opt.number = true
opt.relativenumber = true
opt.mouse = "a"
opt.termguicolors = true
opt.signcolumn = "auto:2"
opt.laststatus = 3
opt.showmode = false
opt.ruler = false
opt.foldlevel = 99
opt.foldlevelstart = 99

-- Recherche
opt.hlsearch = true
opt.incsearch = true
opt.ignorecase = true
opt.smartcase = true

-- Édition
opt.expandtab = true
opt.shiftwidth = 4
opt.tabstop = 4
opt.softtabstop = 4
opt.smartindent = true
opt.autoindent = true
opt.wrap = false
opt.linebreak = true
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.splitright = true
opt.splitbelow = true

-- Buffers / fichiers
opt.swapfile = false
opt.undofile = true
opt.undodir = vim.fn.stdpath("data") .. "/undodir"
vim.fn.system({ "mkdir", "-p", opt.undodir.value })

-- Presse-papiers
opt.clipboard = "unnamedplus"

-- Complétion / UI
opt.updatetime = 250
opt.timeoutlen = 300
opt.completeopt = "menu,menuone,noselect"
opt.pumheight = 12

-- Encodage
opt.encoding = "utf-8"
opt.fileencoding = "utf-8"

-- Performance
opt.lazyredraw = true
opt.synmaxcol = 200