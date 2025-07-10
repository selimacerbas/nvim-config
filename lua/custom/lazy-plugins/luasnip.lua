return {
  {
    'L3MON4D3/LuaSnip',
    dependencies = {
      'rafamadriz/friendly-snippets',  -- a collection of community snippets
      'folke/which-key.nvim',
    },
    build = 'make install_jsregexp',   -- for advanced regex in snippets
    -- event = 'InsertEnter',             -- load when you start typing
    opts = {
      history = true,                  -- keep around last used snippets
      updateevents = 'TextChanged,TextChangedI',
    },
    config = function(_, opts)
      local ls = require('luasnip')
      -- apply the opts
      ls.config.set_config(opts)
      -- load VSCode-style snippets from friendly-snippets
      require('luasnip.loaders.from_vscode').lazy_load()

      local map = vim.keymap.set
      -- expand or jump in insert & select modes
      map({ 'i', 's' }, '<C-k>', function()
        if ls.expand_or_jumpable() then ls.expand_or_jump() end
      end, { silent = true, desc = 'LuaSnip: Expand or Jump' })
      -- jump backwards
      map({ 'i', 's' }, '<C-j>', function()
        if ls.jumpable(-1) then ls.jump(-1) end
      end, { silent = true, desc = 'LuaSnip: Jump Backward' })
      -- cycle forward through choice nodes
      map('i', '<C-l>', function()
        if ls.choice_active() then ls.change_choice(1) end
      end, { silent = true, desc = 'LuaSnip: Next Choice' })
      -- cycle backward through choice nodes
      map('i', '<C-h>', function()
        if ls.choice_active() then ls.change_choice(-1) end
      end, { silent = true, desc = 'LuaSnip: Prev Choice' })

      -- -- Which-Key menu under <leader>s for snippet commands
      -- local ok, which_key = pcall(require, 'which-key')
      -- if not ok then return end
      -- which_key.register({
      --   s = {
      --     name = "Snippets",
      --     e = { "<cmd>lua require('luasnip').expand()<CR>",           "Expand Snippet" },
      --     j = { "<cmd>lua require('luasnip').jump(1)<CR>",            "Jump to Next Field" },
      --     k = { "<cmd>lua require('luasnip').jump(-1)<CR>",           "Jump to Prev Field" },
      --     l = { "<cmd>lua require('luasnip').change_choice(1)<CR>",   "Next Choice" },
      --     h = { "<cmd>lua require('luasnip').change_choice(-1)<CR>",  "Prev Choice" },
      --   },
      -- }, { prefix = '<leader>' })
    end,
  },
}


