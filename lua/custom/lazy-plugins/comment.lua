return {
    {
        "numToStr/Comment.nvim",
        event = { "BufReadPre", "BufNewFile" },
        dependencies = { "folke/which-key.nvim" },
        opts = function()
            -- If ts-context-commentstring is installed, wire it automatically.
            local ok, tscc = pcall(require, "ts_context_commentstring.integrations.comment_nvim")
            return {
                -- keep all defaults; only add pre_hook when available
                padding = true,
                sticky = true,
                ignore = nil,
                mappings = { basic = true, extra = true },
                pre_hook = ok and tscc.create_pre_hook() or nil, -- enable tsx/jsx-aware comments when available
            }
        end,

        -- Lazy-load on first use of our leader helpers too
        keys = {
            -- NORMAL
            {
                "<leader>cc",
                function() require("Comment.api").toggle.linewise.current() end,
                mode = "n",
                desc = "Comment: toggle line"
            },
            {
                "<leader>cB",
                function() require("Comment.api").toggle.blockwise.current() end,
                mode = "n",
                desc = "Comment: toggle block"
            },

            -- VISUAL (preserve selection, then operate)
            {
                "<leader>cc",
                function()
                    local esc = vim.api.nvim_replace_termcodes("<ESC>", true, false, true)
                    vim.api.nvim_feedkeys(esc, "nx", false)
                    require("Comment.api").toggle.linewise(vim.fn.visualmode())
                end,
                mode = "v",
                desc = "Comment: toggle line (visual)"
            },

            {
                "<leader>cB",
                function()
                    local esc = vim.api.nvim_replace_termcodes("<ESC>", true, false, true)
                    vim.api.nvim_feedkeys(esc, "nx", false)
                    require("Comment.api").toggle.blockwise(vim.fn.visualmode())
                end,
                mode = "v",
                desc = "Comment: toggle block (visual)"
            },
        },

        config = function(_, opts)
            require("Comment").setup(opts) -- sets up defaults like gcc/gbc/gc/gb/gcO/gco/gcA :contentReference[oaicite:2]{index=2}

            -- which-key discoverability without overriding native mappings
            local ok, wk = pcall(require, "which-key")
            if ok then
                local add = wk.add or wk.register

                -- Leader group (helpers we provided)
                -- add({ { "<leader>c", group = "Comment" } }, { mode = "n" })

                -- Show native Comment.nvim maps under the normal `g` prefix
                add({
                    { "gc", group = "Linewise comment" },
                    { "gb", group = "Blockwise comment" },
                }, { mode = { "n", "v" }, prefix = "g" })

                -- Extra one-keystroke hints after `gc` (these already exist; we’re just labeling)
                add({
                    { "A", desc = "Comment end of line (gcA)" },
                    { "o", desc = "Comment below (gco)" },
                    { "O", desc = "Comment above (gcO)" },
                }, { mode = "n", prefix = "gc" })
            end
        end,
    },
}
