-- LSP via l'API native de Neovim 0.11+ (vim.lsp.config / vim.lsp.enable).
-- mason-lspconfig v2 n'a plus d'option `handlers` : il installe les serveurs
-- (ensure_installed) puis les active automatiquement (automatic_enable). La
-- configuration se fait donc avec vim.lsp.config, et les raccourcis dans
-- LspAttach.

local function on_attach(args)
  local bufnr = args.buf
  local client = vim.lsp.get_client_by_id(args.data.client_id)
  local function map(lhs, rhs, desc)
    vim.keymap.set("n", lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
  end
  -- Déjà fournis par Neovim 0.11+ : K (hover), grn, gra, grr, gri, [d / ]d
  map("gd", vim.lsp.buf.definition, "Définition")
  map("gi", vim.lsp.buf.implementation, "Implémentation")
  map("<leader>li", function()
    vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr }), { bufnr = bufnr })
  end, "Inlay hints (bascule)")
  map("<leader>lrn", vim.lsp.buf.rename, "Renommer")
  map("<leader>lca", vim.lsp.buf.code_action, "Code action")
  map("<leader>ld", vim.diagnostic.open_float, "Diagnostic (flottant)")

  -- ruff + pyright : laisser le hover à pyright (recommandation ruff)
  if client and client.name == "ruff" then
    client.server_capabilities.hoverProvider = false
  end
end

return {
  -- Gestion des outils LSP
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    opts = {
      ui = { border = "rounded", icons = { package_installed = "✓", package_pending = "➜", package_uninstalled = "✗" } },
    },
  },

  -- Installation + activation automatique des serveurs
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim", "neovim/nvim-lspconfig" },
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      ensure_installed = {
        "bashls",
        "lua_ls",
        -- Python : pyright (types) + ruff (lint/format)
        "pyright",
        "ruff",
        -- JS/TS + web
        "ts_ls",
        "eslint",
        "jsonls",
        "cssls",
        "html",
        -- DevOps
        "yamlls",
        "dockerls",
        "docker_compose_language_service",
        "terraformls",
        "ansiblels",
        "taplo", -- TOML (pyproject.toml, Cargo.toml...)
        "marksman",
      },
    },
    config = function(_, opts)
      local has_blink, blink = pcall(require, "blink.cmp")
      if has_blink then
        vim.lsp.config("*", { capabilities = blink.get_lsp_capabilities() })
      end

      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            runtime = { version = "LuaJIT" },
            workspace = { checkThirdParty = false },
            diagnostics = { globals = { "vim" } },
          },
        },
      })

      -- pyright respecte le venv du projet (direnv/uv) via VIRTUAL_ENV ;
      -- en mode workspace, on pointe aussi explicitement .venv.
      vim.lsp.config("pyright", {
        settings = {
          python = {
            venvPath = ".",
            venv = ".venv",
            analysis = { typeCheckingMode = "basic", autoImportCompletions = true },
          },
        },
      })

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("user_lsp_attach", { clear = true }),
        callback = on_attach,
      })

      require("mason-lspconfig").setup(opts)
    end,
  },

  -- Outils hors LSP installés automatiquement par mason : débogueurs
  -- (debugpy, js-debug-adapter) et formateur prettier (js/ts/json/css).
  -- stylua, shfmt, ruff, yamlfmt viennent des paquets pacman (dans le PATH).
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "williamboman/mason.nvim" },
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      ensure_installed = {
        "debugpy",
        "js-debug-adapter",
        "prettierd",
      },
      run_on_start = true,
    },
  },
}
