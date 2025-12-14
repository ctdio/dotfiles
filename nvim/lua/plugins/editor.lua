-- Editor plugins: editing enhancements, formatting, text objects

return {
  -- Surround text objects
  {
    "kylechui/nvim-surround",
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup({})
    end,
  },

  -- Repeat plugin commands
  {
    "tpope/vim-repeat",
    event = "VeryLazy",
  },

  -- Commenting
  {
    "numToStr/Comment.nvim",
    event = "VeryLazy",
    dependencies = { "JoosepAlviste/nvim-ts-context-commentstring" },
    config = function()
      require("Comment").setup({
        pre_hook = require(
          "ts_context_commentstring.integrations.comment_nvim"
        ).create_pre_hook(),
      })
    end,
  },

  -- Context-aware commentstring
  {
    "JoosepAlviste/nvim-ts-context-commentstring",
    lazy = true,
    config = function()
      require("ts_context_commentstring").setup({
        enable_autocmd = false,
      })
    end,
  },

  -- Autopairs
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      require("nvim-autopairs").setup({
        check_ts = true,
      })
    end,
  },

  -- Indent guides
  {
    "lukas-reineke/indent-blankline.nvim",
    event = "VeryLazy",
    main = "ibl",
    config = function()
      require("ibl").setup()
    end,
  },

  -- Text case conversion
  {
    "johmsalas/text-case.nvim",
    event = "VeryLazy",
    config = function()
      require("textcase").setup()
    end,
  },

  -- Formatting
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    config = function()
      require("conform").setup({
        format_on_save = {
          timeout_ms = 3000,
          lsp_format = "fallback",
        },
        formatters_by_ft = {
          lua = { "stylua" },
          python = { "ruff_format" },
          json = { "prettierd" },
          javascript = { "prettierd" },
          javascriptreact = { "prettierd" },
          typescript = { "prettierd" },
          typescriptreact = { "prettierd" },
          go = { "gofmt" },
          rust = { "rustfmt" },
        },
      })
    end,
  },

  -- Easy alignment
  {
    "junegunn/vim-easy-align",
    cmd = "EasyAlign",
    keys = {
      { "ga", "<Plug>(EasyAlign)", mode = { "n", "x" }, desc = "Easy Align" },
    },
  },

  -- Comment boxes
  {
    "LudoPinelli/comment-box.nvim",
    cmd = { "CBllbox", "CBlcbox", "CBcatalog" },
  },

  -- EditorConfig
  {
    "editorconfig/editorconfig-vim",
    event = "VeryLazy",
  },

  -- Snippets
  {
    "L3MON4D3/LuaSnip",
    version = "v2.*",
    build = "make install_jsregexp || true", -- Don't fail if build fails
    event = "InsertEnter",
    dependencies = { "rafamadriz/friendly-snippets" },
    config = function()
      local luasnip = require("luasnip")
      require("luasnip.loaders.from_vscode").lazy_load()
      require("luasnip.loaders.from_vscode").lazy_load({
        paths = { vim.fn.stdpath("config") .. "/snippets" },
      })
      luasnip.filetype_extend("typescript", { "javascript" })
      luasnip.filetype_extend("typescriptreact", { "javascript" })
    end,
  },

  -- Friendly snippets
  {
    "rafamadriz/friendly-snippets",
    lazy = true,
  },

  -- Search and replace
  {
    "nvim-pack/nvim-spectre",
    cmd = "Spectre",
    keys = {
      {
        "<leader>F",
        function()
          require("spectre").toggle()
        end,
        desc = "Toggle Spectre",
      },
      {
        "<leader>fw",
        function()
          require("spectre").open_visual({ select_word = true })
        end,
        desc = "Search word",
      },
      {
        "<leader>fw",
        function()
          require("spectre").open_visual()
        end,
        mode = "v",
        desc = "Search selection",
      },
      {
        "<leader>fp",
        function()
          require("spectre").open_file_search({ select_word = true })
        end,
        desc = "Search in file",
      },
    },
    config = function()
      require("spectre").setup({
        replace_engine = {
          ["sed"] = {
            cmd = "sed",
            args = { "-i", "", "-E" },
          },
        },
      })
    end,
  },

  -- Zen mode
  {
    "folke/zen-mode.nvim",
    cmd = "ZenMode",
    config = function()
      require("zen-mode").setup()
    end,
  },

  -- Limelight (focus mode)
  {
    "junegunn/limelight.vim",
    cmd = "Limelight",
  },

  -- Auto-close inactive buffers
  {
    "chrisgrieser/nvim-early-retirement",
    event = "VeryLazy",
    config = function()
      require("early-retirement").setup({
        retirementAgeMins = 10,
        ignoredFiletypes = { "sql" },
      })
    end,
  },

  -- Obsidian integration
  {
    "epwalsh/obsidian.nvim",
    ft = "markdown",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("obsidian").setup({
        workspaces = {
          { name = "personal", path = "~/obsidian" },
        },
        notes_subdir = "Notes",
        note_id_func = function(title)
          local dateTable = os.date("*t", os.time())
          return string.format(
            "%04d-%02d-%02d-%02d%02d-%s.md",
            dateTable.year,
            dateTable.month,
            dateTable.day,
            dateTable.hour,
            dateTable.min,
            title
          )
        end,
      })
    end,
  },

  -- Render markdown
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown", "Avante" },
    config = function()
      require("render-markdown").setup({
        file_types = { "Avante" },
      })
    end,
  },

  -- Image pasting
  {
    "HakonHarnes/img-clip.nvim",
    event = "VeryLazy",
    config = function()
      require("img-clip").setup()
    end,
  },

  -- Jupyter notebooks
  {
    "goerz/jupytext.vim",
    ft = { "python", "ipynb" },
  },

  -- Clipboard
  {
    "ahw/vim-pbcopy",
    event = "VeryLazy",
  },
}
