return {
    {
        "folke/todo-comments.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "folke/which-key.nvim",
            { "folke/trouble.nvim", optional = true }, -- optional: open results in Trouble
        },

        -- which-key v3: declare the group here (never inside `keys`)
        init = function()
            local ok, wk = pcall(require, "which-key")
            if ok and wk.add then
                wk.add({ { "<leader>z", group = "Todos" } })
            end
        end,

        opts = {
            keywords = {
                TODO    = { icon = " ", color = "info" },
                NOTE    = { icon = " ", color = "hint" },
                FIXME   = { icon = " ", color = "error" },
                WARNING = { icon = " ", color = "warning" },
                HACK    = { icon = " ", color = "warning" },
                PERF    = { icon = " ", color = "hint" },
            },
            merge_keywords = true,
            signs = true,
            sign_priority = 8,
            gui_style = { fg = "NONE", bg = "BOLD" },
            highlight = {
                before = "fg",
                keyword = "bg",
                after = "fg",
                pattern = [[.*<(KEYWORDS)\s*:]],
                comments_only = true,
            },
            search = {
                command = "rg",
                args = {
                    "--color=never", "--no-heading", "--with-filename",
                    "--line-number", "--column", "--smart-case",
                    "--hidden",
                    "--glob", "!**/.git/*",
                    "--glob", "!**/node_modules/*",
                },
            },
        },

        -- v3 which-key friendly: real mappings in `keys{}` (no safe_map wrapper needed)
        keys = {
            -- quick jumps (non-leader)
            { "]t",         function() require("todo-comments").jump_next() end, desc = "Next TODO",                mode = "n", silent = true, noremap = true },
            { "[t",         function() require("todo-comments").jump_prev() end, desc = "Prev TODO",                mode = "n", silent = true, noremap = true },

            -- leader actions
            { "<leader>zj", function() require("todo-comments").jump_next() end, desc = "Next TODO",                mode = "n", silent = true, noremap = true },
            { "<leader>zk", function() require("todo-comments").jump_prev() end, desc = "Prev TODO",                mode = "n", silent = true, noremap = true },
            { "<leader>zq", "<cmd>TodoQuickFix<CR>",                             desc = "Send to QuickFix",         mode = "n", silent = true, noremap = true },
            { "<leader>zl", "<cmd>TodoLocList<CR>",                              desc = "Send to Location List",    mode = "n", silent = true, noremap = true },
            { "<leader>zs", "<cmd>TodoTelescope<CR>",                            desc = "Search TODOs (Telescope)", mode = "n", silent = true, noremap = true },
            {
                "<leader>zS",
                function()
                    vim.cmd("TodoTelescope keywords=TODO,FIX,FIXME,BUG,WARN,WARNING,PERF,HACK,NOTE")
                end,
                desc = "Search all keywords",
                mode = "n",
                silent = true,
                noremap = true,
            },
            {
                "<leader>zt",
                function()
                    if pcall(require, "trouble") then
                        vim.cmd("TodoTrouble")
                    else
                        vim.notify("Trouble not installed: skipping TodoTrouble", vim.log.levels.INFO)
                    end
                end,
                desc = "Open in Trouble",
                mode = "n",
                silent = true,
                noremap = true,
            },
        },

        config = function(_, opts)
            require("todo-comments").setup(opts)
        end,
    },
}
