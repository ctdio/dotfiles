local function setup()
  require("img-clip").setup()
  require("mini.diff").setup()

  require("snacks").setup({
    bigfile = {},
    notifier = {
      top_down = false,
    },
  })
end

return {
  setup = setup,
}
