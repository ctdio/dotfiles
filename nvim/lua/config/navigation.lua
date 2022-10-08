local function setup()
  -- setup hop for movement
  require("hop").setup()

  -- setup nvim-tree for file nav
  require("nvim-tree").setup({
    view = {
      mappings = {
        list = {
          {
            key = "<S-a>",
            cb = ":lua require('nvimTreeUtil').toggle_size()<CR>",
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
  require("telescope-tabs").setup()

  -- setup ufo for folding
  require("ufo").setup()
end

return {
  setup = setup,
}
