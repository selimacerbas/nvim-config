return {
  {
    'nvim-tree/nvim-tree.lua',
    dependencies = {
      'nvim-tree/nvim-web-devicons',
      'folke/which-key.nvim',
    },
    config = function()
      -- custom on_attach to add extra nvim-tree mappings
      local function on_attach(bufnr)
        local api = require('nvim-tree.api')
        local function opts(desc)
          return {
            desc     = "nvim-tree: " .. desc,
            buffer   = bufnr,
            noremap  = true,
            silent   = true,
            nowait   = true,
          }
        end

        -- load default mappings
        api.config.mappings.default_on_attach(bufnr)

        -- open in new tab / splits
        vim.keymap.set('n', 't', api.node.open.tab,        opts('Open File in New Tab'))
        vim.keymap.set('n', 'v', api.node.open.vertical,   opts('Open: Vertical Split'))
        -- corrected here: horizontal split instead of nonexistent force_tabnew
        vim.keymap.set('n', 'T', api.node.open.horizontal, opts('Open: Horizontal Split'))

        -- navigate siblings
        vim.keymap.set('n', '<Tab>',   api.node.navigate.sibling.next, opts('Next Sibling'))
        vim.keymap.set('n', '<S-Tab>', api.node.navigate.sibling.prev, opts('Previous Sibling'))
      end

      -- nvim-tree setup
      require('nvim-tree').setup {
        disable_netrw = true,
        hijack_netrw  = true,
        view = {
          side  = 'left',
          width = 40,
        },
        trash = {
          cmd             = 'trash',
          require_confirm = true,
        },
        on_attach = on_attach,
      }

      -- which-key bindings under <leader>n
      local wk_ok, which_key = pcall(require, 'which-key')
      if not wk_ok then return end

      which_key.register({
        n = {
          name = 'Explorer',
          t   = { '<cmd>NvimTreeToggle<CR>',   'Toggle Tree' },
          f   = { '<cmd>NvimTreeFindFile<CR>', 'Find Current File' },
          r   = { '<cmd>NvimTreeRefresh<CR>',  'Refresh' },
          o   = { '<cmd>NvimTreeOpen<CR>',     'Open Tree' },
          c   = { '<cmd>NvimTreeClose<CR>',    'Close Tree' },
          C   = { '<cmd>NvimTreeCollapse<CR>', 'Collapse All' },
          a   = { '<cmd>NvimTreeCreate<CR>',   'Create File/Dir' },
          d   = { '<cmd>NvimTreeRemove<CR>',   'Delete' },
          rnm = { '<cmd>NvimTreeRename<CR>',   'Rename' },
          x   = { '<cmd>NvimTreeCut<CR>',      'Cut' },
          y   = { '<cmd>NvimTreeCopy<CR>',     'Copy' },
          p   = { '<cmd>NvimTreePaste<CR>',    'Paste' },
        },
      }, {
        prefix = '<leader>',
      })
    end,
  },
}
