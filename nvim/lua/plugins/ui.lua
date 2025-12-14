-- UI plugins: colorscheme, statusline, bufferline, icons
-- These load immediately for instant visual feedback

return {
  -- Colorschemes
  {
    "webhooked/kanso.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd("colorscheme kanso-zen")
    end,
  },
  {
    "rebelot/kanagawa.nvim",
    lazy = true,
  },
  {
    "EdenEast/nightfox.nvim",
    lazy = true,
  },
  {
    "sainnhe/everforest",
    lazy = true,
  },

  -- Icons (dependency for many plugins)
  {
    "kyazdani42/nvim-web-devicons",
    lazy = false,
  },

  -- Statusline
  {
    "nvim-lualine/lualine.nvim",
    lazy = false,
    dependencies = { "folke/noice.nvim" },
    config = function()
      require("lualine").setup({
        sections = {
          lualine_x = {
            "encoding",
            "fileformat",
            {
              require("noice").api.status.mode.get,
              cond = require("noice").api.status.mode.has,
              color = { fg = "#ff9e64" },
            },
          },
        },
      })
    end,
  },

  -- Bufferline/Tabline
  {
    "akinsho/bufferline.nvim",
    lazy = false,
    version = "*",
    config = function()
      require("bufferline").setup({
        options = {
          separator_style = "slant",
          diagnostics = "nvim_lsp",
          mode = "tabs",
          always_show_bufferline = false,
        },
      })
    end,
  },

  -- Better messages and cmdline
  {
    "folke/noice.nvim",
    lazy = false,
    dependencies = {
      "MunifTanjim/nui.nvim",
    },
    config = function()
      require("noice").setup({
        lsp = {
          override = {
            ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
            ["vim.lsp.util.stylize_markdown"] = true,
            ["cmp.entry.get_documentation"] = true,
          },
        },
        presets = {
          bottom_search = true,
          command_palette = true,
          long_message_to_split = true,
          inc_rename = false,
          lsp_doc_border = false,
        },
      })
    end,
  },

  -- Better vim.ui
  {
    "stevearc/dressing.nvim",
    event = "VeryLazy",
    config = function()
      require("dressing").setup({})
    end,
  },

  -- Cursor beacon
  {
    "danilamihailov/beacon.nvim",
    event = "VeryLazy",
  },
}
