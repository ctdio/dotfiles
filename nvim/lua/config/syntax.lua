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
          ["af"] = "@function.outer",
          ["if"] = "@function.inner",
          ["aF"] = "@frame.outer",
          ["iF"] = "@frame.inner",
          ["ab"] = "@block.outer",
          ["ib"] = "@block.inner",
          ["ac"] = "@call.outer",
          ["ic"] = "@call.inner",
          ["as"] = "@assignment.outer",
          ["is"] = "@assignment.inner",
          ["rs"] = "@assignment.rhs",
          ["ls"] = "@assignment.lhs",
          ["al"] = "@loop.outer",
          ["il"] = "@loop.inner",
          ["aP"] = "@parameter.outer",
          ["iP"] = "@parameter.inner",
        },
      },
    },
  })

  vim.filetype.add({
    extension = {
      tf = "hcl",
    },
  })
end

return {
  setup = setup,
}
