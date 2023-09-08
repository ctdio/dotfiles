local function setup()
  -- setup zen-mode for focused writing
  require("zen-mode").setup()

  -- setup ufo for folding
  require("ufo").setup()

  -- setup glow for markdown
  require("glow").setup()

  -- friendly snippets
  require("luasnip.loaders.from_vscode").lazy_load()

  require("luasnip.loaders.from_vscode").load({
    paths = "~/.config/nvim/snippets",
  })

  require("luasnip").filetype_extend("typescript", { "javascript" })
  require("luasnip").filetype_extend("typescriptreact", { "javascript" })

  -- search and replace
  require("spectre").setup()
end

return {
  setup = setup,
}
