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
        local luasnip = require('luasnip')
        local compare = cmp.config.compare

        -- kind-priority comparator (yours, unchanged)
        local lspkind_comparator = function(conf)
            local lsp_types = require('cmp.types').lsp
            return function(entry1, entry2)
                if entry1.source.name ~= 'nvim_lsp' then
                    if entry2.source.name == 'nvim_lsp' then
                        return false
                    else
                        return nil
                    end
                end
                local kind1 = lsp_types.CompletionItemKind[entry1:get_kind()]
                local kind2 = lsp_types.CompletionItemKind[entry2:get_kind()]
                if kind1 == 'Variable' and entry1:get_completion_item().label:match('%w*=') then
                    kind1 = 'Parameter'
                end
                if kind2 == 'Variable' and entry2:get_completion_item().label:match('%w*=') then
                    kind2 = 'Parameter'
                end
                local prio1 = conf.kind_priority[kind1] or 0
                local prio2 = conf.kind_priority[kind2] or 0
                if prio1 == prio2 then return nil end
                return prio2 < prio1
            end
        end

        -- NEW: push names with leading underscores lower (e.g. _foo, __bar)
        -- If you started typing an underscore, we don't penalize.
        local underscore_comparator = function(entry1, entry2)
            local function leading_uscore_count(label)
                local m = (label or ''):match('^_+')
                return m and #m or 0
            end
            local function typed_prefix()
                local line   = vim.api.nvim_get_current_line()
                local col    = vim.api.nvim_win_get_cursor(0)[2]
                local before = line:sub(1, col)
                return (before:match('[_%w]*$') or '')
            end

            -- don't penalize if the current prefix begins with "_"
            if typed_prefix():match('^_') then
                return nil
            end

            local l1 = entry1.completion_item.label or ''
            local l2 = entry2.completion_item.label or ''
            local c1 = leading_uscore_count(l1)
            local c2 = leading_uscore_count(l2)

            if c1 ~= c2 then
                -- fewer leading underscores wins
                return c1 < c2
            end
            return nil
        end

        local label_comparator = function(e1, e2)
            return e1.completion_item.label < e2.completion_item.label
        end

        local has_words_before = function()
            local line, col = unpack(vim.api.nvim_win_get_cursor(0))
            if col == 0 then return false end
            local text = vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]
            return text:sub(col, col):match('%s') == nil
        end

        return {
            snippet = { expand = function(args) luasnip.lsp_expand(args.body) end },
            window = {
                completion    = cmp.config.window.bordered(),
                documentation = cmp.config.window.bordered(),
            },
            mapping = cmp.mapping.preset.insert({
                ['<Tab>']      = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        cmp.select_next_item()
                    elseif luasnip.expand_or_jumpable() then
                        luasnip.expand_or_jump()
                    elseif has_words_before() then
                        cmp.complete()
                    else
                        fallback()
                    end
                end, { 'i', 's' }),
                ['<S-Tab>']    = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        cmp.select_prev_item()
                    elseif luasnip.jumpable(-1) then
                        luasnip.jump(-1)
                    else
                        fallback()
                    end
                end, { 'i', 's' }),
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
            sorting = {
                comparators = {
                    compare.exact,         -- keep exact matches on top
                    underscore_comparator, -- 👈 push _foo / __bar lower
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
                    compare.score, -- baseline LSP scoring
                    compare.recently_used,
                    compare.locality,
                    label_comparator, -- alpha as a final tiebreaker
                    compare.order,    -- stable order
                },
            },
            experimental = { ghost_text = true },
            completion = { completeopt = 'menu,menuone,noinsert' },
        }
    end,
    config = function(_, opts)
        require('cmp').setup(opts)

        -- which-key (insert-mode) discoverability; no remaps
        local ok, wk = pcall(require, 'which-key')
        if ok then
            local add = wk.add or wk.register
            add({
                { '<C-Space>', desc = 'Completion: trigger' },
                { '<C-e>',     desc = 'Completion: abort' },
                { '<CR>',      desc = 'Completion: confirm' },
                { '<Tab>',     desc = 'Completion/Snippet: next' },
                { '<S-Tab>',   desc = 'Completion/Snippet: prev' },
                { '<C-b>',     desc = 'Docs: scroll up' },
                { '<C-f>',     desc = 'Docs: scroll down' },
            }, { mode = 'i' })
        end
    end,
}
