local nvimTree = require("nvim-tree")

local is_toggled = false

local function toggle_size()
  if is_toggled then
    nvimTree.resize(30)
  else
    nvimTree.resize("98%")
  end

  is_toggled = not is_toggled
end

return {
  toggle_size = toggle_size
}
