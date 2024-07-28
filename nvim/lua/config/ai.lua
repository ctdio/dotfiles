local function setup()
  require("supermaven-nvim").setup({
    keymaps = {
      accept_suggestion = "<C-k>",
      clear_suggestion = nil,
      accept_word = nil,
    },
    ignore_filetypes = { sh = true, TelescopePrompt = true },
  })

  local gp = require("gp")
  gp.setup({
    openai_api_key = os.getenv("NEOVIM_OPENAI_API_KEY"),
    agents = {
      {
        name = "GPT-4o",
        provider = "openai",
        chat = true,
        command = true,
        model = { model = "gpt-4o" },
      },
      -- disable other agents
      { name = "ChatGPT4", disable = true },
      { name = "ChatGPT3.5", disable = true },
      { name = "CodeGPT4", disable = true },
      { name = "CodeGPT3.5", disable = true },
    },
  })

  vim.keymap.set("n", "<leader>gc", "<cmd>GpChatToggle<cr>")
end

return {
  setup = setup,
}
