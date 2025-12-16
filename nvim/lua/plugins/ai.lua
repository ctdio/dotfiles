-- AI plugins: Copilot, CodeCompanion, Sidekick

return {
  {
    "zbirenbaum/copilot.lua",
    event = "VeryLazy",
    config = function()
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
          layout = { position = "bottom", ratio = 0.4 },
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
    end,
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

      vim.keymap.set(
        "v",
        "ga",
        "<cmd>CodeCompanionChat Add<cr>",
        { noremap = true, silent = true }
      )

      -- Expand 'cc' into 'CodeCompanion' in the command line
      vim.cmd([[cab cc CodeCompanion]])
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
