return {
    {
        'lewis6991/gitsigns.nvim',
        dependencies = { 'folke/which-key.nvim' },
        config = function()
            local which_key = require('which-key')
            local gitsigns  = require('gitsigns')

            gitsigns.setup({
                signs = {
                    add          = { text = '+' },
                    change       = { text = '┃' },
                    delete       = { text = '_' },
                    topdelete    = { text = '‾' },
                    changedelete = { text = '~' },
                },
                current_line_blame = true,
                on_attach = function(bufnr)
                    -- leave these global so they work in any buffer:
                    vim.keymap.set('n', ']c', gitsigns.next_hunk, { desc = 'Next Git Hunk', silent = true })
                    vim.keymap.set('n', '[c', gitsigns.prev_hunk, { desc = 'Prev Git Hunk', silent = true })

                    -- all other actions under <leader>h via which-key
                    which_key.register({
                        g = {
                            name = "Git",
                            s = { '<cmd>Gitsigns stage_hunk<CR>', 'Stage Hunk' },
                            r = { '<cmd>Gitsigns reset_hunk<CR>', 'Reset Hunk' },
                            S = { gitsigns.stage_buffer, 'Stage Buffer' },
                            u = { gitsigns.undo_stage_hunk, 'Undo Stage Hunk' },
                            R = { gitsigns.reset_buffer, 'Reset Buffer' },
                            p = { gitsigns.preview_hunk, 'Preview Hunk' },
                            b = { gitsigns.blame_line, 'Blame Line' },
                            B = { gitsigns.toggle_current_line_blame, 'Toggle Blame' },
                            d = { gitsigns.diffthis, 'Diff This' },
                            D = { function() gitsigns.diffthis('~') end, 'Diff Against HEAD' },
                            t = { gitsigns.toggle_deleted, 'Toggle Deleted' },
                        },
                    }, { prefix = '<leader>', buffer = bufnr })
                end,
            })
        end,
    },
}
