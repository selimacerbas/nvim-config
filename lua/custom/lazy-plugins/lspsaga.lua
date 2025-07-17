return {
    -- LSP Saga for enhanced LSP UI
    {
        'glepnir/lspsaga.nvim',
        dependencies = {
            'nvim-tree/nvim-web-devicons',
            'folke/which-key.nvim',
        },
        config = function()
            -- Saga setup: use <CR> to open/close finder entries
            require('lspsaga').setup({
                finder = {
                    keys = {
                        toggle_or_open = 'o',
                        vsplit         = 's',
                        split          = 'i',
                        tabe           = 't',
                        tabnew         = 'r',
                        quit           = 'q',
                        close          = '<C-c>k',
                    },
                },
                lightbulb = { enable = false },
            })

            local map = vim.keymap.set
            -- core mappings
            -- map('n', 'K', '<cmd>Lspsaga hover_doc<CR>', { silent = true, desc = "Saga: Hover Doc" })
            map('n', 'gh', '<cmd>Lspsaga finder<CR>', { silent = true, desc = "Saga: Finder" })
            map('n', 'gd', '<cmd>Lspsaga goto_definition<CR>', { silent = true, desc = "Saga: Definition" })
            map('n', 'gD', '<cmd>Lspsaga goto_declaration<CR>', { silent = true, desc = "Saga: Declaration" })
            map('n', 'gp', '<cmd>Lspsaga peek_definition<CR>', { silent = true, desc = "Saga: Peek Definition" })
            map('n', 'F', '<cmd>lua vim.lsp.buf.format({ async = true })<CR>', { silent = true, desc = "Format Buffer" })
            vim.keymap.set('i', '<C-k>', function() vim.lsp.buf.signature_help() end,
                { silent = true, desc = "LSP: Signature Help" })
            -- make <Esc> and q close the hover window when it's focused
            vim.api.nvim_create_autocmd("FileType", {
                pattern = "LspsagaHover",
                callback = function()
                    vim.keymap.set("n", "<Esc>", "<cmd>Lspsaga hover_doc<CR>", { buffer = true, silent = true })
                    vim.keymap.set("n", "q", "<cmd>Lspsaga hover_doc<CR>", { buffer = true, silent = true })
                end,
            })

            -- Which-key group under <leader>l
            local wk_ok, which_key = pcall(require, 'which-key')
            if not wk_ok then return end

            which_key.register({
                l = {
                    name = "LSP",
                    h = { '<cmd>Lspsaga hover_doc<CR>', "Hover Doc" },
                    f = { '<cmd>Lspsaga finder<CR>', "Finder / References" },
                    g = { '<cmd>Lspsaga goto_definition<CR>', "Definition" },
                    D = { '<cmd>Lspsaga goto_declaration<CR>', "Declaration" },
                    p = { '<cmd>Lspsaga peek_definition<CR>', "Peek Definition" },
                    r = { '<cmd>Lspsaga rename<CR>', "Rename Symbol" },
                    a = { '<cmd>Lspsaga code_action<CR>', "Code Action" },
                    R = { '<cmd>Lspsaga show_line_diagnostics<CR>', "Line Diagnostics" },
                    d = { '<cmd>Lspsaga show_cursor_diagnostics<CR>', "Cursor Diagnostics" },
                    o = { '<cmd>Lspsaga outline<CR>', "Symbol Outline" },
                },
            }, { prefix = '<leader>' })
        end,
    },
}
