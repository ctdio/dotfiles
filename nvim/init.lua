-- NOTE: this requires ripgrep and fd to be installed
-- to have everything working correctly

-- Enable bytecode caching for faster startup
vim.loader.enable()

-- ╭──────────────────────────────────────────────────────────╮
-- │                  Bootstrap lazy.nvim                     │
-- ╰──────────────────────────────────────────────────────────╯
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=stable",
    lazyrepo,
    lazypath,
  })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- ╭──────────────────────────────────────────────────────────╮
-- │                     Set vim options                      │
-- ╰──────────────────────────────────────────────────────────╯
-- use project-local prettier
vim.g.neoformat_try_node_exe = 1
vim.g.neoformat_enabled_sql = {}
-- copy selected text to clipboard
vim.g.vim_pbcopy_local_cmd = "pbcopy"
vim.g.camelsnek_alternative_camel_commands = 1
vim.g.db_ui_use_nvim_notify = 1
vim.g.jupytext_fmt = "py"

-- Leader key (set before loading plugins)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- use zsh shell
vim.opt.shell = "zsh -l"

-- enable folding
vim.opt.foldenable = true
vim.opt.foldcolumn = "1"
vim.opt.foldmethod = "manual"
vim.opt.foldlevel = 200
vim.opt.foldlevelstart = 200

vim.opt.swapfile = false
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 2
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.linebreak = true
vim.opt.compatible = false
vim.opt.hidden = true
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.clipboard = "unnamed"
vim.opt.backspace = "indent,eol,start"
vim.opt.splitbelow = true
vim.opt.splitright = true

vim.opt.laststatus = 3
vim.opt.splitkeep = "screen"

-- Theming
vim.opt.termguicolors = true
vim.opt.cursorline = true
vim.opt.guicursor = "n-v-c-sm:block,i-ci-ve:ver1,r-cr-o:hor20"

vim.opt.colorcolumn = "80"
vim.opt.spell = true

vim.cmd("filetype plugin indent on")
vim.cmd("syntax on")
vim.cmd("highlight ColorColumn ctermbg=0 guibg=grey")

-- ╭──────────────────────────────────────────────────────────╮
-- │                      Autocommands                        │
-- ╰──────────────────────────────────────────────────────────╯
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  callback = function()
    local save_cursor = vim.fn.getpos(".")
    vim.cmd([[%s/\s\+$//e]])
    vim.fn.setpos(".", save_cursor)
  end,
})

vim.api.nvim_create_autocmd({ "BufRead", "BufEnter" }, {
  pattern = "*.astro",
  callback = function()
    vim.bo.filetype = "astro"
  end,
})

-- ╭──────────────────────────────────────────────────────────╮
-- │                     Setup plugins                        │
-- ╰──────────────────────────────────────────────────────────╯
require("lazy").setup({
  spec = {
    { import = "plugins" },
  },
  defaults = {
    lazy = true,
  },
  install = {
    colorscheme = { "kanso-zen", "habamax" },
  },
  checker = {
    enabled = false,
  },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "matchit",
        "matchparen",
        "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})

-- ╭──────────────────────────────────────────────────────────╮
-- │                Configure custom mappings                 │
-- ╰──────────────────────────────────────────────────────────╯
-- NOTE: Most mappings have been moved to the plugin configs
vim.keymap.set({ "n", "v" }, ",", "<leader>", { remap = true })
vim.keymap.set("n", "<leader>e", ":e!<CR>")
vim.keymap.set("n", "<leader>gd", ":DiffviewOpen<CR>")
vim.keymap.set("n", "<leader>gb", ":Git blame<CR>")
vim.keymap.set("n", "<leader>l", ":Limelight!!<CR>")

-- Start interactive EasyAlign in visual mode (e.g. vipga)
vim.keymap.set("x", "ga", "<Plug>(EasyAlign)")
-- Start interactive EasyAlign for a motion/text object (e.g. gaip)
vim.keymap.set("n", "ga", "<Plug>(EasyAlign)")

-- force myself to break bad habits
vim.keymap.set("i", "<C-c>", "<NOP>")
vim.keymap.set("i", "<C-p>", "<NOP>")
vim.keymap.set("i", "<C-n>", "<NOP>")

vim.keymap.set("n", "-", ":Oil<CR>")

-- Expand snippets
vim.keymap.set("i", "<C-j>", function()
  if require("luasnip").expand_or_jumpable() then
    return "<Plug>luasnip-expand-or-jump"
  end
  return "<C-j>"
end, { expr = true })
vim.keymap.set("s", "<C-j>", function()
  if require("luasnip").expand_or_jumpable() then
    return "<Plug>luasnip-expand-or-jump"
  end
  return "<C-j>"
end, { expr = true })

-- Snacks notifier
vim.keymap.set("n", "<leader>ns", function()
  Snacks.notifier.hide()
end)

-- ╭──────────────────────────────────────────────────────────╮
-- │                Configure custom commands                 │
-- ╰──────────────────────────────────────────────────────────╯
vim.api.nvim_create_user_command("Light", "colorscheme dayfox", {})
vim.api.nvim_create_user_command("Dark", "colorscheme kanagawa-dragon", {})
vim.api.nvim_create_user_command("SR", "SnipRun", {})
