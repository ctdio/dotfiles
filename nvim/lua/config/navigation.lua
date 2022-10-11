local function setup()
  -- setup rcarriga/nvim-notify
  vim.notify = require("notify")

  -- setup autosession
  require("auto-session").setup()
  require("session-lens").setup()

  -- setup hop for movement
  require("hop").setup()

  -- setup feline
  require("feline").setup()
  require("feline").winbar.setup()

  -- setup nvim-tree for file nav
  require("nvim-tree").setup({
    view = {
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
  require("telescope").setup({
    defaults = {
      mappings = {
        i = {
          ["<C-k>"] = telescope_actions.move_selection_previous,
          ["<C-j>"] = telescope_actions.move_selection_next,
        },
      },
    },
  })
  require("telescope").load_extension("fzf")
  require("telescope").load_extension("dap")
  require("telescope").load_extension("session-lens")
  require("telescope-tabs").setup()
end

return {
  setup = setup,
}
