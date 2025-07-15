return {
    {
        'neovim/nvim-lspconfig',
        dependencies = { 'folke/which-key.nvim' },
        config = function()
            local lspconfig               = require('lspconfig')
            local which_key_ok, which_key = pcall(require, 'which-key')

            -- common on_attach for all servers
            local on_attach               = function(client, bufnr)
                local bufmap = function(mode, lhs, rhs, desc)
                    vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
                end

                -- enable omnifunc & tagfunc
                vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
                vim.api.nvim_buf_set_option(bufnr, 'tagfunc', 'v:lua.vim.lsp.tagfunc')
                -- enable formatexpr for `gq`
                vim.api.nvim_buf_set_option(bufnr, 'formatexpr', 'v:lua.vim.lsp.formatexpr()')

                -- Normal-mode LSP mappings
                bufmap('n', 'K', vim.lsp.buf.hover, 'Hover Documentation')
                bufmap('n', 'gd', vim.lsp.buf.definition, 'Go To Definition')
                bufmap('n', 'gD', vim.lsp.buf.declaration, 'Go To Declaration')
                bufmap('n', 'gi', vim.lsp.buf.implementation, 'Go To Implementation')
                bufmap('n', 'gr', vim.lsp.buf.references, 'List References')
                bufmap('n', '[d', function() vim.diagnostic.goto_prev() end, 'Prev Diagnostic')
                bufmap('n', ']d', function() vim.diagnostic.goto_next() end, 'Next Diagnostic')
                bufmap('n', '<C-W>d', vim.diagnostic.open_float, 'Show Diagnostics')
                bufmap('n', '<leader>lR', vim.lsp.buf.rename, 'Rename Symbol')
                bufmap('n', '<leader>la', vim.lsp.buf.code_action, 'Code Action')
                bufmap('n', '<leader>lf', function() vim.lsp.buf.format({ async = true }) end, 'Format Buffer')

                -- Insert-mode Which-Key hints for completions
                if which_key_ok then
                    which_key.register({
                        ['<C-n>'] = { '<C-n>', 'Next Completion' },
                        ['<C-p>'] = { '<C-p>', 'Prev Completion' },
                    }, { mode = 'i' })
                    which_key.register({
                        name  = 'Complete (<C-x>)',
                        o     = { '<C-x><C-o>', 'Omni (LSP)' },
                        f     = { '<C-x><C-f>', 'File-Name' },
                        d     = { '<C-x><C-d>', 'Dictionary' },
                        t     = { '<C-x><C-t>', 'Tag' },
                        ['='] = { '<C-x>=', 'Spelling' },
                    }, { mode = 'i', prefix = '<C-x>' })
                end

                -- Normal-mode Which-Key under <leader>l
                if which_key_ok then
                    which_key.register({
                        l = {
                            name = "LSP",
                            h = { 'K', 'Hover Doc' },
                            d = { 'gd', 'Definition' },
                            D = { 'gD', 'Declaration' },
                            i = { 'gi', 'Implementation' },
                            r = { 'gr', 'References' },
                            R = { '<leader>lR', 'Rename Symbol' },
                            a = { '<leader>la', 'Code Action' },
                            f = { '<leader>lf', 'Format Buffer' },
                            ['['] = { '[d', 'Prev Diagnostic' },
                            [']'] = { ']d', 'Next Diagnostic' },
                        },
                    }, { prefix = '<leader>' })
                end
            end

            -- capabilities for nvim-cmp (if installed)
            local capabilities            = vim.lsp.protocol.make_client_capabilities()
            pcall(function()
                capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)
            end)

            -- -- list of LSP servers to auto-configure
            local servers = {
                --     'pyright', 'tsserver', 'gopls', 'rust_analyzer',
                --     'clangd', 'bashls', 'jsonls', 'yamlls',
            }
            for _, name in ipairs(servers) do
                lspconfig[name].setup {
                    on_attach    = on_attach,
                    capabilities = capabilities,
                }
            end
        end,
    },
}
