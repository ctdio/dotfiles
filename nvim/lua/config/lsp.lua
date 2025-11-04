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
      preset = "none",
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

    cmdline = {
      keymap = {
        preset = "none",
        ["<C-k>"] = { "show_and_insert_or_accept_single", "fallback" },
        ["<C-n>"] = { "select_next", "fallback" },
        ["<C-p>"] = { "select_prev", "fallback" },
        ["<Tab>"] = { "show_and_insert_or_accept_single", "select_next" },
        ["<S-Tab>"] = { "show_and_insert_or_accept_single", "select_prev" },
      },
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

  -- Register and enable LSP servers using vim.lsp.config
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
    "zls",
    "vtsls",
  }

  for _, lsp in ipairs(servers) do
    vim.lsp.config(lsp, {
      on_attach = on_attach,
      capabilities = capabilities,
      root_markers = { ".git" },
    })
    vim.lsp.enable(lsp)
  end

  vim.api.nvim_create_user_command("TSA", "VtsExec source_actions", {})

  -- emmet_language_server with specific filetypes
  vim.lsp.config("emmet_language_server", {
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
  vim.lsp.enable("emmet_language_server")

  -- terraformls with specific filetypes
  vim.lsp.config("terraformls", {
    on_attach = on_attach,
    capabilities = capabilities,
    filetypes = { "terraform", "terraform-vars", "hcl" },
  })
  vim.lsp.enable("terraformls")

  -- tweak denols config to avoid conflict with nodejs projects
  -- vim.lsp.config("denols", {
  --   on_attach = on_attach,
  --   capabilities = capabilities,
  --   root_markers = { "deno.json", "deno.jsonc" },
  -- })
  -- vim.lsp.enable("denols")

  -- lua_ls requires some additional config
  vim.lsp.config("lua_ls", {
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
          checkThirdParty = false,
        },
        diagnostics = {
          -- Get the language server to recognize the `vim` global
          globals = { "vim" },
        },
        completion = {
          callSnippet = "Replace",
        },
        telemetry = {
          enable = false,
        },
      },
    },
  })
  vim.lsp.enable("lua_ls")

  -- prismals with specific filetypes
  vim.lsp.config("prismals", {
    cmd = { "prisma-language-server", "--stdio" },
    on_attach = on_attach,
    capabilities = capabilities,
    filetypes = { "prisma" },
    root_markers = { ".git", "package.json" },
  })
  vim.lsp.enable("prismals")

  -- elixirls requires some additional config
  local path_to_elixirls =
    vim.fn.expand("~/lsp/elixir-ls/release/language_server.sh")
  vim.lsp.config("elixirls", {
    cmd = { path_to_elixirls },
    on_attach = on_attach,
    capabilities = capabilities,
    filetypes = { "elixir", "eelixir", "heex", "surface" },
    settings = {
      elixirLS = {
        dialyzerEnabled = false,
        fetchDeps = false,
      },
    },
  })
  vim.lsp.enable("elixirls")
end

return {
  setup = setup,
}
