return {
  -- Arborescence de fichiers
  {
    "nvim-tree/nvim-tree.lua",
    cmd = { "NvimTreeToggle", "NvimTreeFocus", "NvimTreeFindFile" },
    keys = {
      { "<leader>e", "<cmd>NvimTreeToggle<CR>", desc = "Explorer : bascule" },
      { "<leader>E", "<cmd>NvimTreeFindFile<CR>", desc = "Explorer : fichier courant" },
      { "<C-n>", "<cmd>NvimTreeToggle<CR>", desc = "Explorer : bascule", mode = { "n", "v" } },
    },
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      disable_netrw = true,
      hijack_netrw = true,
      sync_root_with_cwd = true,
      respect_buffer_visible = true,
      update_focused_file = { enable = true, update_root = { enable = false } },
      filters = { dotfiles = false },
      renderer = {
        group_empty = true,
        root_folder_label = false,
        icons = { show = { file = true, folder = true } },
      },
      view = {
        width = 36,
        side = "left",
        preserve_window_proportions = true,
      },
      actions = { open_file = { quit_on_open = true } },
      git = { enable = true },
    },
  },
}