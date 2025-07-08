
return {
  {
    'folke/todo-comments.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'folke/which-key.nvim',
    },
    opts = {
      keywords = {
        TODO    = { icon = " ", color = "info" },
        NOTE    = { icon = " ", color = "hint" },
        FIXME   = { icon = " ", color = "error" },
        WARNING = { icon = " ", color = "warning" },
        HACK    = { icon = " ", color = "warning" },
        PERF    = { icon = " ", color = "hint" },
      },
    },
    config = function(_, opts)
      require('todo-comments').setup(opts)

      local wk_ok, which_key = pcall(require, 'which-key')
      if not wk_ok then return end

      which_key.register({
        z = {
          name = "Todo/Zen",
          j = { "<cmd>TodoNext<CR>",                             "Next Todo" },
          k = { "<cmd>TodoPrev<CR>",                             "Prev Todo" },
          q = { "<cmd>TodoQuickFix<CR>",                         "QuickFix List" },
          l = { "<cmd>TodoLocList<CR>",                          "Location List" },
          s = { "<cmd>TodoTelescope<CR>",                        "Search Todos" },
          S = { "<cmd>TodoTelescope keywords=TODO,FIXME,BUG<CR>", "Search All Keywords" },
        },
      }, { prefix = "<leader>" })
    end,
  },
}

