-- Débogage (Debug Adapter Protocol) : points d'arrêt, exécution pas à pas,
-- inspection des variables. Python (debugpy) et JS/TS (js-debug-adapter),
-- tous deux installés par mason (voir lsp.lua, mason-tool-installer).
return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      -- Interface : panneaux variables / pile / points d'arrêt / REPL
      {
        "rcarriga/nvim-dap-ui",
        dependencies = { "nvim-neotest/nvim-nio" },
        config = function()
          local dap, dapui = require("dap"), require("dapui")
          dapui.setup()
          -- Ouvre/ferme l'UI automatiquement avec la session
          dap.listeners.after.event_initialized["dapui"] = function() dapui.open() end
          dap.listeners.before.event_terminated["dapui"] = function() dapui.close() end
          dap.listeners.before.event_exited["dapui"] = function() dapui.close() end
        end,
      },
      -- Valeurs des variables affichées en ligne (en commentaire virtuel)
      { "theHamsta/nvim-dap-virtual-text", opts = {} },
      -- Python : configurations lancées automatiquement
      {
        "mfussenegger/nvim-dap-python",
        config = function()
          -- Adaptateur = debugpy de mason (indépendant du projet).
          local mason = vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python"
          require("dap-python").setup(mason)

          -- Le debuggee tourne dans le venv du projet (direnv/uv) s'il existe,
          -- sinon python3 du PATH. Couvre tous les configs python de dap-python.
          for _, cfg in ipairs(require("dap").configurations.python or {}) do
            cfg.pythonPath = function()
              local venv = os.getenv("VIRTUAL_ENV")
              if venv and vim.fn.executable(venv .. "/bin/python") == 1 then
                return venv .. "/bin/python"
              end
              local cwd = vim.fn.getcwd()
              if vim.fn.executable(cwd .. "/.venv/bin/python") == 1 then
                return cwd .. "/.venv/bin/python"
              end
              return "python3"
            end
          end
        end,
      },
    },
    config = function()
      local dap = require("dap")

      -- Signes dans la gouttière
      local sign = vim.fn.sign_define
      sign("DapBreakpoint", { text = "●", texthl = "DiagnosticError" })
      sign("DapBreakpointCondition", { text = "◆", texthl = "DiagnosticWarn" })
      sign("DapStopped", { text = "▶", texthl = "DiagnosticInfo", linehl = "Visual" })

      -- JS/TS : adaptateur pwa-node de js-debug-adapter (mason)
      local jsdbg = vim.fn.stdpath("data") .. "/mason/packages/js-debug-adapter"
      dap.adapters["pwa-node"] = {
        type = "server",
        host = "localhost",
        port = "${port}",
        executable = {
          command = "node",
          args = { jsdbg .. "/js-debug/src/dapDebugServer.js", "${port}" },
        },
      }
      for _, lang in ipairs({ "javascript", "typescript", "javascriptreact", "typescriptreact" }) do
        dap.configurations[lang] = {
          {
            type = "pwa-node",
            request = "launch",
            name = "Lancer le fichier courant",
            program = "${file}",
            cwd = "${workspaceFolder}",
            -- Exécute le TS via le loader du projet si présent
            runtimeExecutable = "node",
          },
          {
            type = "pwa-node",
            request = "attach",
            name = "S'attacher (port 9229)",
            processId = require("dap.utils").pick_process,
            cwd = "${workspaceFolder}",
          },
        }
      end
    end,
    keys = {
      { "<leader>d", nil, desc = "Debug" },
      { "<F5>", function() require("dap").continue() end, desc = "Debug: continuer / démarrer" },
      { "<F10>", function() require("dap").step_over() end, desc = "Debug: pas au-dessus" },
      { "<F11>", function() require("dap").step_into() end, desc = "Debug: pas dans" },
      { "<F12>", function() require("dap").step_out() end, desc = "Debug: pas dehors" },
      { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Point d'arrêt (bascule)" },
      {
        "<leader>dB",
        function() require("dap").set_breakpoint(vim.fn.input("Condition : ")) end,
        desc = "Point d'arrêt conditionnel",
      },
      { "<leader>dc", function() require("dap").continue() end, desc = "Continuer / démarrer" },
      { "<leader>dr", function() require("dap").repl.toggle() end, desc = "REPL" },
      { "<leader>dl", function() require("dap").run_last() end, desc = "Relancer la dernière session" },
      { "<leader>dt", function() require("dap").terminate() end, desc = "Terminer la session" },
      { "<leader>du", function() require("dapui").toggle() end, desc = "Interface debug (bascule)" },
      {
        "<leader>de",
        function() require("dapui").eval() end,
        mode = { "n", "v" },
        desc = "Évaluer l'expression",
      },
      -- Débogage du test Python sous le curseur (méthode/classe)
      { "<leader>dm", function() require("dap-python").test_method() end, ft = "python", desc = "Debug: méthode de test" },
    },
  },
}
