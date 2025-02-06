local setup_cmp_completion
local setup_lsp

local function setup()
  require("lspsaga").setup({
    lightbulb = {
      enable = false,
    },
    rename = {
      auto_save = true,
    },
  })

  setup_cmp_completion()
  setup_lsp()

  -- configure trouble for prettier diagnostics
  require("trouble").setup()

  require("tsc").setup({
    use_trouble_qflist = true,
  })
end

setup_cmp_completion = function()
  -- Set up neodev
  require("neodev").setup({
    library = {
      plugins = { "nvim-dap-ui" },
      types = true,
    },
  })

  require("blink-cmp").setup({
    completion = {
      list = {
        selection = {
          preselect = function(ctx)
            return ctx.mode ~= "cmdline"
              and not require("blink.cmp").snippet_active({ direction = 1 })
          end,
        },
      },
    },

    keymap = {
      ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
      ["<C-e>"] = { "hide", "fallback" },
      -- ["<CR>"] = { "accept", "fallback" },
      ["<CR>"] = { "accept", "fallback" },

      ["<Tab>"] = {},
      ["<S-Tab>"] = { "snippet_backward", "fallback" },

      ["<Up>"] = { "select_prev", "fallback" },
      ["<Down>"] = { "select_next", "fallback" },
      ["<C-p>"] = { "select_prev", "fallback" },
      ["<C-n>"] = { "select_next", "fallback" },

      ["<C-b>"] = { "scroll_documentation_up", "fallback" },
      ["<C-f>"] = { "scroll_documentation_down", "fallback" },
    },
    signature = {
      enabled = true,
    },
    sources = {
      default = {
        "lsp",
        "path",
        "snippets",
        "buffer",
        "dadbod",
      },
      providers = {
        dadbod = { name = "Dadbod", module = "vim_dadbod_completion.blink" },
      },
    },
  })
end

setup_lsp = function()
  vim.lsp.set_log_level("off")
  local nvim_lsp = require("lspconfig")

  local opts = { noremap = true, silent = true }
  -- See `:help vim.diagnostic.*` for documentation on any of the below functions
  vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
  vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)

  vim.keymap.set("n", "[q", "<CMD>cprev<CR>", opts)
  vim.keymap.set("n", "]q", "<CMD>cnext<CR>", opts)

  vim.keymap.set("n", "<space>e", vim.diagnostic.open_float, opts)
  -- vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist, opts)
  vim.keymap.set(
    "n",
    "<space>q",
    "<CMD>Trouble diagnostics toggle filter.buf=0<CR>",
    opts
  )
  vim.keymap.set("n", "<space>d", "<CMD>Trouble diagnostics toggle<CR>", opts)
  vim.keymap.set("n", "<space>f", vim.lsp.buf.format, opts)

  -- Use an on_attach function to only map the following keys
  -- after the language server attaches to the current buffer
  local on_attach = function(_client, bufnr)
    -- Mappings.
    local bufopts = { noremap = true, silent = true, buffer = bufnr }

    -- See `:help vim.lsp.*` for documentation on any of the below functions
    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, bufopts)
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, bufopts)
    vim.keymap.set("n", "K", vim.lsp.buf.hover, bufopts)
    vim.keymap.set("n", "gi", vim.lsp.buf.implementation, bufopts)
    vim.keymap.set("n", "]d", vim.diagnostic.goto_next, bufopts)
    vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, bufopts)

    -- vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, bufopts)
    vim.keymap.set("n", "<space>wa", vim.lsp.buf.add_workspace_folder, bufopts)
    vim.keymap.set(
      "n",
      "<space>wr",
      vim.lsp.buf.remove_workspace_folder,
      bufopts
    )
    vim.keymap.set("n", "<space>wl", function()
      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, bufopts)
    vim.keymap.set("n", "<space>D", vim.lsp.buf.type_definition, bufopts)
    -- vim.keymap.set("n", "<space>rn", vim.lsp.buf.rename, bufopts)
    vim.keymap.set("n", "<space>rn", ":Lspsaga rename<CR>", bufopts)
    vim.keymap.set("n", "<space>ca", vim.lsp.buf.code_action, bufopts)
    -- vim.keymap.set(
    --   "n",
    --   "<space>ca",vim.lsp.buf.
    --   require("actions-preview").code_actions,
    --   bufopts
    -- )
    vim.keymap.set("n", "gr", require("fzf-lua").lsp_references, bufopts)
  end

  local capabilities = vim.lsp.protocol.make_client_capabilities()

  capabilities.textDocument.foldingRange = {
    dynamicRegistration = false,
    lineFoldingOnly = true,
  }

  capabilities = require("blink.cmp").get_lsp_capabilities(capabilities)

  -- Use a loop to conveniently call 'setup' on multiple servers and
  -- map buffer local keybindings when the language server attaches
  local servers = {
    "astro",
    "bashls",
    "eslint",
    "gopls",
    "mojo",
    "lua_ls",
    "yamlls",
    "pyright",
    "rust_analyzer",
    "tailwindcss",
    "prismals",
    "zls",
    "vtsls",
  }
  for _, lsp in ipairs(servers) do
    nvim_lsp[lsp].setup({
      on_attach = on_attach,
      capabilities = capabilities,
      detached = false,
      root_dir = nvim_lsp.util.root_pattern(".git"),
    })
  end

  vim.api.nvim_create_user_command("TSA", "VtsExec source_actions", {})

  nvim_lsp.emmet_language_server.setup({
    on_attach = on_attach,
    capabilities = capabilities,
    filetypes = {
      "css",
      "eruby",
      "html",
      "javascript",
      "javascriptreact",
      "less",
      "sass",
      "scss",
      "svelte",
      "pug",
      "typescriptreact",
      "vue",
    },
  })

  nvim_lsp.terraformls.setup({
    on_attach = on_attach,
    capabilities = capabilities,
    filetypes = { "terraform", "terraform-vars", "hcl" },
  })

  -- tweak denols config to avoid conflict with nodejs projects
  -- nvim_lsp.denols.setup({
  --   on_attach = on_attach,
  --   capabilities = capabilities,
  --   root_dir = nvim_lsp.util.root_pattern("deno.json", "deno.jsonc"),
  -- })

  -- lua_ls requires some additional config
  nvim_lsp.lua_ls.setup({
    on_attach = on_attach,
    capabilities = capabilities,
    settings = {
      Lua = {
        runtime = {
          -- neovim uses LuaJIT
          version = "LuaJIT",
        },
        workspace = {
          -- Make the server aware of Neovim runtime files
          library = vim.api.nvim_get_runtime_file("", true),
        },
        diagnostics = {
          -- Get the language server to recognize the `vim` global
          globals = { "vim" },
        },
      },
    },
  })

  -- elixirls requires some additional config
  -- handle it separately=
  local path_to_elixirls =
    vim.fn.expand("~/lsp/elixir-ls/release/language_server.sh")
  nvim_lsp.elixirls.setup({
    cmd = { path_to_elixirls },
    on_attach = on_attach,
    capabilities = capabilities,
    settings = {
      elixirLS = {
        dialyzerEnabled = false,
        fetchDeps = false,
      },
    },
  })
end

return {
  setup = setup,
}
