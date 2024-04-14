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
      cwd = "${workspaceFolder}",
    },
    {
      type = "pwa-node",
      request = "attach",
      name = "Attach",
      processId = require("dap.utils").pick_process,
      cwd = "${workspaceFolder}",
    },
  }

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
