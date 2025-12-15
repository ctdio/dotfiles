-- Navigation plugins: fzf, oil, harpoon, sessions

return {
  -- Plenary (dependency)
  { "nvim-lua/plenary.nvim", lazy = true },

  -- SQLite (dependency)
  { "kkharji/sqlite.lua", lazy = true },

  -- FZF
  {
    "ibhagwan/fzf-lua",
    cmd = "FzfLua",
    keys = {
      {
        "<C-p>",
        function()
          require("fzf-lua").files()
        end,
        desc = "Find files",
      },
      {
        "<C-a>",
        function()
          require("fzf-lua").live_grep()
        end,
        desc = "Live grep",
      },
      {
        "<leader>b",
        function()
          require("fzf-lua").buffers()
        end,
        desc = "Buffers",
      },
      {
        "<leader>m",
        function()
          require("fzf-lua").marks()
        end,
        desc = "Marks",
      },
      {
        "<leader>z",
        function()
          require("fzf-lua").spell_suggest()
        end,
        desc = "Spell suggest",
      },
    },
    config = function()
      require("fzf-lua").setup({
        winopts = { width = 0.90 },
        keymap = { fzf = { ["ctrl-q"] = "select-all+accept" } },
        grep = { hidden = true, ignore = true },
      })
    end,
  },

  -- Oil (file explorer)
  {
    "stevearc/oil.nvim",
    cmd = "Oil",
    keys = {
      { "-", ":Oil<CR>", desc = "Open Oil" },
    },
    config = function()
      require("oil").setup({
        skip_confirm_for_simple_edits = true,
        view_options = { show_hidden = true },
        lsp_file_methods = { timeout_ms = 30000, autosave_changes = true },
        keymaps = {
          ["<C-y>"] = {
            mode = "n",
            desc = "Copy file path to system clipboard",
            callback = function()
              require("oil.actions").copy_entry_path.callback()
              vim.fn.setreg("+", vim.fn.getreg(vim.v.register))
            end,
          },
        },
      })
    end,
  },

  -- Harpoon
  {
    "thePrimeagen/harpoon",
    branch = "harpoon2",
    keys = {
      {
        "<C-s>",
        function()
          require("harpoon"):list():add()
        end,
        desc = "Add to harpoon",
      },
      {
        "<C-t>",
        function()
          require("harpoon").ui:toggle_quick_menu(require("harpoon"):list())
        end,
        desc = "Harpoon menu",
      },
      {
        "<leader>1",
        function()
          require("harpoon"):list():select(1)
        end,
        desc = "Harpoon 1",
      },
      {
        "<leader>2",
        function()
          require("harpoon"):list():select(2)
        end,
        desc = "Harpoon 2",
      },
      {
        "<leader>3",
        function()
          require("harpoon"):list():select(3)
        end,
        desc = "Harpoon 3",
      },
      {
        "<leader>4",
        function()
          require("harpoon"):list():select(4)
        end,
        desc = "Harpoon 4",
      },
      {
        "<C-h><C-h>",
        function()
          require("harpoon"):list():select(1)
        end,
        desc = "Harpoon 1",
      },
      {
        "<C-h><C-k>",
        function()
          require("harpoon"):list():select(2)
        end,
        desc = "Harpoon 2",
      },
      {
        "<C-h><C-e>",
        function()
          require("harpoon"):list():select(3)
        end,
        desc = "Harpoon 3",
      },
      {
        "<C-h><C-j>",
        function()
          require("harpoon"):list():select(4)
        end,
        desc = "Harpoon 4",
      },
    },
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("harpoon"):setup()
    end,
  },

  -- Neoclip (clipboard manager)
  {
    "AckslD/nvim-neoclip.lua",
    event = "VeryLazy",
    dependencies = { "ibhagwan/fzf-lua" },
    keys = {
      {
        "<leader>y",
        function()
          require("neoclip.fzf")()
        end,
        desc = "Clipboard history",
      },
    },
    config = function()
      require("neoclip").setup({
        fzf = { paste = "ctrl-k", paste_behind = "ctrl-j" },
      })
    end,
  },

  -- Sessions
  {
    "stevearc/resession.nvim",
    lazy = false, -- Load early for session restore
    priority = 1000,
    keys = {
      {
        "<leader>ss",
        function()
          require("resession").save()
        end,
        desc = "Save session",
      },
      {
        "<leader>sl",
        function()
          require("resession").load()
        end,
        desc = "Load session",
      },
      {
        "<leader>sd",
        function()
          require("resession").delete()
        end,
        desc = "Delete session",
      },
    },
    config = function()
      local resession = require("resession")
      resession.setup({
        autosave = { enabled = true, interval = 60, notify = false },
      })

      -- Load session immediately
      if vim.fn.argc(-1) == 0 and #vim.v.argv < 4 then
        resession.load(
          vim.fn.getcwd(),
          { dir = "dirsession", silence_errors = true }
        )
      end

      vim.api.nvim_create_autocmd("VimLeavePre", {
        callback = function()
          resession.save(
            vim.fn.getcwd(),
            { dir = "dirsession", notify = false }
          )
        end,
      })
    end,
  },

  -- Copy current file path
  {
    "nvim-lua/plenary.nvim",
    keys = {
      {
        "<C-y>",
        function()
          vim.fn.setreg("+", vim.fn.expand("%:p"))
        end,
        desc = "Copy file path",
      },
    },
  },
}
