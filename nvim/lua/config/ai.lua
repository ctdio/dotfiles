local function setup()
  require("copilot").setup({
    suggestion = {
      enabled = true,
      auto_trigger = true,
      hide_during_completion = true,
      debounce = 75,
      keymap = {
        accept = "<C-k>",
        accept_word = false,
        accept_line = false,
        next = "<M-]>",
        prev = "<M-[>",
        dismiss = "<C-]>",
      },
    },
    panel = {
      enabled = true,
      auto_refresh = false,
      keymap = {
        jump_prev = "[[",
        jump_next = "]]",
        accept = "<CR>",
        refresh = "gr",
        open = "<M-CR>",
      },
      layout = {
        position = "bottom",
        ratio = 0.4,
      },
    },
    filetypes = {
      yaml = false,
      markdown = false,
      help = false,
      gitcommit = false,
      gitrebase = false,
      hgcommit = false,
      svn = false,
      cvs = false,
      ["."] = false,
    },
  })

  require("codecompanion").setup({
    strategies = {
      chat = {
        adapter = "anthropic",
      },
      inline = {
        adapter = "anthropic",
      },
    },
  })

  vim.keymap.set("n", "<leader>i", "<cmd>CodeCompanionChat<cr>")
  vim.keymap.set({ "v" }, "<leader>cc", "<cmd>'<,'>CodeCompanion<cr>")

  require("sidekick").setup({})

  -- Sidekick keymaps
  vim.keymap.set("n", "<tab>", function()
    if not require("sidekick").nes_jump_or_apply() then
      return "<Tab>"
    end
  end, { expr = true, desc = "Goto/Apply Next Edit Suggestion" })

  vim.keymap.set("n", "<leader>aa", function()
    require("sidekick.cli").toggle()
  end, { desc = "Sidekick Toggle CLI" })
end

return {
  setup = setup,
}
