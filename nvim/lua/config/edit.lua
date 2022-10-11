local function setup()
  -- setup zen-mode for focused writing
  require("zen-mode").setup()

  -- setup ufo for folding
  require("ufo").setup()

  -- setup glow for markdown
  require("glow").setup()
end

return {
  setup = setup,
}
