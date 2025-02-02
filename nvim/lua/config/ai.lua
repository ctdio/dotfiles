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
      edit = "<C-enter>",
      refresh = "<space>ar",
      focus = "<space>ar",
      toggle = {
        default = "<space>at",
        debug = "<space>ad",
        hint = "<space>ah",
        suggestion = "<space>as",
        repomap = "<space>aR",
      },
    },
  })

  vim.keymap.set("n", "<C-enter>", function()
    vim.cmd("normal! v")
    vim.api.nvim_cmd({ cmd = "AvanteEdit" }, {})
  end)
end

return {
  setup = setup,
}
