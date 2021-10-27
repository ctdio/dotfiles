local dap = require('dap')

local function attach_to_nodejs_inspector()
  dap.run({
    type = 'jsnode',
    request = 'attach',
    address = "127.0.0.1",
    port = 9229,
    localRoot = vim.fn.getcwd(),
    remoteRoot = "/home/vcap/app",
    sourceMaps = true,
    protocol = 'inspector',
    skipFiles = {'<node_internals>/**/*.js'},
  })
end

return {
  attach_to_nodejs_inspector = attach_to_nodejs_inspector,
}
