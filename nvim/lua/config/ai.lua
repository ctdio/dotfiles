local function setup()
  require("supermaven-nvim").setup({
    keymaps = {
      accept_suggestion = "<C-k>",
      clear_suggestion = nil,
      accept_word = nil,
    },
    ignore_filetypes = { TelescopePrompt = true },
    condition = function()
      return string.match(vim.fn.expand("%:t"), ".env")
    end,
  })

  local api = require("supermaven-nvim.api")

  -- Supermaven has been dying occasionally
  -- Set up periodic Supermaven restart
  vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
      if not api.is_running() then
        vim.cmd("SupermavenStart")
      end
      -- Set up timer for periodic restart
      local timer = vim.loop.new_timer()
      timer:start(
        5 * 60 * 1000, -- 10 minutes in milliseconds
        5 * 60 * 1000, -- 10 minutes in milliseconds
        vim.schedule_wrap(function()
          if not api.is_running() then
            vim.cmd("SupermavenRestart")
          end
        end)
      )
    end,
  })

  require("mcphub").setup()
  require("codecompanion").setup({
    strategies = {
      chat = {
        adapter = "anthropic",
      },
      inline = {
        adapter = "anthropic",
      },
    },
    extensions = {
      mcphub = {
        callback = "mcphub.extensions.codecompanion",
        opts = {
          show_result_in_chat = true, -- Show mcp tool results in chat
          make_vars = true, -- Convert resources to #variables
          make_slash_commands = true, -- Add prompts as /slash commands
        },
      },
    },
  })

  vim.keymap.set("n", "<leader>i", "<cmd>CodeCompanionChat<cr>")
  vim.keymap.set({ "v" }, "<C-k>", "<cmd>'<,'>CodeCompanion<cr>")
end

return {
  setup = setup,
}
