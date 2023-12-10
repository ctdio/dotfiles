local function setup()
  require("neotest").setup({
    adapters = {
      require("neotest-go"),
      require("neotest-python"),
      require("neotest-jest")({
        jestCommand = "npx jest",
        jestConfigFile = function()
          local file = vim.fn.expand("%:p")
          if string.find(file, "/packages/") then
            return string.match(file, "(.-/[^/]+/)src") .. "jest.config.ts"
          end

          return vim.fn.getcwd() .. "/jest.config.ts"
        end,
        cwd = function()
          local file = vim.fn.expand("%:p")
          if string.find(file, "/packages/") then
            return string.match(file, "(.-/[^/]+/)src")
          end
          return vim.fn.getcwd()
        end,
      }),
      require("neotest-vitest"),
      require("neotest-rust"),
      require("neotest-elixir"),
    },
  })
end

return {
  setup = setup,
}
