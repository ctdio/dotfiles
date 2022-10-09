local is_toggled = false

local function toggle_spell_check()
  is_toggled = not is_toggled
  if is_toggled then
    vim.cmd("set spell")
  else
    vim.cmd("set spell!")
  end
end

return {
  toggle_spell_check = toggle_spell_check,
}
