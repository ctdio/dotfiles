-- Git plugins

return {
  {
    "tpope/vim-fugitive",
    cmd = { "Git", "G", "Gread", "Gwrite", "Gdiffsplit", "Gvdiffsplit" },
    event = "VeryLazy",
  },

  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("gitsigns").setup()

      local gs = require("gitsigns")
      local ts_repeat_move =
        require("nvim-treesitter.textobjects.repeatable_move")
      local next_hunk_repeat, prev_hunk_repeat =
        ts_repeat_move.make_repeatable_move_pair(gs.next_hunk, gs.prev_hunk)

      vim.keymap.set({ "n", "x", "o" }, "]h", next_hunk_repeat)
      vim.keymap.set({ "n", "x", "o" }, "[h", prev_hunk_repeat)
    end,
  },

  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewFileHistory", "DiffviewClose" },
    config = function()
      require("diffview").setup({
        view = { merge_tool = { layout = "diff3_mixed" } },
      })
    end,
  },
}
