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
            { "<leader>Ud",  function() Snacks.dashboard() end,              desc = "Dashboard" },                   -- :contentReference[oaicite:0]{index=0}
            { "<leader>UE",  function() Snacks.explorer() end,               desc = "Explorer" },                    -- :contentReference[oaicite:1]{index=1}
            { "<leader>UT",  function() Snacks.terminal() end,               desc = "Terminal (cwd)" },              -- :contentReference[oaicite:2]{index=2}
            { "<leader>Un",  function() Snacks.notifier.show_history() end,  desc = "Notification history" },        -- :contentReference[oaicite:3]{index=3}
            { "<leader>Ux",  function() Snacks.bufdelete() end,              desc = "Delete buffer (keep layout)" }, -- :contentReference[oaicite:4]{index=4}
            { "<leader>Ur",  function() Snacks.rename.rename_file() end,     desc = "Rename file (LSP-aware)" },     -- :contentReference[oaicite:5]{index=5}
            { "<leader>UZ",  function() Snacks.zen() end,                    desc = "Zen mode" },                    -- :contentReference[oaicite:6]{index=6}
            { "<leader>US",  function() Snacks.scratch.select() end,         desc = "Scratch: select" },             -- :contentReference[oaicite:7]{index=7}
            { "<leader>Us",  function() Snacks.scratch() end,                desc = "Scratch: toggle" },             -- :contentReference[oaicite:8]{index=8}

            -- Pickers (kept to “meta” stuff to avoid colliding with your <leader>f / <leader>F)
            { "<leader>UPk", function() Snacks.picker.keymaps() end,         desc = "Picker: keymaps" },         -- :contentReference[oaicite:9]{index=9}
            { "<leader>UPh", function() Snacks.picker.highlights() end,      desc = "Picker: highlights" },      -- :contentReference[oaicite:10]{index=10}
            { "<leader>UPn", function() Snacks.picker.notifications() end,   desc = "Picker: notifications" },   -- :contentReference[oaicite:11]{index=11}
            { "<leader>UPc", function() Snacks.picker.command_history() end, desc = "Picker: command history" }, -- :contentReference[oaicite:12]{index=12}

            -- Git helpers
            { "<leader>UGb", function() Snacks.gitbrowse() end,              desc = "Git: open in browser" }, -- :contentReference[oaicite:13]{index=13}
            {
                "<leader>UGy",
                function()
                    Snacks.gitbrowse({ open = function(url) vim.fn.setreg("+", url) end, notify = false })
                end,
                desc = "Git: copy remote URL"
            }, -- :contentReference[oaicite:14]{index=14}
        },

        ---@type snacks.Config
        opts = {
            -- Enable high-value Snacks; others stay off unless you want them
            bigfile      = { enabled = true },
            quickfile    = { enabled = true },
            dashboard    = { enabled = true }, -- start screen
            explorer     = { enabled = true }, -- file explorer (picker-based)
            terminal     = { enabled = true },
            picker       = { enabled = true },
            notifier     = { enabled = true },
            scratch      = { enabled = true },
            rename       = { enabled = true },
            words        = { enabled = true }, -- [[ / ]] jumps between LSP refs          -- :contentReference[oaicite:15]{index=15}
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
