-- AI plugins: Copilot, CodeCompanion, Sidekick

return {
  {
    "zbirenbaum/copilot.lua",
    enabled = false,
  },

  {
    "olimorris/codecompanion.nvim",
    version = "^18.0.0",
    cmd = { "CodeCompanion", "CodeCompanionChat", "CodeCompanionActions" },
    keys = {
      {
        "<leader>i",
        "<cmd>CodeCompanionChat<cr>",
        desc = "CodeCompanion Chat",
      },
      {
        "<leader>cc",
        "<cmd>'<,'>CodeCompanion<cr>",
        mode = "v",
        desc = "CodeCompanion",
      },
      {
        "ga",
        "<cmd>CodeCompanionChat Add<cr>",
        mode = "v",
        desc = "Add to CodeCompanion Chat",
      },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      require("codecompanion").setup({
        adapters = {
          claude_code = function()
            return require("codecompanion.adapters").extend("claude_code", {
              env = {
                CLAUDE_CODE_OAUTH_TOKEN = os.getenv("CLAUDE_CODE_OAUTH_TOKEN"),
              },
            })
          end,
        },
        strategies = {
          chat = { adapter = "claude_code" },
          inline = { adapter = "claude_code" },
        },
      })

      print(
        os.getenv("CLAUDE_CODE_OAUTH_TOKEN")
            and "CodeCompanion: Claude Code token found."
          or "CodeCompanion: Claude Code token NOT found!"
      )
    end,
  },

  {
    "folke/sidekick.nvim",
    event = "VeryLazy",
    config = function()
      require("sidekick").setup({})

      vim.keymap.set({ "i", "n" }, "<C-k>", function()
        if not require("sidekick").nes_jump_or_apply() then
          return "<Tab>"
        end
      end, { expr = true, desc = "Goto/Apply Next Edit Suggestion" })
    end,
  },
}
