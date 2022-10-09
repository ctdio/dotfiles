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

  " lsp/completion
  Plug 'neovim/nvim-lspconfig'
  Plug 'hrsh7th/cmp-nvim-lsp'
  Plug 'hrsh7th/cmp-buffer'
  Plug 'hrsh7th/cmp-path'
  Plug 'hrsh7th/cmp-cmdline'
  Plug 'hrsh7th/nvim-cmp'
  Plug 'hrsh7th/vim-vsnip'
  Plug 'hrsh7th/vim-vsnip-integ'
  Plug 'rafamadriz/friendly-snippets'
  Plug 'tzachar/cmp-tabnine', { 'do': './install.sh' }
  Plug 'folke/trouble.nvim'

  " start screen
  Plug 'mhinz/vim-startify'
  Plug 'feline-nvim/feline.nvim'

  " colorscheme
  Plug 'catppuccin/nvim'

  " writing
  Plug 'junegunn/goyo.vim'
  Plug 'junegunn/limelight.vim'

  " git integration
  Plug 'tpope/vim-fugitive'
  Plug 'pwntester/octo.nvim'
  Plug 'lewis6991/gitsigns.nvim'
  Plug 'sindrets/diffview.nvim'

  " text editing
  Plug 'danilamihailov/beacon.nvim'
  Plug 'tpope/vim-surround'
  Plug 'scrooloose/nerdcommenter'
  Plug 'editorconfig/editorconfig-vim'
  Plug 'LudoPinelli/comment-box.nvim'

  " search/nav
  Plug 'nvim-lua/plenary.nvim'
  Plug 'nvim-telescope/telescope.nvim'
  Plug 'nvim-telescope/telescope-dap.nvim'
  Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'make' }
  Plug 'LukasPietzschmann/telescope-tabs'
  Plug 'phaazon/hop.nvim'
  Plug 'kyazdani42/nvim-web-devicons' " for file icons
  Plug 'kyazdani42/nvim-tree.lua'
  Plug 'akinsho/bufferline.nvim', { 'tag': 'v2.*' }

  " utils
  Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && yarn install'  }
  Plug 'sbdchd/neoformat'
  Plug 'ahw/vim-pbcopy'
  Plug 'tyru/open-browser.vim'
  Plug 'tyru/open-browser-github.vim'
  Plug 'kevinhwang91/promise-async'
  Plug 'kevinhwang91/nvim-ufo'

  " debugging
  Plug 'mfussenegger/nvim-dap'
  Plug 'mfussenegger/nvim-dap-python'
  Plug 'leoluz/nvim-dap-go'
  Plug 'mxsdev/nvim-dap-vscode-js'

  Plug 'rcarriga/nvim-dap-ui'
  Plug 'Pocco81/dap-buddy.nvim'
  Plug 'theHamsta/nvim-dap-virtual-text'
  Plug 'rcarriga/nvim-notify'

  " testing
  Plug 'antoinemadec/FixCursorHold.nvim'
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
" copy selected text to clipboard
let g:vim_pbcopy_local_cmd = 'pbcopy'

autocmd BufWritePre * :%s/\s\+$//e
autocmd BufRead,BufEnter *.astro set filetype=astro

filetype plugin indent on

" use zsh shell
set shell=zsh\ -l

" enable folding
set foldenable
set foldcolumn=1
set foldlevel=99
set foldlevelstart=99

set noswapfile
set expandtab
set tabstop=2
set softtabstop=2
set shiftwidth=2
set number
set linebreak
set nocompatible
set hidden
set nobackup
set nowritebackup
set clipboard=unnamed
set backspace=indent,eol,start
set splitbelow " horizontal splits go below
set splitright " vertical splits go to the right
set spelllang=en_us

" Prepare config for theming
set termguicolors
syntax on
set cursorline
set colorcolumn=80
highlight ColorColumn ctermbg=0 guibg=grey

" ╭──────────────────────────────────────────────────────────╮
" │                      Setup plugins                       │
" ╰──────────────────────────────────────────────────────────╯
:lua << EOF
  require('config.theme').setup()
  require('config.syntax').setup()
  require('config.navigation').setup()
  require('config.debug').setup()
  require('config.test').setup()
  require('config.git').setup()
  require('config.lsp').setup()
EOF

" ╭──────────────────────────────────────────────────────────╮
" │                       Setup theme                        │
" ╰──────────────────────────────────────────────────────────╯

" latte (light)
" frappe
" macchiato
" mocha (dark)
let g:catppuccin_flavour = "mocha"

" colorscheme catppuccin

" ╭──────────────────────────────────────────────────────────╮
" │                Configure custom mappings                 │
" ╰──────────────────────────────────────────────────────────╯
" NOTE: completion mappings live in ./lua/config/completion.lua
map , <leader>
map <leader>n :NvimTreeToggle<CR>
map <leader>f :NvimTreeFindFile<CR>
map <leader>b :Telescope buffers<CR>
map <leader>g :Telescope telescope-tabs list_tabs<CR>
map <leader>z :Telescope spell_suggest<CR>
map <leader>a :HopChar1<CR>
map <leader>s :lua require('spell-check-util').toggle_spell_check()<CR>
map <leader>p :Neoformat<CR>
map <leader>da :lua require('debugHelper').attach_to_inspector()<CR>
map <leader>db :lua require('dap').toggle_breakpoint()<CR>
map <leader>dc :lua require('dap').continue()<CR>
map <leader>dsv :lua require('dap').step_over()<CR>
map <leader>dsi :lua require('dap').step_into()<CR>
map <leader>dso :lua require('dap').step_out()<CR>
map <leader>du :lua require('dapui').toggle()<CR>

map <leader>ta :lua require("neotest").run.attach()<CR>
map <leader>td :lua require("neotest").run.run({strategy = "dap"})<CR>
map <leader>tt :lua require("neotest").run.run()<CR>
map <leader>tf :lua require("neotest").run.run(vim.fn.expand("%"))<CR>
map <leader>to :lua require("neotest").output.open({ enter = true })<CR>
map <leader>ts :lua require("neotest").summary.toggle()<CR>

map <leader>l :Limelight!!<CR>

imap <expr> <C-i> vsnip#expandable() ? '<Plug>(vsnip-expand)' : '<C-i>'
smap <expr> <C-i> vsnip#expandable() ? '<Plug>(vsnip-expand)' : '<C-i>'

map <C-p> :Telescope find_files<enter>
map <C-a> :Telescope live_grep<enter>
map <C-c> <esc>

" ╭──────────────────────────────────────────────────────────╮
" │                Configure custom commands                 │
" ╰──────────────────────────────────────────────────────────╯
command Light :Catppuccin latte
command Dark :Catppuccin mocha
