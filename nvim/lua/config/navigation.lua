local function setup()
  require("noice").setup({
    lsp = {
      -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
      override = {
        ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
        ["vim.lsp.util.stylize_markdown"] = true,
        ["cmp.entry.get_documentation"] = true,
      },
    },
    -- you can enable a preset for easier configuration
    presets = {
      bottom_search = true, -- use a classic bottom cmdline for search
      command_palette = true, -- position the cmdline and popupmenu together
      long_message_to_split = true, -- long messages will be sent to a split
      inc_rename = false, -- enables an input dialog for inc-rename.nvim
      lsp_doc_border = false, -- add a border to hover docs and signature help
    },
  })

  require("dressing").setup({})

  -- setup autosession
  local resession = require("resession")
  resession.setup({
    autosave = {
      enabled = true,
      interval = 60,
      notify = false,
    },
  })

  vim.keymap.set("n", "<leader>ss", resession.save)
  vim.keymap.set("n", "<leader>sl", resession.load)
  vim.keymap.set("n", "<leader>sd", resession.delete)

  vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
      -- Only load the session if nvim was started with no args
      if vim.fn.argc(-1) == 0 and #vim.v.argv < 4 then
        -- Save these to a different directory, so our manual sessions don't get polluted
        resession.load(
          vim.fn.getcwd(),
          { dir = "dirsession", silence_errors = true }
        )
      end
    end,
    nested = true,
  })
  vim.api.nvim_create_autocmd("VimLeavePre", {
    callback = function()
      resession.save(vim.fn.getcwd(), { dir = "dirsession", notify = false })
    end,
  })

  -- setup oil
  require("oil").setup({
    skip_confirm_for_simple_edits = true,
    view_options = {
      show_hidden = true,
    },
    lsp_file_methods = {
      timeout_ms = 30000,
      autosave_changes = true,
    },
    keymaps = {
      ["<C-y>"] = {
        mode = "n",
        desc = "Copy file path to system clipboard",
        callback = function()
          -- copy the to the system clipboard
          require("oil.actions").copy_entry_path.callback()
          vim.fn.setreg("+", vim.fn.getreg(vim.v.register))
        end,
      },
    },
  })

  require("neoclip").setup({
    fzf = {
      paste = "ctrl-k",
      paste_behind = "ctrl-j",
    },
  })

  vim.keymap.set("n", "<leader>y", function()
    require("neoclip.fzf")()
  end, {})

  -- setup status line
  require("lualine").setup({
    sections = {
      lualine_x = {
        "encoding",
        "fileformat",
        {
          require("noice").api.status.mode.get,
          cond = require("noice").api.status.mode.has,
          color = { fg = "#ff9e64" },
        },
      },
    },
  })

  local function on_attach(bufnr)
    local api = require("nvim-tree.api")

    local function opts(desc)
      return {
        desc = "nvim-tree: " .. desc,
        buffer = bufnr,
        noremap = true,
        silent = true,
        nowait = true,
      }
    end

    -- Default mappings. Feel free to modify or remove as you wish.
    --
    -- BEGIN_DEFAULT_ON_ATTACH
    vim.keymap.set("n", "<C-]>", api.tree.change_root_to_node, opts("CD"))
    vim.keymap.set(
      "n",
      "<C-e>",
      api.node.open.replace_tree_buffer,
      opts("Open: In Place")
    )
    -- vim.keymap.set("n", "<C-k>", api.node.show_info_popup, opts("Info"))
    vim.keymap.set(
      "n",
      "<C-r>",
      api.fs.rename_sub,
      opts("Rename: Omit Filename")
    )
    vim.keymap.set("n", "<C-t>", api.node.open.tab, opts("Open: New Tab"))
    vim.keymap.set(
      "n",
      "<C-v>",
      api.node.open.vertical,
      opts("Open: Vertical Split")
    )
    vim.keymap.set(
      "n",
      "<C-x>",
      api.node.open.horizontal,
      opts("Open: Horizontal Split")
    )
    vim.keymap.set(
      "n",
      "<BS>",
      api.node.navigate.parent_close,
      opts("Close Directory")
    )
    vim.keymap.set("n", "<CR>", api.node.open.edit, opts("Open"))
    vim.keymap.set("n", "<Tab>", api.node.open.preview, opts("Open Preview"))
    vim.keymap.set(
      "n",
      ">",
      api.node.navigate.sibling.next,
      opts("Next Sibling")
    )
    vim.keymap.set(
      "n",
      "<",
      api.node.navigate.sibling.prev,
      opts("Previous Sibling")
    )
    vim.keymap.set("n", ".", api.node.run.cmd, opts("Run Command"))
    vim.keymap.set("n", "-", api.tree.change_root_to_parent, opts("Up"))
    vim.keymap.set("n", "a", api.fs.create, opts("Create"))
    vim.keymap.set("n", "bd", api.marks.bulk.delete, opts("Delete Bookmarked"))
    vim.keymap.set("n", "bmv", api.marks.bulk.move, opts("Move Bookmarked"))
    vim.keymap.set(
      "n",
      "B",
      api.tree.toggle_no_buffer_filter,
      opts("Toggle Filter: No Buffer")
    )
    vim.keymap.set("n", "c", api.fs.copy.node, opts("Copy"))
    vim.keymap.set(
      "n",
      "C",
      api.tree.toggle_git_clean_filter,
      opts("Toggle Filter: Git Clean")
    )
    vim.keymap.set("n", "[c", api.node.navigate.git.prev, opts("Prev Git"))
    vim.keymap.set("n", "]c", api.node.navigate.git.next, opts("Next Git"))
    vim.keymap.set("n", "d", api.fs.remove, opts("Delete"))
    vim.keymap.set("n", "D", api.fs.trash, opts("Trash"))
    vim.keymap.set("n", "E", api.tree.expand_all, opts("Expand All"))
    vim.keymap.set("n", "e", api.fs.rename_basename, opts("Rename: Basename"))
    vim.keymap.set(
      "n",
      "]e",
      api.node.navigate.diagnostics.next,
      opts("Next Diagnostic")
    )
    vim.keymap.set(
      "n",
      "[e",
      api.node.navigate.diagnostics.prev,
      opts("Prev Diagnostic")
    )
    vim.keymap.set("n", "F", api.live_filter.clear, opts("Clean Filter"))
    vim.keymap.set("n", "f", api.live_filter.start, opts("Filter"))
    vim.keymap.set("n", "g?", api.tree.toggle_help, opts("Help"))
    vim.keymap.set(
      "n",
      "gy",
      api.fs.copy.absolute_path,
      opts("Copy Absolute Path")
    )
    vim.keymap.set(
      "n",
      "H",
      api.tree.toggle_hidden_filter,
      opts("Toggle Filter: Dotfiles")
    )
    vim.keymap.set(
      "n",
      "I",
      api.tree.toggle_gitignore_filter,
      opts("Toggle Filter: Git Ignore")
    )
    vim.keymap.set(
      "n",
      "J",
      api.node.navigate.sibling.last,
      opts("Last Sibling")
    )
    vim.keymap.set(
      "n",
      "K",
      api.node.navigate.sibling.first,
      opts("First Sibling")
    )
    vim.keymap.set("n", "m", api.marks.toggle, opts("Toggle Bookmark"))
    vim.keymap.set("n", "o", api.node.open.edit, opts("Open"))
    vim.keymap.set(
      "n",
      "O",
      api.node.open.no_window_picker,
      opts("Open: No Window Picker")
    )
    vim.keymap.set("n", "p", api.fs.paste, opts("Paste"))
    vim.keymap.set("n", "P", api.node.navigate.parent, opts("Parent Directory"))
    vim.keymap.set("n", "q", api.tree.close, opts("Close"))
    vim.keymap.set("n", "r", api.fs.rename, opts("Rename"))
    vim.keymap.set("n", "R", api.tree.reload, opts("Refresh"))
    vim.keymap.set("n", "s", api.node.run.system, opts("Run System"))
    vim.keymap.set("n", "S", api.tree.search_node, opts("Search"))
    vim.keymap.set(
      "n",
      "U",
      api.tree.toggle_custom_filter,
      opts("Toggle Filter: Hidden")
    )
    vim.keymap.set("n", "W", api.tree.collapse_all, opts("Collapse"))
    vim.keymap.set("n", "x", api.fs.cut, opts("Cut"))
    vim.keymap.set("n", "y", api.fs.copy.filename, opts("Copy Name"))
    vim.keymap.set(
      "n",
      "Y",
      api.fs.copy.relative_path,
      opts("Copy Relative Path")
    )
    vim.keymap.set("n", "<2-LeftMouse>", api.node.open.edit, opts("Open"))
    vim.keymap.set(
      "n",
      "<2-RightMouse>",
      api.tree.change_root_to_node,
      opts("CD")
    )
    -- END_DEFAULT_ON_ATTACH

    -- Mappings migrated from view.mappings.list
    --
    -- You will need to insert "your code goes here" for any mappings with a custom action_cb
    vim.keymap.set(
      "n",
      "i",
      api.node.open.horizontal,
      opts("Open: Horizontal Split")
    )
    vim.keymap.set(
      "n",
      "s",
      api.node.open.vertical,
      opts("Open: Vertical Split")
    )
    vim.keymap.set(
      "n",
      "<S-a>",
      require("nvim-tree-util").toggle_size,
      opts("Toggle size")
    )
  end

  -- setup nvim-tree for file nav
  require("nvim-tree").setup({
    on_attach = on_attach,
    view = {
      width = 35,
    },
  })

  vim.keymap.set("n", "<leader>nn", ":NvimTreeToggle<CR>")
  vim.keymap.set("n", "<leader>nf", ":NvimTreeFindFile<CR>")

  -- setup bufferline for nicer tabs
  require("bufferline").setup({
    options = {
      separator_style = "slant",
      diagnostics = "nvim_lsp",
      mode = "tabs",
      always_show_bufferline = false,
    },
  })

  local fzf = require("fzf-lua")

  fzf.setup({
    winopts = {
      width = 0.90,
    },
    keymap = {
      fzf = {
        ["ctrl-q"] = "select-all+accept",
      },
    },
    grep = {
      hidden = true,
      ignore = true,
    },
  })

  vim.keymap.set("n", "<C-p>", function()
    fzf.files()
  end, {})

  vim.keymap.set("n", "<C-a>", function()
    fzf.live_grep({})
  end, {})

  vim.keymap.set("n", "<leader>b", function()
    fzf.buffers()
  end, {})

  vim.keymap.set("n", "<leader>m", function()
    fzf.marks()
  end, {})

  vim.keymap.set("n", "<leader>z", function()
    fzf.spell_suggest()
  end, {})

  -- setup harpoon
  local harpoon = require("harpoon")

  harpoon:setup()

  vim.keymap.set("n", "<C-s>", function()
    harpoon:list():append()
  end)
  vim.keymap.set("n", "<C-t>", function()
    harpoon.ui:toggle_quick_menu(harpoon:list())
  end)

  vim.keymap.set("n", "<leader>1", function()
    harpoon:list():select(1)
  end)
  vim.keymap.set("n", "<leader>2", function()
    harpoon:list():select(2)
  end)
  vim.keymap.set("n", "<leader>3", function()
    harpoon:list():select(3)
  end)
  vim.keymap.set("n", "<leader>4", function()
    harpoon:list():select(4)
  end)

  vim.keymap.set("n", "<C-h><C-h>", function()
    harpoon:list():select(1)
  end)
  vim.keymap.set("n", "<C-h><C-k>", function()
    harpoon:list():select(2)
  end)
  vim.keymap.set("n", "<C-h><C-e>", function()
    harpoon:list():select(3)
  end)
  vim.keymap.set("n", "<C-h><C-j>", function()
    harpoon:list():select(4)
  end)

  vim.keymap.set("n", "<C-y>", function()
    local current_path = vim.fn.expand("%:p")
    vim.fn.setreg("+", current_path)
  end)
end

return {
  setup = setup,
}
