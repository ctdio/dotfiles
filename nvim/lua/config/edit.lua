local function setup()
  -- setup indent-blankline
  require("ibl").setup()

  -- setup text-case for easier text case manipulation
  require("textcase").setup()

  -- autopairs
  require("nvim-autopairs").setup({
    check_ts = true,
  })

  -- comments
  require("Comment").setup()

  -- setup zen-mode for focused writing
  require("zen-mode").setup()

  -- setup ufo for folding
  require("ufo").setup()

  -- friendly snippets
  require("luasnip.loaders.from_vscode").lazy_load()

  require("luasnip.loaders.from_vscode").load({
    paths = "~/.config/nvim/snippets",
  })

  require("luasnip").filetype_extend("typescript", { "javascript" })
  require("luasnip").filetype_extend("typescriptreact", { "javascript" })

  -- search and replace
  require("spectre").setup()

  local env_path = vim.fn.expand("$HOME") .. "/.env"

  require("chatgpt").setup({
    api_key_cmd = "dotenv -e " .. env_path .. " -p NEOVIM_OPENAI_API_KEY",
  })

  require("obsidian").setup({
    workspaces = {
      {
        name = "personal",
        path = "~/obsidian",
      },
    },
  })
end

return {
  setup = setup,
}
