return {
    {
        "rmagatti/auto-session",
        -- Mandatory. Autoload cannot work from a lazy trigger: a bare `nvim`
        -- with no file argument never fires BufReadPre or any other lazy event.
        lazy = false,

        dependencies = { "folke/which-key.nvim" },

        init = function()
            local ok, wk = pcall(require, "which-key")
            if ok and wk.add then
                wk.add({ { "<leader>S", group = "Session" } })
            end
        end,

        ---@type AutoSession.Config
        opts = {
            -- Never create sessions for these. Without this, a bare `nvim` in
            -- $HOME accumulates a junk session for the home directory.
            suppressed_dirs = { "~/", "~/Downloads", "~/Desktop", "~/Documents", "/" },

            -- Terminal and tree windows are not backed by a normal file. Closing
            -- them before save is what keeps a restored layout free of dead
            -- windows, and it pairs with excluding `terminal` from
            -- sessionoptions in Task 1.
            close_unsupported_windows = true,

            -- Do not save a session whose only buffer is a dashboard.
            bypass_save_filetypes = { "snacks_dashboard", "alpha", "dashboard", "lazy" },

            -- Drop sessions untouched for 30 days, matching Claude Code's own
            -- default cleanupPeriodDays so the two halves age out together.
            purge_after_minutes = 43200,

            -- Surface restore failures rather than silently starting blank.
            show_auto_restore_notif = true,
        },

        keys = {
            { "<leader>Ss", "<cmd>AutoSession save<cr>",    desc = "Save session" },
            { "<leader>Sr", "<cmd>AutoSession restore<cr>", desc = "Restore session" },
            { "<leader>Sd", "<cmd>AutoSession delete<cr>",  desc = "Delete session" },
            { "<leader>Sl", "<cmd>AutoSession search<cr>",  desc = "Search sessions" },
        },
    },
}
