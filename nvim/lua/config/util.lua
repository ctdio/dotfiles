local function setup()
  require("img-clip").setup()
  require("mini.diff").setup()
  require("snacks").setup()
end

return {
  setup = setup,
}
