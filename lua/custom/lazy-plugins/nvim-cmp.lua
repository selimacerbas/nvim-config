return {
    'hrsh7th/nvim-cmp',
    dependencies = {
        'hrsh7th/cmp-nvim-lsp',
        'hrsh7th/cmp-buffer',
        'hrsh7th/cmp-path',
        'saadparwaiz1/cmp_luasnip',
        'L3MON4D3/LuaSnip',
        'folke/which-key.nvim',
    },

    -- which-key v3: define groups/labels here (no keymaps)
    init = function()
        local ok, wk = pcall(require, 'which-key')
        if not ok or not wk.add then return end
        wk.add({
            { '<leader>UC', group = 'Completion bias' }, -- group header
            -- optional insert-mode hints (pure labels, not mappings)
            { '<C-Space>',  desc = 'Completion: trigger',      mode = 'i' },
            { '<C-e>',      desc = 'Completion: abort',        mode = 'i' },
            { '<CR>',       desc = 'Completion: confirm',      mode = 'i' },
            { '<Tab>',      desc = 'Completion/Snippet: next', mode = 'i' },
            { '<S-Tab>',    desc = 'Completion/Snippet: prev', mode = 'i' },
            { '<C-b>',      desc = 'Docs: scroll up',          mode = 'i' },
            { '<C-f>',      desc = 'Docs: scroll down',        mode = 'i' },
        })
    end,

    -- lazy.nvim-managed mappings (will load plugin on first press)
    keys = {
        { '<leader>UCc', '<cmd>CmpBiasClasses<CR>',   mode = 'n', desc = 'CMP bias: Classes first' },
        { '<leader>UCv', '<cmd>CmpBiasVariables<CR>', mode = 'n', desc = 'CMP bias: Variables first' },
        { '<leader>UCf', '<cmd>CmpBiasFunctions<CR>', mode = 'n', desc = 'CMP bias: Functions first' },
        { '<leader>UC0', '<cmd>CmpBiasDefault<CR>',   mode = 'n', desc = 'CMP bias: Reset default' },
    },

    opts = function()
        local cmp = require('cmp')
        local luasnip = require('luasnip')
        local compare = cmp.config.compare

        -- your existing comparators (unchanged)
        local lspkind_comparator = function(conf)
            local lsp_types = require('cmp.types').lsp
            return function(entry1, entry2)
                if entry1.source.name ~= 'nvim_lsp' then
                    if entry2.source.name == 'nvim_lsp' then return false else return nil end
                end
                local kind1 = lsp_types.CompletionItemKind[entry1:get_kind()]
                local kind2 = lsp_types.CompletionItemKind[entry2:get_kind()]
                if kind1 == 'Variable' and entry1:get_completion_item().label:match('%w*=') then kind1 = 'Parameter' end
                if kind2 == 'Variable' and entry2:get_completion_item().label:match('%w*=') then kind2 = 'Parameter' end
                local prio1 = conf.kind_priority[kind1] or 0
                local prio2 = conf.kind_priority[kind2] or 0
                if prio1 == prio2 then return nil end
                return prio2 < prio1
            end
        end

        local underscore_comparator = function(entry1, entry2)
            local function leading_uscore_count(label)
                local m = (label or ''):match('^_+'); return m and #m or 0
            end
            local function typed_prefix()
                local line   = vim.api.nvim_get_current_line()
                local col    = vim.api.nvim_win_get_cursor(0)[2]
                local before = line:sub(1, col)
                return (before:match('[_%w]*$') or '')
            end
            if typed_prefix():match('^_') then return nil end
            local l1 = entry1.completion_item.label or ''
            local l2 = entry2.completion_item.label or ''
            local c1 = leading_uscore_count(l1)
            local c2 = leading_uscore_count(l2)
            if c1 ~= c2 then return c1 < c2 end
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

        -- default priorities (yours)
        local KIND_PRIORITY_DEFAULT = {
            Parameter = 14,
            Variable = 12,
            Field = 11,
            Property = 11,
            Constant = 10,
            Enum = 10,
            EnumMember = 10,
            Event = 10,
            Function = 10,
            Method = 10,
            Operator = 10,
            Reference = 10,
            Struct = 10,
            File = 8,
            Folder = 8,
            Class = 5,
            Color = 5,
            Module = 5,
            Keyword = 2,
            Constructor = 1,
            Interface = 1,
            Snippet = 0,
            Text = 1,
            TypeParameter = 1,
            Unit = 1,
            Value = 1,
        }

        local function make_comparators(kind_prio)
            return {
                compare.exact,
                underscore_comparator,
                lspkind_comparator({ kind_priority = kind_prio }),
                compare.score,
                compare.recently_used,
                compare.locality,
                label_comparator,
                compare.order,
            }
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
            sorting = { comparators = make_comparators(KIND_PRIORITY_DEFAULT) },

            -- expose helpers for config()
            __cmp_bias = {
                default_kind_priority = KIND_PRIORITY_DEFAULT,
                make_comparators = make_comparators,
            },

            experimental = { ghost_text = true },
            completion = { completeopt = 'menu,menuone,noinsert' },
        }
    end,

    config = function(_, opts)
        local cmp = require('cmp')
        cmp.setup(opts)

        -- bias overlays + user commands
        local helpers = opts.__cmp_bias or {}
        local default_prio = vim.deepcopy(helpers.default_kind_priority or {})
        local make_comparators = helpers.make_comparators

        local presets = {
            classes   = { Class = 200, Struct = 195, Interface = 190, Module = 150, TypeParameter = 120, Constructor = 110 },
            variables = { Variable = 200, Field = 195, Property = 195, Parameter = 190, Constant = 180, EnumMember = 175, Value = 160 },
            functions = { Function = 200, Method = 195, Constructor = 190 },
            default   = {},
        }

        local function apply_bias(overlay, label)
            local prio = vim.deepcopy(default_prio)
            for k, v in pairs(overlay) do prio[k] = v end
            cmp.setup({ sorting = { comparators = make_comparators(prio) } })
            vim.notify('CMP bias: ' .. label, vim.log.levels.INFO, { title = 'nvim-cmp' })
        end

        vim.api.nvim_create_user_command('CmpBiasClasses',
            function() apply_bias(presets.classes, 'Classes first') end, {})
        vim.api.nvim_create_user_command('CmpBiasVariables',
            function() apply_bias(presets.variables, 'Variables first') end, {})
        vim.api.nvim_create_user_command('CmpBiasFunctions',
            function() apply_bias(presets.functions, 'Functions first') end, {})
        vim.api.nvim_create_user_command('CmpBiasDefault',
            function() apply_bias(presets.default, 'Default') end, {})
    end,
}
