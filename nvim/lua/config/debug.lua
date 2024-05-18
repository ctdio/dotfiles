local function setup()
  -- setup dap
  local dapui = require("dapui")
  dapui.setup()

  local dap = require("dap")
  require("dap-go").setup()
  require("dap-python").setup()
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
              if url == nil or url == "" then
                return
              else
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

  vim.keymap.set("n", "<leader>db", function()
    dap.toggle_breakpoint()
  end)

  vim.keymap.set("n", "<leader>dc", function()
    dap.continue()
  end)

  vim.keymap.set("n", "<leader>dsv", function()
    dap.step_over()
  end)

  vim.keymap.set("n", "<leader>dsi", function()
    dap.step_into()
  end)

  vim.keymap.set("n", "<leader>dso", function()
    dap.step_out()
  end)

  vim.keymap.set("n", "<leader>du", function()
    dapui.toggle({ reset = true })
  end)
end

return {
  setup = setup,
}
