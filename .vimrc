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
  Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}  " We recommend updating the parsers on update

  " autocomplete
  Plug 'neovim/nvim-lspconfig'
  Plug 'hrsh7th/cmp-nvim-lsp'
  Plug 'hrsh7th/cmp-buffer'
  Plug 'hrsh7th/cmp-path'
  Plug 'hrsh7th/cmp-cmdline'
  Plug 'hrsh7th/nvim-cmp'
  Plug 'hrsh7th/cmp-vsnip'
  Plug 'hrsh7th/cmp-emoji'
  Plug 'rafamadriz/friendly-snippets'
  Plug 'tzachar/cmp-tabnine', { 'do': './install.sh' }

  " start screen
  Plug 'mhinz/vim-startify'
  Plug 'famiu/feline.nvim'

  " colorscheme
  Plug 'bluz71/vim-nightfly-guicolors'
  Plug 'folke/tokyonight.nvim', { 'branch': 'main' }
  Plug 'mangeshrex/uwu.vim'
  Plug 'catppuccin/nvim', {'as': 'catppuccin'}
  Plug 'Mofiqul/vscode.nvim'
  Plug 'marko-cerovac/material.nvim'

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
  Plug 'tami5/sqlite.lua'
  Plug 'nvim-telescope/telescope.nvim'
  Plug 'nvim-telescope/telescope-dap.nvim'
  Plug 'nvim-telescope/telescope-smart-history.nvim'
  Plug 'nvim-telescope/telescope-fzy-native.nvim'
  Plug 'phaazon/hop.nvim'
  Plug 'sidebar-nvim/sidebar.nvim'
  Plug 'kyazdani42/nvim-tree.lua'
  Plug 'kyazdani42/nvim-web-devicons' " for file icons
  Plug 'xuyuanp/nerdtree-git-plugin'

  " utils
  Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && yarn install'  }
  Plug 'prettier/vim-prettier', { 'do': 'npm install' }
  Plug 'ahw/vim-pbcopy'
  Plug 'vim-test/vim-test'
  Plug 'tpope/vim-dispatch'
  Plug 'jbyuki/venn.nvim'
  Plug 'tyru/open-browser.vim'
  Plug 'tyru/open-browser-github.vim'
  Plug 'sindrets/diffview.nvim'
  Plug 'tzachar/cmp-tabnine', { 'do': './install.sh' }

  Plug 'tpope/vim-repeat'

  Plug 'antoinemadec/FixCursorHold.nvim'
  Plug 'nvim-neotest/neotest'
  Plug 'haydenmeade/neotest-jest'

  " debugging
  Plug 'mfussenegger/nvim-dap'
  Plug 'mfussenegger/nvim-dap-python'
  Plug 'leoluz/nvim-dap-go'
  Plug 'mxsdev/nvim-dap-vscode-js'
  Plug 'rcarriga/nvim-dap-ui'
  Plug 'theHamsta/nvim-dap-virtual-text'
call plug#end()

" use zsh shell
set shell=zsh\ -l

" optimization: only use git for signify
let g:signify_vcs_list = [ 'git' ]

autocmd BufWritePre * :%s/\s\+$//e

filetype plugin indent on
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

set foldmethod=marker
set foldmarker=region,endregion
set foldlevelstart=99

set noswapfile

" Theming
if (has("termguicolors"))
  set termguicolors
endif
let g:material_style = "lighter" " material is used for light theme
syntax on
set cursorline
set colorcolumn=80
highlight ColorColumn ctermbg=0 guibg=grey

" copy selected text to clipboard
let g:vim_pbcopy_local_cmd = 'pbcopy'

:lua << EOF
  require("catppuccin").setup({
    integration = {
      nvimtree = {
        enabled = true,
        show_root = true, -- makes the root folder not transparent
        transparent_panel = false, -- make the panel transparent
      }
    }
  })
  vim.cmd[[colorscheme catppuccin]]

  -- setup feline
  require("feline").setup({
    -- components = require('catppuccin.core.integrations.feline'),
  })

  -- setup hop
  require('hop').setup()

  -- setup nvim-tree
  local nvim_tree_callback = require('nvim-tree.config').nvim_tree_callback

  require('nvim-tree').setup({
    view = {
      width = 40,
      mappings = {
        list = {
          { key = 's', cb = nvim_tree_callback('vsplit') },
          { key = 'i', cb = nvim_tree_callback('split') },
          { key = '<S-a>', cb = ':lua require("nvimTreeUtil").toggle_size()<CR>' }
        }
      }
    }
  })

  require('diffview').setup()

  require('sidebar-nvim').setup({
    open = false,
    side = 'right'
  })

  -- setup treesitter
  require('nvim-treesitter.configs').setup {
    ensure_installed = {
      "rust",
      "kotlin",
      "go",
      "gomod",
      "elixir",
      "gleam",
      "jsdoc",
      "javascript",
      "typescript",
      "python",
      "lua",
      "json",
      "graphql",
      "yaml",
      "hcl",
      "toml"
    },
    highlight = {
      enable = true,
      -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
      -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
      -- Using this option may slow down your editor, and you may see some duplicate highlights.
      -- Instead of true it can also be a list of languages
      additional_vim_regex_highlighting = {"kotlin"},
    },
  }

  -- setup telescope
  local telescope_actions = require('telescope.actions')
  require('telescope').setup{
    defaults = {
      mappings = {
        i = {
          ["<C-k>"] = telescope_actions.move_selection_previous,
          ["<C-j>"] = telescope_actions.move_selection_next
        }
      }
    }
  }

  require('telescope').load_extension('fzy_native')
  require('telescope').load_extension('dap')

  local dap = require('dap')

  require('dap-go').setup()
  require('dap-python').setup()
  require('dap-python').setup()
  require("dap-vscode-js").setup({
    adapters = {
      'pwa-node',
      'pwa-chrome',
      'node-terminal',
      'pwa-extensionHost'
    },
  })

  local nodejs_dap_config = {
    {
      type = "pwa-node",
      request = "launch",
      name = "Launch file",
      program = "${file}",
      cwd = "${workspaceFolder}",
    },
    {
      type = "pwa-node",
      request = "attach",
      name = "Attach",
      processId = require'dap.utils'.pick_process,
      cwd = "${workspaceFolder}",
    }
  }

  dap.configurations.typescript = nodejs_dap_config
  dap.configurations.javascript = nodejs_dap_config

  require('nvim-dap-virtual-text').setup()

  -- setup dapui
  require('dapui').setup()

  require('neotest').setup({
    adapters = {
      require('neotest-jest')({
        jestCommand = "yarn jest --"
      })
    }
  })

  -- setup completion
  local nvim_lsp = require('lspconfig')

  -- Use an on_attach function to only map the following keys
  -- after the language server attaches to the current buffer
  local on_attach = function(client, bufnr)
    local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
    local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

    --Enable completion triggered by <c-x><c-o>
    buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

    -- Mappings.
    local opts = { noremap=true, silent=true }

    -- See `:help vim.lsp.*` for documentation on any of the below functions
    buf_set_keymap('n', 'gD', '<Cmd>lua vim.lsp.buf.declaration()<CR>', opts)
    buf_set_keymap('n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
    buf_set_keymap('n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
    buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
    buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
    buf_set_keymap('n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
    buf_set_keymap('n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
    buf_set_keymap('n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
    buf_set_keymap('n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
    buf_set_keymap('n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
    buf_set_keymap('n', '<space>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
    -- buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
    buf_set_keymap('n', 'gr', '<cmd>Telescope lsp_references<CR>', opts)
    buf_set_keymap('n', '<space>e', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)
    buf_set_keymap('n', '[d', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
    buf_set_keymap('n', ']d', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
    buf_set_keymap('n', '<space>q', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)
    buf_set_keymap("n", "<space>f", "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)
  end

  -- Setup nvim-cmp with recommended setup
  local cmp = require('cmp')
  local select_next_item_or_confirm = function(fallback)
    -- This little snippet will confirm with tab, and if no entry is selected, will confirm the first item
    if cmp.visible() then
      local entry = cmp.get_selected_entry()
      if not entry then
        cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
      else
        cmp.confirm()
      end
    else
      fallback()
    end
  end

  local confirm_item = function(fallback)
    -- This little snippet will confirm with tab, and if no entry is selected, will confirm the first item
    if cmp.visible() then
      local entry = cmp.get_selected_entry()
      if entry then
        cmp.confirm()
      else
        fallback()
      end
    else
      fallback()
    end
  end

  cmp.setup({
    snippet = {
      expand = function(args)
        vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
      end,
    },
    mapping = {
      ['<C-d>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
      ['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),
      ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
      ['<C-e>'] = cmp.mapping({
        i = cmp.mapping.abort(),
        c = cmp.mapping.close(),
      }),
      ['<C-n>'] = cmp.mapping({
        c = function()
          if cmp.visible() then
            cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
          else
            vim.api.nvim_feedkeys(t('<Down>'), 'n', true)
          end
        end,
        i = function(fallback)
          if cmp.visible() then
            cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
          else
            fallback()
          end
        end
      }),
      ['<C-p>'] = cmp.mapping({
        c = function()
          if cmp.visible() then
            cmp.select_prev_item({ behavior = cmp.SelectBehavior.Select })
          else
            vim.api.nvim_feedkeys(t('<Up>'), 'n', true)
          end
        end,
        i = function(fallback)
          if cmp.visible() then
            cmp.select_prev_item({ behavior = cmp.SelectBehavior.Select })
          else
            fallback()
          end
        end
      }),
      ["<Tab>"] = cmp.mapping(select_next_item_or_confirm, {"i","s","c",}),
      ['<CR>'] = cmp.mapping(confirm_item, {"i","s","c",}),
    },
    sources = cmp.config.sources({
      { name = 'nvim_lsp' },
      { name = 'dap' },
      { name = 'cmp_tabnine' },
      { name = 'vsnip' }, -- For vsnip users.
      { name = 'emoji' },
    }, {
      { name = 'buffer' },
    })
  })

  -- Use buffer source for `/`.
  cmp.setup.cmdline('/', {
    sources = {
      { name = 'buffer' }
    }
  })

  -- Use cmdline & path source for ':'.
  cmp.setup.cmdline(':', {
    sources = cmp.config.sources({
      { name = 'path' }
    }, {
      { name = 'cmdline' }
    })
  })

  local tabnine = require('cmp_tabnine.config')
  tabnine:setup({
    max_lines = 1000;
    max_num_results = 20;
    sort = true;
    run_on_every_keystroke = true;
    snippet_placeholder = '..';
    ignored_file_types = { -- default is not to ignore
      -- uncomment to ignore in lua:
      -- lua = true
    };
  })

  -- Setup lspconfig.
  local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())

  -- Use a loop to conveniently call 'setup' on multiple servers and
  -- map buffer local keybindings when the language server attaches
  local servers = { "tsserver", "terraformls" }
  for _, lsp in ipairs(servers) do
    nvim_lsp[lsp].setup {
      on_attach = on_attach,
      capabilities = capabilities
    }
  end

  local path_to_kotlin_ls = vim.fn.expand('~/kotlin-language-server/server/build/install/server/bin/kotlin-language-server')
  nvim_lsp.kotlin_language_server.setup {
    cmd = { path_to_kotlin_ls },
    on_attach = on_attach,
    capabilities = capabilities
  }
EOF

" custom mappings
map , <leader>
map <leader>n :NvimTreeToggle<CR>
map <leader>f :NvimTreeFindFile<CR>
map f :HopChar1<CR>
map r :HopChar2<CR>
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

map <C-p> :Telescope find_files<enter>
map <C-a> :Telescope live_grep<enter>
map <C-c> <esc>

command Light :rightbelow colo material
command Dark :rightbelow colo catppuccino
