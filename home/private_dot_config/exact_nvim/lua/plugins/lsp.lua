local has_blink, blink = pcall(require, "blink.cmp")
local default_capabilities =
  has_blink and blink.get_lsp_capabilities() or vim.lsp.protocol.make_client_capabilities()

local function on_attach(_, bufnr)
  local buf = { noremap = true, silent = true, buffer = bufnr }
  vim.keymap.set("n", "gd", vim.lsp.buf.definition, buf)
  vim.keymap.set("n", "K", vim.lsp.buf.hover, buf)
  vim.keymap.set("n", "gi", vim.lsp.buf.implementation, buf)
  vim.keymap.set("n", "<leader>li", vim.lsp.buf.inlay_hint, buf)
  vim.keymap.set("n", "<leader>lrn", vim.lsp.buf.rename, buf)
  vim.keymap.set("n", "<leader>lca", vim.lsp.buf.code_action, buf)
  vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, buf)
  vim.keymap.set("n", "]d", vim.diagnostic.goto_next, buf)
  vim.keymap.set("n", "<leader>ld", vim.diagnostic.open_float, buf)
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

  -- Configuration automatique des serveurs
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim", "neovim/nvim-lspconfig" },
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      ensure_installed = {
        "bashls",
        "lua_ls",
        "pyright",
        "ruff",
        "ts_ls",
        "yamlls",
        "marksman",
        "dockerls",
      },
      handlers = {
        function(server)
          require("lspconfig")[server].setup({
            capabilities = default_capabilities,
            on_attach = on_attach,
          })
        end,
        lua_ls = function()
          require("lspconfig").lua_ls.setup({
            capabilities = default_capabilities,
            on_attach = on_attach,
            settings = {
              Lua = {
                runtime = { version = "LuaJIT" },
                workspace = { checkThirdParty = false },
                diagnostics = { globals = { "vim" } },
              },
            },
          })
        end,
        ruff = function()
          vim.api.nvim_create_autocmd("LspAttach", {
            callback = function(args)
              if args.data and args.data.client_id then
                local client = vim.lsp.get_client_by_id(args.data.client_id)
                if client and client.name == "ruff" then
                  vim.keymap.set("n", "<leader>lca", function()
                    vim.lsp.buf.code_action({
                      filter = function(action) return action.title:find("suggest") ~= nil end,
                      apply = true,
                      context = { only = { "source.fixAll", "source.organizeImports" } },
                    })
                  end, { buffer = args.buf, desc = "Ruff fix + organize" })
                end
              end
            end,
          })
          require("lspconfig").ruff.setup({
            capabilities = default_capabilities,
            on_attach = on_attach,
          })
        end,
      },
    },
  },
}