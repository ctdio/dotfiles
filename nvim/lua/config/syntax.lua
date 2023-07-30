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
