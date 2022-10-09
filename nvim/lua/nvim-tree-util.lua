local nvimTree = require("nvim-tree")

local is_toggled = false

local function toggle_size()
  is_toggled = not is_toggled
  if is_toggled then
    vim.cmd("NvimTreeResize +30")
  else
    vim.cmd("NvimTreeResize -30")
  end
end

return {
  toggle_size = toggle_size,
}
