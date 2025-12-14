-- Debug plugins (lazy loaded on command)

return {
  {
    "mfussenegger/nvim-dap",
    cmd = { "DapContinue", "DapToggleBreakpoint" },
    keys = {
      {
        "<leader>db",
        function()
          require("dap").toggle_breakpoint()
        end,
        desc = "Toggle breakpoint",
      },
      {
        "<leader>dc",
        function()
          require("dap").continue()
        end,
        desc = "Continue",
      },
      {
        "<leader>dsv",
        function()
          require("dap").step_over()
        end,
        desc = "Step over",
      },
      {
        "<leader>dsi",
        function()
          require("dap").step_into()
        end,
        desc = "Step into",
      },
      {
        "<leader>dso",
        function()
          require("dap").step_out()
        end,
        desc = "Step out",
      },
      {
        "<leader>du",
        function()
          require("dapui").toggle({ reset = true })
        end,
        desc = "Toggle DAP UI",
      },
    },
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "theHamsta/nvim-dap-virtual-text",
      "mfussenegger/nvim-dap-python",
      "leoluz/nvim-dap-go",
      "mxsdev/nvim-dap-vscode-js",
      "nvim-neotest/nvim-nio",
    },
    config = function()
      local dapui = require("dapui")
      dapui.setup()

      local dap = require("dap")
      require("dap-go").setup()
      require("dap-python").setup()
      require("dap-vscode-js").setup({
        adapters = {
          "pwa-node",
          "pwa-chrome",
          "node-terminal",
          "pwa-extensionHost",
        },
      })

      local node_config = {
        {
          type = "pwa-node",
          request = "launch",
          name = "Launch file",
          program = "${file}",
          skipFiles = { "<node_internals>/**" },
          cwd = "${workspaceFolder}",
          sourceMaps = true,
        },
        {
          type = "pwa-node",
          request = "attach",
          name = "Attach",
          skipFiles = { "<node_internals>/**" },
          processId = require("dap.utils").pick_process,
          cwd = "${workspaceFolder}",
          sourceMaps = true,
        },
        {
          name = "Launch & Debug Chrome",
          type = "pwa-chrome",
          request = "launch",
          skipFiles = { "<node_internals>/**" },
          url = function()
            local co = coroutine.running()
            return coroutine.create(function()
              vim.ui.input(
                { prompt = "Enter URL: ", default = "http://localhost:3000" },
                function(url)
                  if url and url ~= "" then
                    coroutine.resume(co, url)
                  end
                end
              )
            end)
          end,
          protocol = "inspector",
          sourceMaps = true,
          userDataDir = false,
          rootPath = "${workspaceFolder}",
          cwd = "${workspaceFolder}",
          console = "integratedTerminal",
          internalConsoleOptions = "neverOpen",
        },
      }

      dap.configurations.javascript = node_config
      dap.configurations.javascriptreact = node_config
      dap.configurations.typescript = node_config
      dap.configurations.typescriptreact = node_config

      require("nvim-dap-virtual-text").setup()
    end,
  },

  { "rcarriga/nvim-dap-ui", lazy = true },
  { "theHamsta/nvim-dap-virtual-text", lazy = true },
  { "mfussenegger/nvim-dap-python", lazy = true },
  { "leoluz/nvim-dap-go", lazy = true },
  { "mxsdev/nvim-dap-vscode-js", lazy = true },
  { "nvim-neotest/nvim-nio", lazy = true },
}
