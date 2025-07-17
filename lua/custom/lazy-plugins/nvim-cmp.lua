return {
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

        -- 1) Comparator that treats "foo=" style Variables as Parameters, and ranks
        --    all LSP items by a custom priority table.
        local lspkind_comparator = function(conf)
            local lsp_types = require('cmp.types').lsp
            return function(entry1, entry2)
                -- only sort when both are from LSP
                if entry1.source.name ~= 'nvim_lsp' then
                    if entry2.source.name == 'nvim_lsp' then
                        return false
                    else
                        return nil
                    end
                end

                local kind1 = lsp_types.CompletionItemKind[entry1:get_kind()]
                local kind2 = lsp_types.CompletionItemKind[entry2:get_kind()]

                -- treat `foo=` as a Parameter rather than a plain Variable
                if kind1 == 'Variable' and entry1:get_completion_item().label:match('%w*=') then
                    kind1 = 'Parameter'
                end
                if kind2 == 'Variable' and entry2:get_completion_item().label:match('%w*=') then
                    kind2 = 'Parameter'
                end

                local prio1 = conf.kind_priority[kind1] or 0
                local prio2 = conf.kind_priority[kind2] or 0
                if prio1 == prio2 then
                    return nil
                end
                return prio2 < prio1
            end
        end

        -- 2) Fallback: alphabetical by label
        local label_comparator = function(entry1, entry2)
            return entry1.completion_item.label < entry2.completion_item.label
        end

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
                ['<C-x><C-k>'] = cmp.mapping.complete(),
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

            -- 3) Here’s the magic: insert your custom comparators into `sorting`
            sorting = {
                comparators = {
                    -- first, run the LSP‑prioritizer so parameters bubble up
                    lspkind_comparator({
                        kind_priority = {
                            Parameter     = 14,
                            Variable      = 12,
                            Field         = 11,
                            Property      = 11,
                            Constant      = 10,
                            Enum          = 10,
                            EnumMember    = 10,
                            Event         = 10,
                            Function      = 10,
                            Method        = 10,
                            Operator      = 10,
                            Reference     = 10,
                            Struct        = 10,
                            File          = 8,
                            Folder        = 8,
                            Class         = 5,
                            Color         = 5,
                            Module        = 5,
                            Keyword       = 2,
                            Constructor   = 1,
                            Interface     = 1,
                            Snippet       = 0,
                            Text          = 1,
                            TypeParameter = 1,
                            Unit          = 1,
                            Value         = 1,
                        },
                    }),
                    -- then fall back to sorting purely by label
                    label_comparator,
                },
            },
        }
    end,
}
-- return {
--     {
--         'hrsh7th/nvim-cmp',
--         -- event = 'InsertEnter',
--         dependencies = {
--             'hrsh7th/cmp-nvim-lsp',
--             'hrsh7th/cmp-buffer',
--             'hrsh7th/cmp-path',
--             'saadparwaiz1/cmp_luasnip',
--             {
--                 'L3MON4D3/LuaSnip',
--                 build = 'make install_jsregexp',
--             },
--             'folke/which-key.nvim',
--         },
--         opts = function()
--             local cmp = require('cmp')
--             return {
--                 snippet = {
--                     expand = function(args)
--                         require('luasnip').lsp_expand(args.body)
--                     end,
--                 },
--                 window = {
--                     completion    = cmp.config.window.bordered(),
--                     documentation = cmp.config.window.bordered(),
--                 },
--                 mapping = cmp.mapping.preset.insert({
--                     ['<Tab>']      = cmp.mapping.select_next_item(),
--                     ['<S-Tab>']    = cmp.mapping.select_prev_item(),
--                     ['<Down>']     = cmp.mapping.select_next_item(),
--                     ['<Up>']       = cmp.mapping.select_prev_item(),
--                     ['<C-Space>']  = cmp.mapping.complete(),
--                     ['<C-x><C-k>'] = cmp.mapping.complete(),     -- Show available options of properties.
--                     ['<C-e>']      = cmp.mapping.abort(),
--                     ['<Esc>']      = cmp.mapping.abort(),
--                     ['<C-b>']      = cmp.mapping.scroll_docs(-4),
--                     ['<C-f>']      = cmp.mapping.scroll_docs(4),
--                     ['<Left>']     = cmp.mapping.scroll_docs(-4),
--                     ['<Right>']    = cmp.mapping.scroll_docs(4),
--                     ['<CR>']       = cmp.mapping.confirm({ select = true }),
--                 }),
--                 sources = cmp.config.sources({
--                     { name = 'nvim_lsp' },
--                     { name = 'luasnip' },
--                 }, {
--                     { name = 'buffer' },
--                     { name = 'path' },
--                 }),
--                 formatting = {
--                     format = function(entry, vim_item)
--                         vim_item.menu = ({
--                             nvim_lsp = "[LSP]",
--                             buffer   = "[Buffer]",
--                             path     = "[Path]",
--                             luasnip  = "[Snippet]",
--                         })[entry.source.name]
--                         return vim_item
--                     end,
--                 },
--             }
--         end,
--     },
-- }
