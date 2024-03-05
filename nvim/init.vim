" NOTE: this requires ripgrep and fd need to be installedj
" to have everything working correctly

" ╭──────────────────────────────────────────────────────────╮
" │                  Auto install vim-plug                   │
" ╰──────────────────────────────────────────────────────────╯
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" ╭──────────────────────────────────────────────────────────╮
" │                     Install Plugins                      │
" ╰──────────────────────────────────────────────────────────╯
call plug#begin('~/.vim/plugged')
  " highlighting
  Plug 'tjvr/vim-nearley'
  " Updating the parsers on treesitter update is recommended
  Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
  Plug 'nvim-treesitter/nvim-treesitter-textobjects'
  Plug 'RRethy/nvim-treesitter-textsubjects'

  " lsp/completion
  Plug 'folke/neodev.nvim'
  Plug 'neovim/nvim-lspconfig'
  Plug 'hrsh7th/nvim-cmp'
  Plug 'hrsh7th/cmp-nvim-lsp'
  Plug 'hrsh7th/cmp-nvim-lsp-signature-help'
  Plug 'hrsh7th/cmp-buffer'
  Plug 'hrsh7th/cmp-path'
  Plug 'hrsh7th/cmp-cmdline'
  Plug 'folke/trouble.nvim'
  Plug 'rafamadriz/friendly-snippets'
  Plug 'L3MON4D3/LuaSnip', {'tag': 'v2.*', 'do': 'make install_jsregexp'}
  Plug 'saadparwaiz1/cmp_luasnip'
  Plug 'nvimdev/lspsaga.nvim'
  Plug 'zbirenbaum/copilot.lua'
  Plug 'zbirenbaum/copilot-cmp'
  Plug 'pmizio/typescript-tools.nvim'
  Plug 'dmmulroy/tsc.nvim' " for workspace diagnostics

  " statusline
  Plug 'nvim-lualine/lualine.nvim'

  " colorscheme
  " Plug 'catppuccin/nvim'
  " Plug 'nyoom-engineering/oxocarbon.nvim'
  " Plug 'folke/tokyonight.nvim'
  Plug 'rebelot/kanagawa.nvim'

  " writing
  Plug 'folke/zen-mode.nvim'
  Plug 'junegunn/limelight.vim'

  " git integration
  Plug 'tpope/vim-fugitive'
  Plug 'lewis6991/gitsigns.nvim'
  Plug 'sindrets/diffview.nvim'

  " text editing
  Plug 'danilamihailov/beacon.nvim'
  Plug 'kylechui/nvim-surround'
  Plug 'tpope/vim-repeat'
  Plug 'numToStr/Comment.nvim'
  Plug 'editorconfig/editorconfig-vim'
  Plug 'LudoPinelli/comment-box.nvim'
  Plug 'kevinhwang91/promise-async'
  Plug 'sbdchd/neoformat', { 'on': 'Neoformat' }
  Plug 'nicwest/vim-camelsnek'
  Plug 'junegunn/vim-easy-align'
  Plug 'windwp/nvim-autopairs'
  Plug 'lukas-reineke/indent-blankline.nvim'
  Plug 'johmsalas/text-case.nvim'
  Plug 'windwp/nvim-ts-autotag'
  Plug 'JoosepAlviste/nvim-ts-context-commentstring'

  " jupyter notebooks
  Plug 'goerz/jupytext.vim'

  " search/nav
  Plug 'nvim-lua/plenary.nvim'
  Plug 'nvim-telescope/telescope.nvim'
  Plug 'nvim-telescope/telescope-dap.nvim'
  Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'make' }
  Plug 'nvim-telescope/telescope-live-grep-args.nvim'
  Plug 'nvim-telescope/telescope-smart-history.nvim'
  Plug 'benfowler/telescope-luasnip.nvim'
  Plug 'kyazdani42/nvim-web-devicons' " for file icons
  Plug 'kyazdani42/nvim-tree.lua', { 'on': 'NvimTreeToggle' }
  Plug 'akinsho/bufferline.nvim', { 'tag': 'v3.*' }
  Plug 'kkharji/sqlite.lua'
  Plug 'nvim-pack/nvim-spectre'
  Plug 'stevearc/oil.nvim'
  Plug 'thePrimeagen/harpoon', { 'tag': 'harpoon2' }
  Plug 'andymass/vim-matchup'


  " utils
  Plug 'MunifTanjim/nui.nvim'
  Plug 'ahw/vim-pbcopy'
  Plug 'tyru/open-browser.vim'
  Plug 'tyru/open-browser-github.vim'
  Plug 'glacambre/firenvim', { 'do': { _ -> firenvim#install(0) } }
  Plug 'tpope/vim-dadbod'
  Plug 'kristijanhusak/vim-dadbod-ui'
  Plug 'kristijanhusak/vim-dadbod-completion'
  Plug 'nvim-lua/plenary.nvim'
  Plug 'jellydn/CopilotChat.nvim'
  Plug 'tpope/vim-dotenv'
  Plug 'folke/noice.nvim'
  Plug 'AckslD/nvim-neoclip.lua'
  Plug 'antoinemadec/FixCursorHold.nvim'
  Plug 'epwalsh/obsidian.nvim'

  "" session
  Plug 'rmagatti/auto-session'
  Plug 'rmagatti/session-lens'

  " debugging
  Plug 'mfussenegger/nvim-dap'
  Plug 'mfussenegger/nvim-dap-python'
  Plug 'leoluz/nvim-dap-go'
  Plug 'mxsdev/nvim-dap-vscode-js'

  Plug 'rcarriga/nvim-dap-ui'
  Plug 'Pocco81/dap-buddy.nvim'
  Plug 'theHamsta/nvim-dap-virtual-text'
  Plug 'rcarriga/nvim-notify'
  Plug 'michaelb/sniprun', { 'do': 'sh install.sh' }

  " testing
  Plug 'nvim-neotest/neotest'
  Plug 'nvim-neotest/neotest-go'
  Plug 'nvim-neotest/neotest-python'
  Plug 'haydenmeade/neotest-jest'
  Plug 'marilari88/neotest-vitest'
  Plug 'rouge8/neotest-rust'
  Plug 'jfpedroza/neotest-elixir'
call plug#end()

" ╭──────────────────────────────────────────────────────────╮
" │                     Set vim options                      │
" ╰──────────────────────────────────────────────────────────╯
" use project-local prettier
let g:neoformat_try_node_exe = 1
let g:neoformat_enabled_sql = []
" copy selected text to clipboard
let g:vim_pbcopy_local_cmd = 'pbcopy'
let g:firenvim_config = {
  \ 'globalSettings': {
    \ 'alt': 'all',
  \  },
  \ 'localSettings': {
    \ '.*': {
      \ 'cmdline': 'neovim',
      \ 'content': 'text',
      \ 'priority': 0,
      \ 'selector': 'textarea',
      \ 'takeover': 'never',
    \ },
  \ }
\ }

let g:camelsnek_alternative_camel_commands = 1
let g:db_ui_use_nvim_notify = 1

function! s:env(var) abort
  return exists('*DotenvGet') ? DotenvGet(a:var) : eval('$'.a:var)
endfunction

autocmd BufWritePre * :%s/\s\+$//e
autocmd BufRead,BufEnter *.astro set filetype=astro

filetype plugin indent on

let g:jupytext_fmt = 'py'


" use zsh shell
set shell=zsh\ -l

" enable folding
set foldenable
set foldcolumn=1
set foldmethod=manual
set foldlevel=200
set foldlevelstart=200

inoremap <c-p> <nop>
inoremap <c-n> <nop>

set noswapfile
set expandtab
set tabstop=4
set softtabstop=4
set shiftwidth=2
set number
set relativenumber
set linebreak
set nocompatible
set hidden
set nobackup
set nowritebackup
set clipboard=unnamed
set backspace=indent,eol,start
set splitbelow " horizontal splits go below
set splitright " vertical splits go to the right

" Prepare config for theming
set termguicolors
syntax on
set cursorline
set guicursor=n-v-c-sm:block,i-ci-ve:ver1,r-cr-o:hor20

set colorcolumn=80
highlight ColorColumn ctermbg=0 guibg=grey

" neoformat on save
augroup fmt
  autocmd!
  autocmd BufWritePre * silent! undojoin | Neoformat
augroup END

" ╭──────────────────────────────────────────────────────────╮
" │                      Setup plugins                       │
" ╰──────────────────────────────────────────────────────────╯
:lua << EOF
  require('config.edit').setup()
  require('config.theme').setup()
  require('config.syntax').setup()
  require('config.navigation').setup()
  require('config.debug').setup()
  require('config.test').setup()
  require('config.git').setup()
  require('config.lsp').setup()

  -- NOTE: `set spell` in vimscript for some reason does not work, but
  -- setting it here does.
  vim.o.spell = true

  -- setup notify last
  vim.notify = require("notify").setup({
    top_down = false,
  })

EOF

" ╭──────────────────────────────────────────────────────────╮
" │                       Setup theme                        │
" ╰──────────────────────────────────────────────────────────╯

" latte (light)
" frappe
" macchiato
" mocha (dark)
" let g:catppuccin_flavour = "mocha"
" colorscheme catppuccin

colorscheme kanagawa-dragon

" ╭──────────────────────────────────────────────────────────╮
" │                Configure custom mappings                 │
" ╰──────────────────────────────────────────────────────────╯
" NOTE: completion mappings live in ./lua/config/completion.lua
map , <leader>
map <leader>nn :NvimTreeToggle<CR>
map <leader>nf :NvimTreeFindFile<CR>
map <leader>ns :lua require('notify').dismiss()<CR>
map <leader>f :HopChar1<CR>
map <leader>e :e!<CR>

map <leader>gd :DiffviewOpen<CR>
map <leader>gb :Git blame<CR>

nmap <leader>S :lua require("spectre").toggle()<CR>
nmap <leader>sw :lua require("spectre").open_visual({select_word=true})<CR>
vmap <leader>sw :lua require("spectre").open_visual()<CR>
nmap <leader>sp :lua require("spectre").open_file_search({select_word=true})<CR>

map <leader>p :Neoformat<CR>

map <leader>da :lua require('debugHelper').attach_to_inspector()<CR>
map <leader>db :lua require('dap').toggle_breakpoint()<CR>
map <leader>dc :lua require('dap').continue()<CR>
map <leader>dsv :lua require('dap').step_over()<CR>
map <leader>dsi :lua require('dap').step_into()<CR>
map <leader>dso :lua require('dap').step_out()<CR>
map <leader>du :lua require('dapui').toggle({ reset = true })<CR>

map <leader>ta :lua require("neotest").run.attach()<CR>
map <leader>td :lua require("neotest").run.run({strategy = "dap"})<CR>
map <leader>tt :lua require("neotest").run.run()<CR>
map <leader>tf :lua require("neotest").run.run(vim.fn.expand("%"))<CR>
map <leader>to :lua require("neotest").output.open({ enter = true })<CR>
map <leader>ts :lua require("neotest").summary.toggle()<CR>

map <leader>l :Limelight!!<CR>

" Start interactive EasyAlign in visual mode (e.g. vipga)
xmap ga <Plug>(EasyAlign)
" Start interactive EasyAlign for a motion/text object (e.g. gaip)
nmap ga <Plug>(EasyAlign)

" force myself to break bad habits
imap <C-c> <NOP>
map <C-s> :w<CR>

nmap - :Oil<CR>

" Expand snippets
imap <expr> <C-j> luasnip#expand_or_jumpable() ? '<Plug>luasnip-expand-or-jump' : '<C-j>'
smap <expr> <C-j> luasnip#expand_or_jumpable() ? '<Plug>luasnip-expand-or-jump' : '<C-j>'

" ╭──────────────────────────────────────────────────────────╮
" │                Configure custom commands                 │
" ╰──────────────────────────────────────────────────────────╯
command Light :colorscheme kanagawa-lotus
command Dark :colorscheme kanagawa-dragon
command Snip :Telescope luasnip
command SR :SnipRun
command Term :Lspsaga term_toggle
command Inc :Telescope lsp_incoming_calls
command Out :Telescope lsp_outgoing_calls
command ResumeSearch :Telescope resume
