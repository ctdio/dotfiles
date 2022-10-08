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

  dap.configurations.typescript = {
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

  require("nvim-dap-virtual-text").setup()

  -- setup rcarriga/nvim-notify
  vim.notify = require("notify")

  require("trouble").setup()
end

return {
  setup = setup,
}
