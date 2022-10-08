local function setup()
  require("neotest").setup({
    adapters = {
      require("neotest-go"),
      require("neotest-python"),
      require("neotest-jest")({
        jestCommand = "npx jest",
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
