local dap = require('dap')

local function attach_to_inspector()
  local config_name = vim.fn.input('Which configuration? ')
  local config = dap.configurations[config_name]
  dap.run(config)
end

return {
  attach_to_inspector = attach_to_inspector,
}
