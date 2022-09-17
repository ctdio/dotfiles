local function setup ()
  -- setup theme
  require("catppuccin").setup()
  vim.cmd[[colorscheme catppuccin]]

  -- setup feline
  require('feline').setup()
end

return {
  setup = setup
}
