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

  -- require("avante_lib").load()
  -- require("avante").setup({
  --   provider = "claude",
  --   behavior = {
  --     auto_suggestion = true,
  --   },
  -- })
  --
  os = require("os")

  require("codecompanion").setup({
    adapters = {
      anthropic = function()
        return require("codecompanion.adapters").extend("anthropic", {
          env = {
            api_key = os.getenv("ANTHROPIC_API_KEY"),
          },
        })
      end,
    },
    strategies = {
      chat = {
        adapter = "anthropic",
      },
      inline = {
        adapter = "anthropic",
      },
      agent = {
        adapter = "anthropic",
      },
    },
  })

  vim.keymap.set("v", "<C-a>", ":CodeCompanion ")
  vim.keymap.set("n", "<leader>aa", ":CodeCompanionChat toggle<CR>")
  vim.keymap.set("n", "<leader>ac", ":CodeCompanionActions<CR>")
end

return {
  setup = setup,
}
