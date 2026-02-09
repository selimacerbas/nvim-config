return {
    {
        "folke/snacks.nvim",
        priority = 1000,
        lazy = false, -- Snacks wants early setup for some modules
        dependencies = { "folke/which-key.nvim" },

        -- which-key groups visible immediately
        init = function()
            local ok, wk = pcall(require, "which-key")
            if ok then
                wk.add({
                    { "<leader>U",  group = "Utils" },
                    { "<leader>UP", group = "Picker (Snacks)" },
                    { "<leader>UE", group = "Explorer" },
                    { "<leader>UT", group = "Terminal" },
                    { "<leader>UN", group = "Notify" },
                    { "<leader>UG", group = "Git" },
                    { "<leader>UZ", group = "Zen" },
                    { "<leader>US", group = "Scratch" },
                })
            end
        end,

        -- ergonomic, non-conflicting mappings (all under <leader>U…)
        keys = {
            -- Core utils
            { "<leader>Ud",  function() Snacks.dashboard() end,              desc = "Dashboard" },
            { "<leader>UE",  function() Snacks.explorer() end,               desc = "Explorer" },
            { "<leader>UT",  function() Snacks.terminal() end,               desc = "Terminal (cwd)" },
            { "<leader>Un",  function() Snacks.notifier.show_history() end,  desc = "Notification history" },
            { "<leader>Ux",  function() Snacks.bufdelete() end,              desc = "Delete buffer (keep layout)" },
            { "<leader>Ur",  function() Snacks.rename.rename_file() end,     desc = "Rename file (LSP-aware)" },
            { "<leader>UZ",  function() Snacks.zen() end,                    desc = "Zen mode" },
            { "<leader>US",  function() Snacks.scratch.select() end,         desc = "Scratch: select" },
            { "<leader>Us",  function() Snacks.scratch() end,                desc = "Scratch: toggle" },

            -- Pickers (kept to "meta" stuff to avoid colliding with your <leader>f / <leader>F)
            { "<leader>UPk", function() Snacks.picker.keymaps() end,         desc = "Picker: keymaps" },
            { "<leader>UPh", function() Snacks.picker.highlights() end,      desc = "Picker: highlights" },
            { "<leader>UPn", function() Snacks.picker.notifications() end,   desc = "Picker: notifications" },
            { "<leader>UPc", function() Snacks.picker.command_history() end, desc = "Picker: command history" },

            -- Git helpers
            { "<leader>UGb", function() Snacks.gitbrowse() end,              desc = "Git: open in browser" },
            {
                "<leader>UGy",
                function()
                    Snacks.gitbrowse({ open = function(url) vim.fn.setreg("+", url) end, notify = false })
                end,
                desc = "Git: copy remote URL"
            },
        },

        ---@type snacks.Config
        opts = {
            -- Enable high-value Snacks; others stay off unless you want them
            bigfile      = { enabled = true },
            quickfile    = { enabled = true },
            dashboard    = { enabled = true },
            explorer     = { enabled = true },
            terminal     = { enabled = true },
            picker       = { enabled = true },
            notifier     = { enabled = true },
            scratch      = { enabled = true },
            rename       = { enabled = true },
            words        = { enabled = true },
            -- UI-heavy modules off by default to avoid surprises; enable if desired:
            indent       = { enabled = false },
            statuscolumn = { enabled = false },
            -- Small niceties
            input        = { enabled = true },
            scroll       = { enabled = true },
            scope        = { enabled = true },
        },
    },
}
