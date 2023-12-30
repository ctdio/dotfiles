local function setup()
  require("gitsigns").setup()

  require("diffview").setup({
    view = {
      merge_tool = {
        layout = "diff3_mixed",
      },
    },
  })
end

return {
  setup = setup,
}
