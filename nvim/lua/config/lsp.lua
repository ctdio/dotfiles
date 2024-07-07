local setup_ai
local setup_cmp_completion
local setup_lsp

local function setup()
  setup_ai()
  setup_cmp_completion()
  setup_lsp()

  -- configure trouble for prettier diagnostics
  require("trouble").setup()
end

setup_ai = function()
  require("supermaven-nvim").setup({
    keymaps = {
      accept_suggestion = "<C-k>",
      clear_suggestion = nil,
      accept_word = nil,
    },
    ignore_filetypes = { sh = true },
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

  -- Setup nvim-cmp with recommended setup
  local cmp = require("cmp")

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

  local replace_termcodes = function(str)
    return vim.api.nvim_replace_termcodes(str, true, true, true)
  end

  cmp.setup({
    snippet = {
      expand = function(args)
        require("luasnip").lsp_expand(args.body)
      end,
    },
    window = {
      completion = cmp.config.window.bordered(),
      documentation = cmp.config.window.bordered(),
    },
    mapping = {
      ["<C-d>"] = cmp.mapping(cmp.mapping.scroll_docs(-4), { "i", "c" }),
      ["<C-f>"] = cmp.mapping(cmp.mapping.scroll_docs(4), { "i", "c" }),
      ["<C-Space>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),
      ["<C-e>"] = cmp.mapping({
        i = cmp.mapping.abort(),
        c = cmp.mapping.close(),
      }),
      ["<C-n>"] = cmp.mapping({
        c = function()
          if cmp.visible() then
            cmp.select_next_item({
              behavior = cmp.SelectBehavior.Select,
            })
          else
            vim.api.nvim_feedkeys(replace_termcodes("<Down>"), "n", true)
          end
        end,
        i = function(fallback)
          if cmp.visible() then
            cmp.select_next_item({
              behavior = cmp.SelectBehavior.Select,
            })
          else
            fallback()
          end
        end,
      }, { "i", "c" }),
      ["<C-p>"] = cmp.mapping({
        c = function()
          if cmp.visible() then
            cmp.select_prev_item({
              behavior = cmp.SelectBehavior.Select,
            })
          else
            vim.api.nvim_feedkeys(replace_termcodes("<Up>"), "n", true)
          end
        end,
        i = function(fallback)
          if cmp.visible() then
            cmp.select_prev_item({
              behavior = cmp.SelectBehavior.Select,
            })
          else
            fallback()
          end
        end,
      }, { "i", "c" }),
      -- ["<Tab>"] = vim.schedule_wrap(function(fallback)
      --   if cmp.visible() and has_words_before() then
      --     cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
      --   else
      --     fallback()
      --   end
      -- end),
      ["<CR>"] = cmp.mapping(confirm_item, { "i", "s", "c" }),
    },
    sources = cmp.config.sources({
      -- { name = "copilot" },
      -- { name = "supermaven" },
      { name = "nvim_lsp" },
    }, {
      -- { name = "nvim_lsp_signature_help" },
      { name = "luasnip" },
      { name = "buffer" },
      { name = "vim-dadbod-completion" },
      { name = "dap" },
      { name = "emoji" },
    }),
  })

  -- Use buffer source for `/`.
  cmp.setup.cmdline("/", {
    sources = {
      { name = "buffer" },
    },
  })

  -- Use cmdline & path source for ':'.
  cmp.setup.cmdline(":", {
    sources = cmp.config.sources({
      { name = "path" },
    }, {
      { name = "cmdline" },
    }),
  })
end

setup_lsp = function()
  local nvim_lsp = require("lspconfig")

  local opts = { noremap = true, silent = true }
  -- See `:help vim.diagnostic.*` for documentation on any of the below functions
  vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
  vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)

  vim.keymap.set("n", "<space>e", vim.diagnostic.open_float, opts)
  -- vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist, opts)
  vim.keymap.set(
    "n",
    "<space>q",
    "<CMD>Trouble diagnostics toggle filter.buf=0<CR>",
    opts
  )
  vim.keymap.set("n", "<space>Q", "<CMD>Trouble diagnostics toggle<CR>", opts)
  vim.keymap.set("n", "<space>f", vim.lsp.buf.format, opts)

  -- Use an on_attach function to only map the following keys
  -- after the language server attaches to the current buffer
  local on_attach = function(_client, bufnr)
    local function buf_set_option(...)
      vim.api.nvim_buf_set_option(bufnr, ...)
    end

    --Enable completion triggered by <c-x><c-o>
    buf_set_option("omnifunc", "v:lua.vim.lsp.omnifunc")

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
    vim.keymap.set("n", "<space>rn", vim.lsp.buf.rename, bufopts)
    -- vim.keymap.set("n", "<space>ca", vim.lsp.buf.code_action, bufopts)
    vim.keymap.set(
      "n",
      "<space>ca",
      require("actions-preview").code_actions,
      bufopts
    )
    vim.keymap.set(
      "n",
      "gr",
      require("telescope.builtin").lsp_references,
      bufopts
    )
  end

  local capabilities = vim.lsp.protocol.make_client_capabilities()

  capabilities.textDocument.foldingRange = {
    dynamicRegistration = false,
    lineFoldingOnly = true,
  }

  capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

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
    -- "tsserver", (covered by typescript-tools)
  }
  for _, lsp in ipairs(servers) do
    nvim_lsp[lsp].setup({
      on_attach = on_attach,
      capabilities = capabilities,
      detached = false,
    })
  end

  require("typescript-tools").setup({
    on_attach = on_attach,
  })

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
  nvim_lsp.denols.setup({
    on_attach = on_attach,
    capabilities = capabilities,
    root_dir = nvim_lsp.util.root_pattern("deno.json", "deno.jsonc"),
  })

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
