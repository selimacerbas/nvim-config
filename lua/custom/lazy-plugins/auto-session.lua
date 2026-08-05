return {
    {
        "rmagatti/auto-session",
        -- Mandatory. Autoload cannot work from a lazy trigger: a bare `nvim`
        -- with no file argument never fires BufReadPre or any other lazy event.
        lazy = false,

        dependencies = { "folke/which-key.nvim" },

        init = function()
            -- <leader>W, not <leader>S: treesitter.lua and surround.lua already
            -- register <leader>S as "Treesitter/Surround", and which-key resolves
            -- group labels last-write-wins, so a third claimant would relabel the
            -- popup by import order. "Workspace" also names the wider job here,
            -- since this is the Neovim half of a workspace-restore system that
            -- rebuilds terminal tabs and Claude sessions too.
            local ok, wk = pcall(require, "which-key")
            if ok and wk.add then
                wk.add({ { "<leader>W", group = "Workspace" } })
            end
        end,

        ---@type AutoSession.Config
        opts = {
            -- Never create sessions for these. Without this, a bare `nvim` in
            -- $HOME accumulates a junk session for the home directory.
            suppressed_dirs = { "~/", "~/Downloads", "~/Desktop", "~/Documents", "/" },

            -- Closes windows whose buffer is not backed by a readable file
            -- before autosaving, which keeps tree and picker windows out of a
            -- restored layout.
            --
            -- It does NOT close terminals, whatever the name suggests. The
            -- plugin's own lib.lua guards the close with
            -- `filereadable(name) == 0 and buf_type ~= "terminal"`, so a
            -- terminal window is explicitly exempt. The reason a restored
            -- layout has no dead Claude pane is the `sessionoptions` exclusion
            -- in lua/custom/init.lua, and that line alone. Deleting it because
            -- this option looks like it covers the same ground would silently
            -- bring the dead panes back.
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
            { "<leader>Ws", "<cmd>AutoSession save<cr>",    desc = "Save session" },
            { "<leader>Wr", "<cmd>AutoSession restore<cr>", desc = "Restore session" },
            { "<leader>Wd", "<cmd>AutoSession delete<cr>",  desc = "Delete session" },
            { "<leader>Wl", "<cmd>AutoSession search<cr>",  desc = "Search sessions" },
        },
    },
}
