return {
    {
        "folke/todo-comments.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "folke/which-key.nvim",
            -- Optional: show todos inside Trouble if installed
            -- "folke/trouble.nvim",
        },
        opts = {
            -- keep your icons/colors
            keywords = {
                TODO    = { icon = " ", color = "info" },
                NOTE    = { icon = " ", color = "hint" },
                FIXME   = { icon = " ", color = "error" },
                WARNING = { icon = " ", color = "warning" },
                HACK    = { icon = " ", color = "warning" },
                PERF    = { icon = " ", color = "hint" },
            },
            merge_keywords = true, -- keep default synonyms like BUG/FIX/WARN/ISSUE…
            signs = true,
            sign_priority = 8,
            gui_style = { fg = "NONE", bg = "BOLD" },
            highlight = {
                before = "fg",
                keyword = "bg",
                after = "fg",
                pattern = [[.*<(KEYWORDS)\s*:]], -- default; keeps noise low
                comments_only = true,
            },
            search = {
                command = "rg",
                args = {
                    "--color=never", "--no-heading", "--with-filename",
                    "--line-number", "--column", "--smart-case",
                    "--hidden",   -- see dotfiles
                    "--glob", "!**/.git/*", -- but ignore VCS + heavy dirs
                    "--glob", "!**/node_modules/*",
                },
            },
        },
        config = function(_, opts)
            local tc = require("todo-comments")
            tc.setup(opts)

            -- safe_map: only set map if nothing else uses it
            local function safe_map(mode, lhs, rhs, desc)
                if vim.fn.maparg(lhs, mode) == "" then
                    vim.keymap.set(mode, lhs, rhs, { desc = desc, silent = true, noremap = true })
                end
            end

            -- Jumps (kept off <leader> for speed; guarded against conflicts)
            safe_map("n", "]t", function() tc.jump_next() end, "Next TODO comment")
            safe_map("n", "[t", function() tc.jump_prev() end, "Prev TODO comment")

            -- Leader group for discoverability
            safe_map("n", "<leader>zj", "<cmd>TodoNext<CR>", "Next TODO")
            safe_map("n", "<leader>zk", "<cmd>TodoPrev<CR>", "Prev TODO")
            safe_map("n", "<leader>zq", "<cmd>TodoQuickFix<CR>", "Send to QuickFix")
            safe_map("n", "<leader>zl", "<cmd>TodoLocList<CR>", "Send to Location List")
            safe_map("n", "<leader>zs", "<cmd>TodoTelescope<CR>", "Search TODOs")
            safe_map("n", "<leader>zS",
                function()
                    vim.cmd("TodoTelescope keywords=TODO,FIX,FIXME,BUG,WARN,WARNING,PERF,HACK,NOTE")
                end,
                "Search all keywords"
            )
            -- Trouble integration (if present)
            if pcall(require, "trouble") then
                safe_map("n", "<leader>zt", "<cmd>TodoTrouble<CR>", "Open in Trouble")
            end

            -- Which-Key labels (group header; entries already have desc via keymaps)
            local ok, wk = pcall(require, "which-key")
            if ok then
                wk.add({
                    { "<leader>z", group = "Todos" },
                    { "]t",        desc = "Next TODO", mode = "n" },
                    { "[t",        desc = "Prev TODO", mode = "n" },
                })
            end
        end,
    },
}
