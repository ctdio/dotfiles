local function setup()
  -- setup indent-blankline
  require("ibl").setup()

  -- setup text-case for easier text case manipulation
  require("textcase").setup()

  -- autopairs
  require("nvim-autopairs").setup({
    check_ts = true,
  })

  require("nvim-surround").setup({})

  -- comments
  require("Comment").setup({
    pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
  })

  -- formatting
  require("conform").setup({
    format_on_save = {
      timeout_ms = 3000,
      lsp_format = "fallback",
    },
    formatters_by_ft = {
      lua = { "stylua" },
      python = { "ruff_format" },
      json = { "prettierd", "prettier" },
      javascript = { { "prettierd", "prettier" } },
      javascriptreact = { { "prettierd", "prettier" } },
      typescript = { "prettierd", "prettier" },
      typescriptreact = { "prettierd", "prettier" },
      go = { "gofmt" },
      rust = { "rustfmt" },
    },
  })

  -- setup zen-mode for focused writing
  require("zen-mode").setup()

  -- friendly snippets
  require("luasnip.loaders.from_vscode").lazy_load()

  require("luasnip.loaders.from_vscode").load({
    paths = "~/.config/nvim/snippets",
  })

  require("luasnip").filetype_extend("typescript", { "javascript" })
  require("luasnip").filetype_extend("typescriptreact", { "javascript" })

  -- search and replace
  local spectre = require("spectre")
  spectre.setup()

  vim.keymap.set("n", "<leader>S", function()
    spectre.toggle()
  end)

  vim.keymap.set("n", "<leader>sw", function()
    spectre.open_visual({ select_word = true })
  end)

  vim.keymap.set("v", "<leader>sw", function()
    spectre.open_visual()
  end)

  vim.keymap.set("n", "<leader>sp", function()
    spectre.open_file_search({ select_word = true })
  end)

  require("obsidian").setup({
    workspaces = {
      {
        name = "personal",
        path = "~/obsidian",
      },
    },
    notes_subdir = "Notes",
    note_id_func = function(title)
      -- Convert the timestamp to a date table in the local time zone
      local dateTable = os.date("*t", os.time())

      -- Format the date and time as "YYYY-MM-DD-hh:mm"
      local formattedDateTime = string.format(
        "%04d-%02d-%02d-%02d%02d-%s.md",
        dateTable.year,
        dateTable.month,
        dateTable.day,
        dateTable.hour,
        dateTable.min,
        title
      )

      return formattedDateTime
    end,
  })

  require("hbac").setup()
end

return {
  setup = setup,
}
