return {
    -- LSP Saga for enhanced LSP UI
    {
        'glepnir/lspsaga.nvim',
        dependencies = {
            'nvim-tree/nvim-web-devicons',
            'folke/which-key.nvim',
        },
        config = function()
            -- Basic Saga setup
            require('lspsaga').setup({
                lightbulb = { enable = false },
            })

            -- General-purpose mappings
            local map = vim.keymap.set
            -- map('n', 'K', '<cmd>Lspsaga hover_doc<CR>', { silent = true, desc = "Saga: Hover Doc" })
            map('n', 'gh', '<cmd>Lspsaga lsp_finder<CR>', { silent = true, desc = "Saga: Finder" })
            map('n', 'gd', '<cmd>Lspsaga goto_definition<CR>', { silent = true, desc = "Saga: Definition" })
            map('n', 'gD', '<cmd>Lspsaga goto_declaration<CR>', { silent = true, desc = "Saga: Declaration" })
            map('n', 'gp', '<cmd>Lspsaga peek_definition<CR>', { silent = true, desc = "Saga: Peek Definition" })

            -- Format with a single F keystroke
            map('n', 'F', '<cmd>lua vim.lsp.buf.format({ async = true })<CR>', { silent = true, desc = "Format Buffer" })
            
            -- Which-key group under <leader>l
            local wk_ok, which_key = pcall(require, 'which-key')
            if not wk_ok then return end

            which_key.register({
                l = {
                    name = "LSP",
                    r = { '<cmd>Lspsaga rename<CR>', "Rename Symbol" },
                    a = { '<cmd>Lspsaga code_action<CR>', "Code Action" },
                    s = { '<cmd>Lspsaga signature_help<CR>', "Signature Help" },
                    R = { '<cmd>Lspsaga show_line_diagnostics<CR>', "Line Diagnostics" },
                    d = { '<cmd>Lspsaga show_cursor_diagnostics<CR>', "Cursor Diagnostics" },
                    o = { '<cmd>Lspsaga outline<CR>', "Symbol Outline" },
                },
            }, { prefix = '<leader>' })
        end,
    },
}
