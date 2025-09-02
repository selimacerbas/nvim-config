return {
    {
        "meznaric/key-analyzer.nvim",
        cmd = { "KeyAnalyzer" }, -- lazy on command
        dependencies = { "folke/which-key.nvim" },

        -- also lazy on these keys
        keys = {
            -- core
            { "<leader>kk",  "<cmd>KeyAnalyzer<CR>",                                        desc = "Key Analyzer: Open (normal)" },

            -- leader prefix analyzers (normal & visual)
            { "<leader>kl",  function() require("key-analyzer").show("n", "<leader>") end,  desc = "Analyze <leader> (normal)" },
            { "<leader>kv",  function() require("key-analyzer").show("v", "<leader>") end,  desc = "Analyze <leader> (visual)" },

            -- mode-focused analyzers (normal & visual)
            { "<leader>kc",  function() require("key-analyzer").show("n", "<C-") end,       desc = "Analyze CTRL combos (normal)" },
            { "<leader>kC",  function() require("key-analyzer").show("v", "<C-") end,       desc = "Analyze CTRL combos (visual)" },
            { "<leader>km",  function() require("key-analyzer").show("n", "<M-") end,       desc = "Analyze Alt/Meta combos (normal)" },
            { "<leader>kM",  function() require("key-analyzer").show("v", "<M-") end,       desc = "Analyze Alt/Meta combos (visual)" },

            -- insert-mode analyzers (CTRL/Alt) — quick health check for your insert maps
            { "<leader>kic", function() require("key-analyzer").show("i", "<C-") end,       desc = "Analyze INSERT CTRL combos" },
            { "<leader>kim", function() require("key-analyzer").show("i", "<M-") end,       desc = "Analyze INSERT Alt/Meta combos" },

            -- project prefixes you use elsewhere (normal + visual where it makes sense)
            { "<leader>kg",  function() require("key-analyzer").show("n", "<leader>g") end, desc = "Analyze Git maps (normal)" },
            { "<leader>kG",  function() require("key-analyzer").show("v", "<leader>g") end, desc = "Analyze Git maps (visual)" },

            { "<leader>kf",  function() require("key-analyzer").show("n", "<leader>f") end, desc = "Analyze Flutter maps (normal)" },
            { "<leader>kF",  function() require("key-analyzer").show("v", "<leader>f") end, desc = "Analyze Flutter maps (visual)" },

            { "<leader>kt",  function() require("key-analyzer").show("n", "<leader>t") end, desc = "Analyze Tabs maps (normal)" },
            { "<leader>kT",  function() require("key-analyzer").show("v", "<leader>t") end, desc = "Analyze Tabs maps (visual)" },

            { "<leader>kb",  function() require("key-analyzer").show("n", "<leader>b") end, desc = "Analyze Bookmarks maps (normal)" },
            { "<leader>kB",  function() require("key-analyzer").show("v", "<leader>b") end, desc = "Analyze Bookmarks maps (visual)" },

            { "<leader>ku",  function() require("key-analyzer").show("n", "<leader>u") end, desc = "Analyze UI maps (normal)" },
            { "<leader>kU",  function() require("key-analyzer").show("v", "<leader>u") end, desc = "Analyze UI maps (visual)" },
        },

        opts = {
            command_name = "KeyAnalyzer",
            layout       = "qwertz", -- switch to "qwerty" if that’s your keyboard
            promotion    = false,    -- hide promo link
            highlights   = { define_default_highlights = true },
        },

        config = function(_, opts)
            require("key-analyzer").setup(opts)

            local ok, wk = pcall(require, "which-key")
            if not ok then return end
            local add = wk.add or wk.register

            -- group labels (v2/v3 compatible)
            add({
                { "<leader>k",   group = "Key Analyzer" },
                { "<leader>kk",  desc = "Open (normal)" },

                -- leader & mode analyzers
                { "<leader>kl",  desc = "Leader (normal)" },
                { "<leader>kv",  desc = "Leader (visual)" },
                { "<leader>kc",  desc = "CTRL (normal)" },
                { "<leader>kC",  desc = "CTRL (visual)" },
                { "<leader>km",  desc = "Alt/Meta (normal)" },
                { "<leader>kM",  desc = "Alt/Meta (visual)" },

                -- insert-mode
                { "<leader>kic", desc = "INSERT CTRL" },
                { "<leader>kim", desc = "INSERT Alt/Meta" },

                -- project prefixes
                { "<leader>kg",  desc = "Git (normal)" },
                { "<leader>kG",  desc = "Git (visual)" },
                { "<leader>kf",  desc = "Flutter (normal)" },
                { "<leader>kF",  desc = "Flutter (visual)" },
                { "<leader>kt",  desc = "Tabs (normal)" },
                { "<leader>kT",  desc = "Tabs (visual)" },
                { "<leader>kb",  desc = "Bookmarks (normal)" },
                { "<leader>kB",  desc = "Bookmarks (visual)" },
                { "<leader>ku",  desc = "UI (normal)" },
                { "<leader>kU",  desc = "UI (visual)" },
            }, { mode = { "n", "v" } })
        end,
    },
}
