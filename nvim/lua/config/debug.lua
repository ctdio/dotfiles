local function setup()
  -- setup dap
  require("dapui").setup()

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
end

return {
  setup = setup,
}
