return {
  {
    "numToStr/Comment.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "folke/which-key.nvim" },

    -- which-key v3: register the <leader>c group early
    init = function()
      local ok, wk = pcall(require, "which-key")
      if ok and wk.add then
        wk.add({ { "<leader>c", group = "Comment" } })
      end
    end,

    opts = function()
      -- If ts-context-commentstring is installed, wire it automatically.
      local ok, tscc = pcall(require, "ts_context_commentstring.integrations.comment_nvim")
      return {
        -- keep all defaults; only add pre_hook when available
        padding = true,
        sticky  = true,
        ignore  = nil,
        mappings = { basic = true, extra = true },
        pre_hook = ok and tscc.create_pre_hook() or nil, -- tsx/jsx-aware comments when available
      }
    end,

    -- v3-friendly keys{} (normal & visual)
    keys = {
      -- NORMAL
      {
        "<leader>cc",
        function() require("Comment.api").toggle.linewise.current() end,
        mode = "n", silent = true, noremap = true, desc = "Comment: toggle line",
      },
      {
        "<leader>cB",
        function() require("Comment.api").toggle.blockwise.current() end,
        mode = "n", silent = true, noremap = true, desc = "Comment: toggle block",
      },

      -- VISUAL (preserve selection, then operate)
      {
        "<leader>cc",
        function()
          local esc = vim.api.nvim_replace_termcodes("<ESC>", true, false, true)
          vim.api.nvim_feedkeys(esc, "nx", false)
          require("Comment.api").toggle.linewise(vim.fn.visualmode())
        end,
        mode = "v", silent = true, noremap = true, desc = "Comment: toggle line (visual)",
      },
      {
        "<leader>cB",
        function()
          local esc = vim.api.nvim_replace_termcodes("<ESC>", true, false, true)
          vim.api.nvim_feedkeys(esc, "nx", false)
          require("Comment.api").toggle.blockwise(vim.fn.visualmode())
        end,
        mode = "v", silent = true, noremap = true, desc = "Comment: toggle block (visual)",
      },
    },

    config = function(_, opts)
      require("Comment").setup(opts) -- sets gcc/gbc/gc/gb/gcO/gco/gcA, etc.

      -- which-key discoverability for native 'gc'/'gb' trees
      local ok, wk = pcall(require, "which-key")
      if ok and wk.add then
        -- Show native Comment.nvim maps under the normal `g` prefix
        wk.add({
          { "gc", group = "Linewise comment" },
          { "gb", group = "Blockwise comment" },
        }, { mode = { "n", "v" }, prefix = "g" })

        -- Extra hints after `gc` (labels only; mappings already provided by Comment.nvim)
        wk.add({
          { "A", desc = "Comment end of line (gcA)" },
          { "o", desc = "Comment below (gco)" },
          { "O", desc = "Comment above (gcO)" },
        }, { mode = "n", prefix = "gc" })
      end
    end,
  },
}
