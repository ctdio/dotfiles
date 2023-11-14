local function setup()
  -- setup treesitter
  require("nvim-treesitter.configs").setup({
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
      "toml",
      "astro",
      "markdown",
      "markdown_inline",
      "proto",
    },
    highlight = {
      enable = true,
      -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
      -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
      -- Using this option may slow down your editor, and you may see some duplicate highlights.
      -- Instead of true it can also be a list of languages
      additional_vim_regex_highlighting = false,
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
          ["]R"] = "@assignment.rhs",

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
  local ts_repeat_move = require("nvim-treesitter.textobjects.repeatable_move")

  -- Repeat movement with ; and ,
  -- ensure ; goes forward and , goes backward regardless of the last direction
  --[[
     [vim.keymap.set({ "n", "x", "o" }, ";", ts_repeat_move.repeat_last_move_next)
     [vim.keymap.set(
     [  { "n", "x", "o" },
     [  ",",
     [  ts_repeat_move.repeat_last_move_previous
     [)
     ]]
  vim.keymap.set({ "n", "x", "o" }, ";", ts_repeat_move.repeat_last_move)
  vim.keymap.set(
    { "n", "x", "o" },
    ",",
    ts_repeat_move.repeat_last_move_opposite
  )

  vim.filetype.add({
    extension = {
      tf = "hcl",
    },
  })
end

return {
  setup = setup,
}
