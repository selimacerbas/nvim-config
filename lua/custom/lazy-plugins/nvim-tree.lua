return {
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
      "folke/which-key.nvim",
    },

    -- lazy-load on commands/keys
    cmd = {
      "NvimTreeToggle", "NvimTreeOpen", "NvimTreeClose", "NvimTreeRefresh",
      "NvimTreeFindFile", "NvimTreeCollapse", "NvimTreeResize",
      "NvimTreeCreate", "NvimTreeRemove", "NvimTreeRename",
      "NvimTreeCopy", "NvimTreeCut", "NvimTreePaste",
    },

    -- cleaned keys (sizing presets removed). mode+silent added for consistency.
    keys = {
      { "<leader>nt", "<cmd>NvimTreeToggle<CR>",  desc = "NvimTree: Toggle",            mode = "n", silent = true },
      { "<leader>no", "<cmd>NvimTreeOpen<CR>",    desc = "NvimTree: Open",              mode = "n", silent = true },
      { "<leader>nc", "<cmd>NvimTreeClose<CR>",   desc = "NvimTree: Close",             mode = "n", silent = true },
      { "<leader>nC", "<cmd>NvimTreeCollapse<CR>",desc = "NvimTree: Collapse All",      mode = "n", silent = true },
      { "<leader>nr", "<cmd>NvimTreeRefresh<CR>", desc = "NvimTree: Refresh",           mode = "n", silent = true },
      { "<leader>nf", "<cmd>NvimTreeFindFile<CR>",desc = "NvimTree: Find Current File", mode = "n", silent = true },
      { "<leader>na", "<cmd>NvimTreeCreate<CR>",  desc = "NvimTree: Create",            mode = "n", silent = true },
      { "<leader>nd", "<cmd>NvimTreeRemove<CR>",  desc = "NvimTree: Delete",            mode = "n", silent = true },
      { "<leader>nR", "<cmd>NvimTreeRename<CR>",  desc = "NvimTree: Rename",            mode = "n", silent = true },
      { "<leader>nx", "<cmd>NvimTreeCut<CR>",     desc = "NvimTree: Cut",               mode = "n", silent = true },
      { "<leader>ny", "<cmd>NvimTreeCopy<CR>",    desc = "NvimTree: Copy",              mode = "n", silent = true },
      { "<leader>np", "<cmd>NvimTreePaste<CR>",   desc = "NvimTree: Paste",             mode = "n", silent = true },

      -- built-in filter toggles
      {
        "<leader>ng",
        function() require("nvim-tree.api").tree.toggle_gitignore_filter() end,
        desc = "NvimTree: Toggle .gitignore", mode = "n", silent = true
      },
      {
        "<leader>n.",
        function() require("nvim-tree.api").tree.toggle_hidden_filter() end,
        desc = "NvimTree: Toggle Dotfiles",   mode = "n", silent = true
      },
    },

    -- auto-open on startup (no sizing here; global us*/uh* will handle it)
    init = function()
      vim.api.nvim_create_autocmd("VimEnter", {
        callback = function()
          vim.schedule(function()
            vim.cmd("NvimTreeOpen")
          end)
        end,
      })
    end,

    opts = function()
      local function on_attach(bufnr)
        local api = require("nvim-tree.api")
        local function opts(desc)
          return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
        end
        api.config.mappings.default_on_attach(bufnr)
        -- open in tab/splits
        vim.keymap.set("n", "t", api.node.open.tab,        opts("Open in New Tab"))
        vim.keymap.set("n", "v", api.node.open.vertical,   opts("Open: Vertical Split"))
        vim.keymap.set("n", "T", api.node.open.horizontal, opts("Open: Horizontal Split"))
        -- sibling nav
        vim.keymap.set("n", "<Tab>",   api.node.navigate.sibling.next, opts("Next Sibling"))
        vim.keymap.set("n", "<S-Tab>", api.node.navigate.sibling.prev, opts("Previous Sibling"))
      end

      return {
        disable_netrw       = true,
        hijack_netrw        = true,
        view                = { side = "left" }, -- width removed; use global UI sizing
        renderer            = { highlight_git = true, highlight_opened_files = "all" },
        update_focused_file = { enable = true, update_root = true },
        sync_root_with_cwd  = true,
        respect_buf_cwd     = true,
        diagnostics         = { enable = false },
        git                 = { enable = true, ignore = true },
        trash               = { cmd = "trash", require_confirm = true },
        on_attach           = on_attach,
      }
    end,

    config = function(_, opts)
      require("nvim-tree").setup(opts)

      -- If tree is the last window, just close the tree (don't quit Neovim)
      vim.api.nvim_create_autocmd("BufEnter", {
        nested = true,
        callback = function()
          if #vim.api.nvim_list_wins() == 1 and vim.bo.filetype == "NvimTree" then
            require("nvim-tree.api").tree.close()
          end
        end,
      })

      -- which-key v3 labels (sizing entries removed)
      local ok, wk = pcall(require, "which-key")
      if ok and wk.add then
        wk.add({
          { "<leader>n",  group = "NvimTree" },
          { "<leader>nt", desc = "Toggle" },
          { "<leader>no", desc = "Open" },
          { "<leader>nc", desc = "Close" },
          { "<leader>nC", desc = "Collapse All" },
          { "<leader>nr", desc = "Refresh" },
          { "<leader>nf", desc = "Find Current File" },
          { "<leader>na", desc = "Create" },
          { "<leader>nd", desc = "Delete" },
          { "<leader>nR", desc = "Rename" },
          { "<leader>nx", desc = "Cut" },
          { "<leader>ny", desc = "Copy" },
          { "<leader>np", desc = "Paste" },
          { "<leader>ng", desc = "Toggle .gitignore" },
          { "<leader>n.", desc = "Toggle Dotfiles" },
        })
      end
    end,
  },
}
