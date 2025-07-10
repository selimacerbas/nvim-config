return {
  {
    'windwp/nvim-autopairs',
    -- event = 'InsertEnter',
    dependencies = { 'folke/which-key.nvim' },
    opts = {
      -- Enable Treesitter integration to avoid pairing in strings/comments
      check_ts = true,
      ts_config = {
        lua = { 'string' },
        javascript = { 'template_string' },
        java = false,
      },
      -- Fast wrap configuration (trigger with Alt-e)
      fast_wrap = {
        map = '<M-e>',
        chars = { '{', '[', '(', '"', "'" },
        pattern = [=[[%'%"%>%]%)%}%,]]=],
        end_key = '$',
        keys = 'qwertyuiopzxcvbnmasdfghjkl',
        cursor_pos = true,
      },
      -- Filetypes to ignore
      disable_filetype = { 'TelescopePrompt', 'spectre_panel', 'snacks_picker_input' },
      -- Leave all other defaults
    },
    config = function(_, opts)
      local npairs = require('nvim-autopairs')
      local Rule   = require('nvim-autopairs.rule')
      local cond   = require('nvim-autopairs.conds')

      -- Setup with our opts
      npairs.setup(opts)

      -- Example: add TeX $$…$$ rule, but don’t pair if next char is %
      npairs.add_rule(
        Rule('$$', '$$', 'tex')
          :with_pair(cond.not_after_regex('%%'))
      )

      -- Which-key hints under <leader>p
      local wk_ok, which_key = pcall(require, 'which-key')
      if not wk_ok then return end

      which_key.register({
        p = {
          name = 'Pairs',
          e = { '<M-e>',                                             'Fast Wrap' },
          d = { '<cmd>lua require("nvim-autopairs").disable()<CR>',  'Disable Pairs' },
          E = { '<cmd>lua require("nvim-autopairs").enable()<CR>',   'Enable Pairs' },
          r = { '<cmd>lua require("nvim-autopairs").remove_rule("(")<CR>', 'Remove "(" Rule' },
          c = { '<cmd>lua require("nvim-autopairs").clear_rules()<CR>',   'Clear All Rules' },
        },
      }, { prefix = '<leader>' })
    end,
  },
}
