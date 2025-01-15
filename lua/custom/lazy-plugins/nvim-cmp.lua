return {
    -- nvim-cmp: Autocompletion plugin
    {
        'hrsh7th/nvim-cmp',
        dependencies = {
            'hrsh7th/cmp-nvim-lsp',              -- LSP source for nvim-cmp
            'hrsh7th/cmp-buffer',                -- Buffer source for nvim-cmp
            'hrsh7th/cmp-path',                  -- Path completion source for nvim-cmp
            'saadparwaiz1/cmp_luasnip',          -- LuaSnip source for nvim-cmp
            {
                'L3MON4D3/LuaSnip',              -- LuaSnip snippet engine
                build = "make install_jsregexp", -- Add this to install jsregexp for transformations
            },
        },
        config = function()
            local cmp = require 'cmp'

            cmp.setup {
                snippet = {
                    expand = function(args)
                        require('luasnip').lsp_expand(args.body)
                    end,
                },

                window = {
                    completion = cmp.config.window.bordered(),
                    documentation = cmp.config.window.bordered(),
                },

                mapping = {
                    ['<Tab>'] = cmp.mapping.select_next_item(),
                    ['<S-Tab>'] = cmp.mapping.select_prev_item(),
                    ['<Down>'] = cmp.mapping.select_next_item(),
                    ['<Up>'] = cmp.mapping.select_prev_item(),
                    ['<C-Space>'] = cmp.mapping.complete(),
                    ['<C-k>'] = cmp.mapping.complete(), -- Alternate mapping
                    ['<C-e>'] = cmp.mapping.abort(),
                    ['<Esc>'] = cmp.mapping.abort(),
                    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
                    ['<C-f>'] = cmp.mapping.scroll_docs(4),
                    ['<Left>'] = cmp.mapping.scroll_docs(-4),
                    ['<Right>'] = cmp.mapping.scroll_docs(4),
                    ['<CR>'] = cmp.mapping.confirm({ select = true }),
                },
                sources = {
                    { name = 'nvim_lsp' },
                    { name = 'buffer' },
                    { name = 'path' },
                    { name = 'luasnip' },
                },
                formatting = {
                    -- Added enhanced formatting with icons and source names
                    format = function(entry, vim_item)
                        vim_item.menu = ({
                            nvim_lsp = "[LSP]",
                            buffer = "[Buffer]",
                            path = "[Path]",
                            luasnip = "[Snippet]",
                        })[entry.source.name]
                        return vim_item
                    end,
                },
            }
        end
    },

    -- {
    --     "L3MON4D3/LuaSnip",
    --     build = "make install_jsregexp", -- Optional build step for jsregexp support
    --     config = function()
    --         require("luasnip").setup()
    --     end,
    -- },
}
