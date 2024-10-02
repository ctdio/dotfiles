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

  require("avante_lib").load()
  require("avante").setup({
    provider = "claude",
    behavior = {
      auto_suggestion = true,
    },
  })
end

return {
  setup = setup,
}
