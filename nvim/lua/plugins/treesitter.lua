-- Treesitter and syntax plugins

return {
  -- Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    event = { "BufReadPost", "BufNewFile" },
    build = ":TSUpdate",
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
      "RRethy/nvim-treesitter-textsubjects",
    },
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "astro",
          "diff",
          "elixir",
          "gitcommit",
          "git_rebase",
          "gleam",
          "go",
          "gomod",
          "graphql",
          "hcl",
          "javascript",
          "jsdoc",
          "json",
          "kotlin",
          "lua",
          "markdown",
          "markdown_inline",
          "prisma",
          "proto",
          "python",
          "rust",
          "toml",
          "typescript",
          "vimdoc",
          "yaml",
          "zig",
        },
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
          is_supported = function()
            if
              vim.fn.strwidth(vim.fn.getline(".")) > 300
              or vim.fn.getfsize(vim.fn.expand("%")) > 1024 * 1024
            then
              return false
            end
            return true
          end,
        },
        autotag = { enable = true },
        textsubjects = {
          enable = true,
          prev_selection = ",",
          keymaps = {
            ["."] = "textsubjects-smart",
            [";"] = "textsubjects-container-outer",
            ["i;"] = "textsubjects-container-inner",
          },
        },
        textobjects = {
          select = {
            enable = true,
            lookahead = true,
            keymaps = {
              ["af"] = "@function.outer",
              ["if"] = "@function.inner",
              ["ai"] = "@conditional.outer",
              ["ii"] = "@conditional.inner",
              ["ab"] = "@block.outer",
              ["ib"] = "@block.inner",
              ["ac"] = "@call.outer",
              ["ic"] = "@call.inner",
              ["aC"] = "@class.outer",
              ["iC"] = "@class.inner",
              ["a="] = "@assignment.outer",
              ["i="] = "@assignment.inner",
              ["r="] = "@assignment.rhs",
              ["l="] = "@assignment.lhs",
              ["al"] = "@loop.outer",
              ["il"] = "@loop.inner",
              ["aa"] = "@parameter.outer",
              ["ia"] = "@parameter.inner",
              ["in"] = "@number.inner",
            },
          },
          move = {
            enable = true,
            set_jumps = true,
            goto_next_start = {
              ["]f"] = "@function.outer",
              ["]i"] = "@conditional.outer",
              ["]b"] = "@block.outer",
              ["]c"] = "@call.outer",
              ["]="] = "@assignment.outer",
              ["]l"] = "@loop.outer",
              ["]a"] = "@parameter.outer",
              ["]n"] = "@number.inner",
            },
            goto_next_end = {
              ["]F"] = "@function.outer",
              ["]I"] = "@conditional.outer",
              ["]B"] = "@block.outer",
              ["]C"] = "@call.outer",
              ["]+"] = "@assignment.outer",
              ["]L"] = "@loop.outer",
              ["]A"] = "@parameter.outer",
              ["]N"] = "@number.inner",
            },
            goto_previous_start = {
              ["[f"] = "@function.outer",
              ["[i"] = "@conditional.outer",
              ["[b"] = "@block.outer",
              ["[c"] = "@call.outer",
              ["[="] = "@assignment.outer",
              ["[l"] = "@loop.outer",
              ["[a"] = "@parameter.outer",
              ["[n"] = "@number.inner",
            },
            goto_previous_end = {
              ["[F"] = "@function.outer",
              ["[i"] = "@conditional.outer",
              ["[B"] = "@block.outer",
              ["[C"] = "@call.outer",
              ["[+"] = "@assignment.outer",
              ["[L"] = "@loop.outer",
              ["[A"] = "@parameter.outer",
              ["[N"] = "@number.inner",
            },
          },
        },
      })

      local ts_repeat_move =
        require("nvim-treesitter.textobjects.repeatable_move")
      vim.keymap.set({ "n", "x", "o" }, ";", ts_repeat_move.repeat_last_move)
      vim.keymap.set(
        { "n", "x", "o" },
        ",",
        ts_repeat_move.repeat_last_move_opposite
      )
      vim.keymap.set({ "n", "x", "o" }, "f", ts_repeat_move.builtin_f)
      vim.keymap.set({ "n", "x", "o" }, "F", ts_repeat_move.builtin_F)
      vim.keymap.set({ "n", "x", "o" }, "t", ts_repeat_move.builtin_t)
      vim.keymap.set({ "n", "x", "o" }, "T", ts_repeat_move.builtin_T)

      vim.filetype.add({ extension = { tf = "hcl" } })
    end,
  },

  { "nvim-treesitter/nvim-treesitter-textobjects", lazy = true },
  { "RRethy/nvim-treesitter-textsubjects", lazy = true },

  {
    "windwp/nvim-ts-autotag",
    ft = {
      "html",
      "javascript",
      "javascriptreact",
      "typescript",
      "typescriptreact",
      "vue",
      "svelte",
      "astro",
    },
  },
}
