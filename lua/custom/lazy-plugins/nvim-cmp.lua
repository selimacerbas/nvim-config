return {
    {
        'hrsh7th/nvim-cmp',
        -- event = 'InsertEnter',
        dependencies = {
            'hrsh7th/cmp-nvim-lsp',
            'hrsh7th/cmp-buffer',
            'hrsh7th/cmp-path',
            'saadparwaiz1/cmp_luasnip',
            {
                'L3MON4D3/LuaSnip',
                build = 'make install_jsregexp',
            },
            'folke/which-key.nvim',
        },
        opts = function()
            local cmp = require('cmp')
            return {
                snippet = {
                    expand = function(args)
                        require('luasnip').lsp_expand(args.body)
                    end,
                },
                window = {
                    completion    = cmp.config.window.bordered(),
                    documentation = cmp.config.window.bordered(),
                },
                mapping = cmp.mapping.preset.insert({
                    ['<Tab>']      = cmp.mapping.select_next_item(),
                    ['<S-Tab>']    = cmp.mapping.select_prev_item(),
                    ['<Down>']     = cmp.mapping.select_next_item(),
                    ['<Up>']       = cmp.mapping.select_prev_item(),
                    ['<C-Space>']  = cmp.mapping.complete(),
                    ['<C-x><C-k>'] = cmp.mapping.complete(),     -- Show available options of properties.
                    ['<C-e>']      = cmp.mapping.abort(),
                    ['<Esc>']      = cmp.mapping.abort(),
                    ['<C-b>']      = cmp.mapping.scroll_docs(-4),
                    ['<C-f>']      = cmp.mapping.scroll_docs(4),
                    ['<Left>']     = cmp.mapping.scroll_docs(-4),
                    ['<Right>']    = cmp.mapping.scroll_docs(4),
                    ['<CR>']       = cmp.mapping.confirm({ select = true }),
                }),
                sources = cmp.config.sources({
                    { name = 'nvim_lsp' },
                    { name = 'luasnip' },
                }, {
                    { name = 'buffer' },
                    { name = 'path' },
                }),
                formatting = {
                    format = function(entry, vim_item)
                        vim_item.menu = ({
                            nvim_lsp = "[LSP]",
                            buffer   = "[Buffer]",
                            path     = "[Path]",
                            luasnip  = "[Snippet]",
                        })[entry.source.name]
                        return vim_item
                    end,
                },
            }
        end,
    },
}
