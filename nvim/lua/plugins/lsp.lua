-- LSP and completion plugins

return {
  -- Completion engine
  {
    "Saghen/blink.cmp",
    event = { "InsertEnter", "CmdlineEnter" },
    version = "*",
    dependencies = {
      "L3MON4D3/LuaSnip",
      "kristijanhusak/vim-dadbod-completion",
    },
    config = function()
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
        signature = { enabled = true },
        sources = {
          default = { "lsp", "path", "snippets", "buffer", "dadbod" },
          providers = {
            dadbod = { name = "Dadbod", module = "vim_dadbod_completion.blink" },
          },
        },
      })
    end,
  },

  -- LSP Saga for better UI
  {
    "nvimdev/lspsaga.nvim",
    event = "LspAttach",
    config = function()
      require("lspsaga").setup({
        lightbulb = { enable = false },
        rename = { auto_save = true },
      })
    end,
  },

  -- Trouble for diagnostics
  {
    "folke/trouble.nvim",
    cmd = "Trouble",
    keys = {
      {
        "<space>q",
        "<CMD>Trouble diagnostics toggle filter.buf=0<CR>",
        desc = "Buffer Diagnostics",
      },
      {
        "<space>d",
        "<CMD>Trouble diagnostics toggle<CR>",
        desc = "Workspace Diagnostics",
      },
    },
    config = function()
      require("trouble").setup()
    end,
  },

  -- TypeScript checker
  {
    "dmmulroy/tsc.nvim",
    cmd = "TSC",
    ft = { "typescript", "typescriptreact" },
    config = function()
      require("tsc").setup({ use_trouble_qflist = true })
    end,
  },

  -- Zig language
  {
    "ziglang/zig.vim",
    ft = "zig",
  },

  -- nvim-vtsls (kept for compatibility, may be used later)
  {
    "yioneko/nvim-vtsls",
    lazy = true,
  },

  -- LSP configuration (native Neovim 0.10+ vim.lsp.config/enable)
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPost", "BufNewFile" },
    optional = true, -- Not strictly required, but kept for schema definitions
    config = function()
      vim.lsp.set_log_level("off")

      local opts = { noremap = true, silent = true }
      vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
      vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
      vim.keymap.set("n", "[q", "<CMD>cprev<CR>", opts)
      vim.keymap.set("n", "]q", "<CMD>cnext<CR>", opts)
      vim.keymap.set("n", "<space>e", vim.diagnostic.open_float, opts)
      vim.keymap.set("n", "<space>f", vim.lsp.buf.format, opts)

      local on_attach = function(_client, bufnr)
        local bufopts = { noremap = true, silent = true, buffer = bufnr }
        vim.keymap.set("n", "gD", vim.lsp.buf.declaration, bufopts)
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, bufopts)
        vim.keymap.set("n", "K", vim.lsp.buf.hover, bufopts)
        vim.keymap.set("n", "gi", vim.lsp.buf.implementation, bufopts)
        vim.keymap.set("n", "]d", vim.diagnostic.goto_next, bufopts)
        vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, bufopts)
        vim.keymap.set(
          "n",
          "<space>wa",
          vim.lsp.buf.add_workspace_folder,
          bufopts
        )
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
        vim.keymap.set("n", "<space>rn", ":Lspsaga rename<CR>", bufopts)
        vim.keymap.set("n", "<space>ca", vim.lsp.buf.code_action, bufopts)
        vim.keymap.set("n", "gr", require("fzf-lua").lsp_references, bufopts)
      end

      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities.textDocument.foldingRange = {
        dynamicRegistration = false,
        lineFoldingOnly = true,
      }
      capabilities = require("blink.cmp").get_lsp_capabilities(capabilities)

      -- Basic servers
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
      }

      for _, lsp in ipairs(servers) do
        vim.lsp.config(lsp, {
          on_attach = on_attach,
          capabilities = capabilities,
          root_markers = { ".git" },
        })
        vim.lsp.enable(lsp)
      end

      -- zls
      vim.lsp.config("zls", {
        cmd = { "zls" },
        on_attach = on_attach,
        capabilities = capabilities,
        filetypes = { "zig", "zir" },
        root_markers = { "build.zig", "zls.json", ".git" },
      })
      vim.lsp.enable("zls")

      -- tsgo (TypeScript native Go port)
      vim.lsp.config("tsgo", {
        cmd = { "tsgo", "lsp", "--stdio" },
        on_attach = on_attach,
        capabilities = capabilities,
        filetypes = {
          "typescript",
          "typescriptreact",
          "javascript",
          "javascriptreact",
        },
        root_markers = {
          "tsconfig.json",
          "jsconfig.json",
          "package.json",
          ".git",
        },
      })
      vim.lsp.enable("tsgo")

      -- emmet
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

      -- terraform
      vim.lsp.config("terraformls", {
        on_attach = on_attach,
        capabilities = capabilities,
        filetypes = { "terraform", "terraform-vars", "hcl" },
      })
      vim.lsp.enable("terraformls")

      -- lua_ls with neovim runtime
      vim.lsp.config("lua_ls", {
        on_attach = on_attach,
        capabilities = capabilities,
        settings = {
          Lua = {
            runtime = { version = "LuaJIT" },
            workspace = {
              library = vim.api.nvim_get_runtime_file("", true),
              checkThirdParty = false,
            },
            diagnostics = { globals = { "vim" } },
            completion = { callSnippet = "Replace" },
            telemetry = { enable = false },
          },
        },
      })
      vim.lsp.enable("lua_ls")

      -- prismals
      vim.lsp.config("prismals", {
        cmd = { "prisma-language-server", "--stdio" },
        on_attach = on_attach,
        capabilities = capabilities,
        filetypes = { "prisma" },
        root_markers = { ".git", "package.json" },
      })
      vim.lsp.enable("prismals")

      -- elixirls
      local path_to_elixirls =
        vim.fn.expand("~/lsp/elixir-ls/release/language_server.sh")
      vim.lsp.config("elixirls", {
        cmd = { path_to_elixirls },
        on_attach = on_attach,
        capabilities = capabilities,
        filetypes = { "elixir", "eelixir", "heex", "surface" },
        settings = {
          elixirLS = { dialyzerEnabled = false, fetchDeps = false },
        },
      })
      vim.lsp.enable("elixirls")

      vim.api.nvim_create_user_command("TSA", "VtsExec source_actions", {})
    end,
  },
}
