local function setup()
  -- setup rcarriga/nvim-notify
  vim.notify = require("notify")

  -- setup autosession
  require("auto-session").setup({})
  require("session-lens").setup()

  -- setup hop for movement
  require("hop").setup()

  -- setup feline
  require("feline").setup()
  require("feline").winbar.setup()

  -- setup nvim-tree for file nav
  require("nvim-tree").setup({
    view = {
      width = 35,
      mappings = {
        list = {
          {
            key = "<S-a>",
            cb = require("nvim-tree-util").toggle_size,
          },
          {
            key = "i",
            action = "split",
          },
          {
            key = "s",
            action = "vsplit",
          },
        },
      },
    },
  })

  -- setup bufferline for nicer tabs
  require("bufferline").setup({
    options = {
      separator_style = "slant",
      diagnostics = "nvim_lsp",
      mode = "tabs",
      always_show_bufferline = false,
    },
  })

  -- setup telescope
  local telescope_actions = require("telescope.actions")
  local telescope_smart_history_path =
    "~/.local/share/nvim/databases/telescope_history.sqlite3"

  require("telescope").setup({
    defaults = {
      history = {
        path = telescope_smart_history_path,
        limit = 100,
      },
      mappings = {
        i = {
          ["<C-Down>"] = require("telescope.actions").cycle_history_next,
          ["<C-Up>"] = require("telescope.actions").cycle_history_prev,
        },
      },
    },
  })

  require("telescope").load_extension("fzf")
  require("telescope").load_extension("dap")
  require("telescope").load_extension("session-lens")
  require("telescope").load_extension("luasnip")
  require("telescope").load_extension("live_grep_args")
  require("telescope").load_extension("smart_history")

  require("telescope-tabs").setup()

  require("symbols-outline").setup({
    keymaps = {
      close = { "q" },
    },
  })
end

return {
  setup = setup,
}
