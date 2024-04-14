local function setup()
  local neotest = require("neotest")

  neotest.setup({
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

  vim.keymap.set("n", "<leader>ta", function()
    neotest.run.attach()
  end)

  vim.keymap.set("n", "<leader>td", function()
    neotest.run.run({ strategy = "dap" })
  end)

  vim.keymap.set("n", "<leader>tt", function()
    neotest.run.run()
  end)

  vim.keymap.set("n", "<leader>tf", function()
    neotest.run.run(vim.fn.expand("%"))
  end)

  vim.keymap.set("n", "<leader>to", function()
    neotest.output.open({ enter = true })
  end)

  vim.keymap.set("n", "<leader>ts", function()
    neotest.summary.toggle()
  end)
end

return {
  setup = setup,
}
