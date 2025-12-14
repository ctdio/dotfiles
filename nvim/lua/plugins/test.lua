-- Test plugins (lazy loaded on command)

return {
  {
    "nvim-neotest/neotest",
    cmd = { "Neotest" },
    keys = {
      {
        "<leader>ta",
        function()
          require("neotest").run.attach()
        end,
        desc = "Attach to test",
      },
      {
        "<leader>td",
        function()
          require("neotest").run.run({ strategy = "dap" })
        end,
        desc = "Debug test",
      },
      {
        "<leader>tt",
        function()
          require("neotest").run.run()
        end,
        desc = "Run nearest test",
      },
      {
        "<leader>tf",
        function()
          require("neotest").run.run(vim.fn.expand("%"))
        end,
        desc = "Run file tests",
      },
      {
        "<leader>to",
        function()
          require("neotest").output.open({ enter = true })
        end,
        desc = "Open test output",
      },
      {
        "<leader>ts",
        function()
          require("neotest").summary.toggle()
        end,
        desc = "Toggle test summary",
      },
    },
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "nvim-neotest/neotest-go",
      "nvim-neotest/neotest-python",
      "haydenmeade/neotest-jest",
      "marilari88/neotest-vitest",
      "rouge8/neotest-rust",
      "jfpedroza/neotest-elixir",
    },
    config = function()
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
    end,
  },

  { "nvim-neotest/neotest-go", lazy = true },
  { "nvim-neotest/neotest-python", lazy = true },
  { "haydenmeade/neotest-jest", lazy = true },
  { "marilari88/neotest-vitest", lazy = true },
  { "rouge8/neotest-rust", lazy = true },
  { "jfpedroza/neotest-elixir", lazy = true },
}
