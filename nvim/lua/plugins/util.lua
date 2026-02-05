-- Utility plugins

return {
  -- NUI (dependency)
  { "MunifTanjim/nui.nvim", lazy = true },

  -- Snacks (bigfile, notifier)
  {
    "folke/snacks.nvim",
    lazy = false,
    priority = 900,
    config = function()
      require("snacks").setup({
        bigfile = {},
        notifier = { top_down = false },
      })
    end,
  },

  -- Mini.diff
  {
    "echasnovski/mini.nvim",
    event = "VeryLazy",
    config = function()
      require("mini.diff").setup()
    end,
  },

  -- Image clipboard
  {
    "HakonHarnes/img-clip.nvim",
    event = "VeryLazy",
    config = function()
      require("img-clip").setup()
    end,
  },

  -- Open browser
  {
    "tyru/open-browser.vim",
    cmd = { "OpenBrowser", "OpenBrowserSearch" },
  },

  -- Open browser GitHub
  {
    "tyru/open-browser-github.vim",
    cmd = { "OpenGithubFile", "OpenGithubIssue", "OpenGithubPullReq" },
    dependencies = { "tyru/open-browser.vim" },
  },

  -- Database
  {
    "tpope/vim-dadbod",
    cmd = { "DB", "DBUI" },
  },
  {
    "kristijanhusak/vim-dadbod-ui",
    cmd = { "DBUI", "DBUIToggle", "DBUIAddConnection" },
    dependencies = { "tpope/vim-dadbod" },
  },
  {
    "kristijanhusak/vim-dadbod-completion",
    ft = { "sql", "mysql", "plsql" },
    dependencies = { "tpope/vim-dadbod" },
  },

  -- Dotenv
  {
    "tpope/vim-dotenv",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd("Dotenv ~")
    end,
  },

  -- Fix CursorHold
  {
    "antoinemadec/FixCursorHold.nvim",
    event = "VeryLazy",
  },

  -- Startup time profiler
  {
    "dstein64/vim-startuptime",
    cmd = "StartupTime",
  },
}
