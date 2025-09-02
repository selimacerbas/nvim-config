return {
    {
        'windwp/nvim-autopairs',
        -- event = 'InsertEnter', -- lazy-load for speed
        dependencies = { 'folke/which-key.nvim' },
        opts = function()
            -- Only turn on Treesitter-aware pairing if TS is installed
            local has_ts = pcall(require, 'nvim-treesitter.parsers')

            return {
                check_ts = has_ts,
                ts_config = {
                    -- don't pair inside strings/comments (when TS is available)
                    lua = { 'string', 'comment' },
                    javascript = { 'template_string', 'string', 'comment' },
                    java = false, -- keep Java simple (no TS checks)
                },
                -- keep your custom ignores
                disable_filetype = { 'TelescopePrompt', 'spectre_panel', 'snacks_picker_input' },

                -- keep your fast-wrap but let the plugin handle the mapping itself
                fast_wrap = {
                    map = '<M-e>',
                    chars = { '{', '[', '(', '"', "'" },
                    pattern = [=[[%'%"%>%]%)%}%,]]=],
                    end_key = '$',
                    keys = 'qwertyuiopzxcvbnmasdfghjkl',
                    cursor_pos = true,
                },

                -- small quality-of-life tweaks
                enable_check_bracket_line = false, -- add pairs even if a closing exists later on the line
                map_c_h = true,                    -- <C-h> deletes pair intelligently in insert mode
                map_c_w = true,                    -- <C-w> deletes pair word-wise in insert mode
            }
        end,
        config = function(_, opts)
            local npairs = require('nvim-autopairs')
            local Rule   = require('nvim-autopairs.rule')
            local cond   = require('nvim-autopairs.conds')

            npairs.setup(opts)

            -- TeX $$…$$ rule, but don’t pair if next char is %
            npairs.add_rule(
                Rule('$$', '$$', 'tex')
                :with_pair(cond.not_after_regex('%%'))
            )

            -- Space inside brackets: (|) -> ( | ), etc.
            npairs.add_rules({
                Rule(' ', ' ')
                    :with_pair(function(ctx)
                        local pair = ctx.line:sub(ctx.col - 1, ctx.col)
                        return pair == '()' or pair == '[]' or pair == '{}'
                    end),
            })

            -- Optional nvim-cmp integration (auto-insert () after confirm)
            local ok_cmp, cmp = pcall(require, 'cmp')
            if ok_cmp then
                local cmp_autopairs = require('nvim-autopairs.completion.cmp')
                cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done({ map_char = { tex = '' } }))
            end

            -- Simple toggle command (global)
            local enabled = true
            vim.api.nvim_create_user_command('AutoPairsToggle', function()
                enabled = not enabled
                if enabled then
                    npairs.enable()
                    vim.notify('nvim-autopairs: enabled')
                else
                    npairs.disable()
                    vim.notify('nvim-autopairs: disabled')
                end
            end, {})

            -- which-key: names + safe, non-conflicting helpers under <leader>p
            local wk_ok, wk = pcall(require, 'which-key')
            if wk_ok then
                -- v3 uses :add, v2 uses :register — support both
                local register = wk.add or wk.register
                register({
                    { '<leader>p',  group = 'Pairs' },
                    { '<leader>pt', '<cmd>AutoPairsToggle<CR>',                                         desc = 'Toggle enable/disable' },
                    { '<leader>pc', function() require('nvim-autopairs').clear_rules() end,             desc = 'Clear all custom rules' },
                    -- Don’t bind Fast Wrap to a leader key (it’s an insert-mode action);
                    -- give a discoverable helper instead:
                    { '<leader>pe', function() vim.notify('Fast Wrap: press <M-e> in INSERT mode') end, desc = 'Fast Wrap (how-to)' },
                }, { mode = 'n', silent = true, noremap = true })
            end
        end,
    },
}
