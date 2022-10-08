local function setup()
  require('octo').setup()
  require('gitsigns').setup()
end

return {
  setup = setup
}
