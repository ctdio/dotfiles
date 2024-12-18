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
    claude = {
      model = "claude-3-5-sonnet-latest",
    },
    behavior = {
      auto_suggestions = true,
    },
    mappings = {
      ask = "<space>aa",
      edit = "<space>ae",
      refresh = "<space>ar",
      focus = "<space>af",
      toggle = {
        default = "<space>at",
        debug = "<space>ad",
        hint = "<space>ah",
        suggestion = "<space>as",
        repomap = "<space>aR",
      },
    },
  })
end

return {
  setup = setup,
}
