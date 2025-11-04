local function setup()
  -- setup treesitter
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
      -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
      -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
      -- Using this option may slow down your editor, and you may see some duplicate highlights.
      -- Instead of true it can also be a list of languages
      additional_vim_regex_highlighting = false,
      is_supported = function()
        if
          vim.fn.strwidth(vim.fn.getline(".")) > 300
          or vim.fn.getfsize(vim.fn.expand("%")) > 1024 * 1024
        then
          return false
        else
          return true
        end
      end,
    },
    autotag = {
      enable = true,
    },
    textsubjects = {
      enable = true,
      prev_selection = ",", -- (Optional) keymap to select the previous selection
      keymaps = {
        ["."] = "textsubjects-smart",
        [";"] = "textsubjects-container-outer",
        ["i;"] = "textsubjects-container-inner",
      },
    },
    textobjects = {
      select = {
        enable = true,

        -- Automatically jump forward to textobj, similar to targets.vim
        lookahead = true,

        keymaps = {
          -- functions/methods
          ["af"] = "@function.outer",
          ["if"] = "@function.inner",

          ["ai"] = "@conditional.outer",
          ["ii"] = "@conditional.inner",

          -- block
          ["ab"] = "@block.outer",
          ["ib"] = "@block.inner",

          -- function calls
          ["ac"] = "@call.outer",
          ["ic"] = "@call.inner",

          -- classes
          ["aC"] = "@class.outer",
          ["iC"] = "@class.inner",

          -- assignment
          ["a="] = "@assignment.outer",
          ["i="] = "@assignment.inner",
          ["r="] = "@assignment.rhs",
          ["l="] = "@assignment.lhs",

          -- loops
          ["al"] = "@loop.outer",
          ["il"] = "@loop.inner",

          -- parameters
          ["aa"] = "@parameter.outer",
          ["ia"] = "@parameter.inner",

          -- numbers
          ["in"] = "@number.inner",
        },
      },

      move = {
        enable = true,
        set_jumps = true,
        goto_next_start = {
          -- functions/methods
          ["]f"] = "@function.outer",

          ["]i"] = "@conditional.outer",

          -- block
          ["]b"] = "@block.outer",

          -- classes
          ["]c"] = "@call.outer",

          -- assignment
          ["]="] = "@assignment.outer",

          -- loops
          ["]l"] = "@loop.outer",

          -- parameters
          ["]a"] = "@parameter.outer",

          -- numbers
          ["]n"] = "@number.inner",
        },
        goto_next_end = {
          -- functions/methods
          ["]F"] = "@function.outer",

          ["]I"] = "@conditional.outer",

          -- block
          ["]B"] = "@block.outer",

          -- function calls
          ["]C"] = "@call.outer",

          -- assignment
          ["]+"] = "@assignment.outer",

          -- loops
          ["]L"] = "@loop.outer",

          -- parameters
          ["]A"] = "@parameter.outer",

          -- numbers
          ["]N"] = "@number.inner",
        },
        goto_previous_start = {
          -- functions/methods
          ["[f"] = "@function.outer",

          ["[i"] = "@conditional.outer",

          -- block
          ["[b"] = "@block.outer",

          -- function calls
          ["[c"] = "@call.outer",

          -- assignment
          ["[="] = "@assignment.outer",

          -- loops
          ["[l"] = "@loop.outer",

          -- parameters
          ["[a"] = "@parameter.outer",

          -- numbers
          ["[n"] = "@number.inner",
        },
        goto_previous_end = {
          -- functions/methods
          ["[F"] = "@function.outer",

          ["[i"] = "@conditional.outer",

          -- block
          ["[B"] = "@block.outer",

          -- classes
          ["[C"] = "@call.outer",

          -- assignment
          ["[+"] = "@assignment.outer",

          -- loops
          ["[L"] = "@loop.outer",

          -- parameters
          ["[A"] = "@parameter.outer",

          -- numbers
          ["[N"] = "@number.inner",
        },
      },
    },
  })

  require("ts_context_commentstring").setup({
    enable_autocmd = false,
  })

  local ts_repeat_move = require("nvim-treesitter.textobjects.repeatable_move")

  vim.keymap.set({ "n", "x", "o" }, ";", ts_repeat_move.repeat_last_move)
  vim.keymap.set(
    { "n", "x", "o" },
    ",",
    ts_repeat_move.repeat_last_move_opposite
  )
  -- make builtin f, F, t, T also repeatable with ; and ,
  vim.keymap.set({ "n", "x", "o" }, "f", ts_repeat_move.builtin_f)
  vim.keymap.set({ "n", "x", "o" }, "F", ts_repeat_move.builtin_F)
  vim.keymap.set({ "n", "x", "o" }, "t", ts_repeat_move.builtin_t)
  vim.keymap.set({ "n", "x", "o" }, "T", ts_repeat_move.builtin_T)

  vim.filetype.add({
    extension = {
      tf = "hcl",
    },
  })

  -- add keybinds for gitsigns
  local gs = require("gitsigns")

  local next_hunk_repeat, prev_hunk_repeat =
    ts_repeat_move.make_repeatable_move_pair(gs.next_hunk, gs.prev_hunk)

  vim.keymap.set({ "n", "x", "o" }, "]h", next_hunk_repeat)
  vim.keymap.set({ "n", "x", "o" }, "[h", prev_hunk_repeat)

  require("render-markdown").setup({
    file_types = { "Avante" },
  })
end

return {
  setup = setup,
}
