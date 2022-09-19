" NOTE: this requires ripgrep and fd need to be installed
" to have everything working correctly

" setup plug
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/plugged')
  " highlighting
  Plug 'tjvr/vim-nearley'

  " Updating the parsers on treesitter update is recommended
  Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

  " autocomplete
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

  " start screen
  Plug 'mhinz/vim-startify'
  Plug 'famiu/feline.nvim'

  " colorscheme
  Plug 'bluz71/vim-nightfly-guicolors'
  Plug 'folke/tokyonight.nvim', { 'branch': 'main' }
  Plug 'mangeshrex/uwu.vim'
  " Plug 'pocco81/catppuccino.nvim'
  Plug 'catppuccin/nvim'
  Plug 'Mofiqul/vscode.nvim'

  " writing
  Plug 'junegunn/goyo.vim'

  " note taking
  Plug 'vimwiki/vimwiki'

  " git integration
  Plug 'mhinz/vim-signify'
  Plug 'tpope/vim-fugitive'

  " text editing
  Plug 'tpope/vim-surround'
  Plug 'scrooloose/nerdcommenter'
  Plug 'editorconfig/editorconfig-vim'

  " search/nav
  Plug 'nvim-lua/plenary.nvim'
  Plug 'nvim-telescope/telescope.nvim'
  Plug 'nvim-telescope/telescope-dap.nvim'
  Plug 'nvim-telescope/telescope-fzy-native.nvim'
  Plug 'phaazon/hop.nvim'
  Plug 'kyazdani42/nvim-web-devicons' " for file icons
  Plug 'kyazdani42/nvim-tree.lua'

  " utils
  Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && yarn install'  }
  Plug 'prettier/vim-prettier', { 'do': 'npm install' }
  Plug 'ahw/vim-pbcopy'
  Plug 'vim-test/vim-test'
  Plug 'tpope/vim-dispatch'
  Plug 'David-Kunz/jester'
  Plug 'jbyuki/venn.nvim'
  Plug 'tyru/open-browser.vim'
  Plug 'tyru/open-browser-github.vim'

  " debugging
  Plug 'mfussenegger/nvim-dap'

  Plug 'mfussenegger/nvim-dap-python'
  Plug 'leoluz/nvim-dap-go'
  Plug 'mxsdev/nvim-dap-vscode-js'

  Plug 'rcarriga/nvim-dap-ui'
  Plug 'Pocco81/dap-buddy.nvim'
  Plug 'theHamsta/nvim-dap-virtual-text'

  " temp until treesitter performance improves
  " Plug 'elixir-editors/vim-elixir'
call plug#end()

" Setup all plugins
:lua << EOF
  require('config.theme').setup()
  require('config.syntax').setup()
  require('config.navigation').setup()
  require('config.debug').setup()
  require('config.completion').setup()
EOF

" use zsh shell
set shell=zsh\ -l

" optimization: only use git for signify
let g:signify_vcs_list = [ 'git' ]

autocmd BufWritePre * :%s/\s\+$//e
autocmd BufRead,BufEnter *.astro set filetype=astro

filetype plugin indent on

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

" Theming
if (has("termguicolors"))
  set termguicolors
endif
syntax on
set cursorline
set colorcolumn=80
highlight ColorColumn ctermbg=0 guibg=grey

" latte (light)
" frappe
" macchiato
" mocha (dark)
let g:catppuccin_flavour = "mocha"

colorscheme catppuccin

" copy selected text to clipboard
let g:vim_pbcopy_local_cmd = 'pbcopy'

" custom mappings
map , <leader>
map <leader>n :NvimTreeToggle<CR>
map <leader>f :NvimTreeFindFile<CR>
map <leader>b :Telescope buffers<cr>
map <leader>a :HopChar1<CR>
map <leader>s :lua require('sidebar-nvim').toggle()<CR>
map <leader>da :lua require('debugHelper').attach_to_inspector()<CR>
map <leader>db :lua require('dap').toggle_breakpoint()<CR>
map <leader>dc :lua require('dap').continue()<CR>
map <leader>dsv :lua require('dap').step_over()<CR>
map <leader>dsi :lua require('dap').step_into()<CR>
map <leader>dso :lua require('dap').step_out()<CR>

map <leader>du :lua require('dapui').toggle()<CR>

map <leader>td :lua require("neotest").run.run({strategy = "dap"})<CR>
map <leader>tt :lua require("neotest").run.run()<CR>
map <leader>tf :lua require("neotest").run.run(vim.fn.expand("%"))<CR>
map <leader>to :lua require("neotest").output.open({ enter = true })<CR>
map <leader>ts :lua require("neotest").summary.toggle()<CR>


imap <expr> <C-i> vsnip#expandable() ? '<Plug>(vsnip-expand)' : '<C-i>'
smap <expr> <C-i> vsnip#expandable() ? '<Plug>(vsnip-expand)' : '<C-i>'

map <S-F> :HopChar1<CR>

map <C-p> :Telescope find_files<enter>
map <C-a> :Telescope live_grep<enter>
map <C-c> <esc>

command Light :Catppuccin latte
command Dark :Catppuccin mocha

