local function setup()
  -- setup theme
  require("catppuccin").setup()
  vim.cmd([[colorscheme catppuccin]])
end

return {
  setup = setup,
}
