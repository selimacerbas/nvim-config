return {
    {
        "meznaric/key-analyzer.nvim",
        dependencies = {
            "folke/which-key.nvim",
        },
        cmd = { "KeyAnalyzer" }, -- plugin command
        keys = {
            { "<leader>kk", "<cmd>KeyAnalyzer<CR>",                                       desc = "Key Analyzer: Open (normal mode)" },

            -- Handy presets
            { "<leader>kl", function() require("key-analyzer").show("n", "<leader>") end, desc = "Analyze <leader> maps (normal)" },
            { "<leader>kv", function() require("key-analyzer").show("v", "<leader>") end, desc = "Analyze <leader> maps (visual)" },
            { "<leader>kc", function() require("key-analyzer").show("n", "<C-") end,      desc = "Analyze CTRL combos" },
            { "<leader>km", function() require("key-analyzer").show("n", "<M-") end,      desc = "Analyze Alt/Meta combos" },
        },
        opts = {
            -- command_name = "KeyAnalyzer",
            -- layout = "qwerty", -- change to "qwertz" (CH/DE), "azerty", "dvorak", etc.
            -- promotion = true,  -- set to false to hide the promo link
            -- highlights = { ... } -- see :h key-analyzer.options
        },
        config = function(_, opts)
            require("key-analyzer").setup(opts)

            local ok, which_key = pcall(require, "which-key")
            if not ok then return end

            which_key.register({
                k = {
                    name = "Key Analyzer",
                    k = { "<cmd>KeyAnalyzer<CR>", "Open (normal mode)" },
                    l = { function() require("key-analyzer").show("n", "<leader>") end, "Leader maps (normal)" },
                    v = { function() require("key-analyzer").show("v", "<leader>") end, "Leader maps (visual)" },
                    c = { function() require("key-analyzer").show("n", "<C-") end, "CTRL combos" },
                    m = { function() require("key-analyzer").show("n", "<M-") end, "Alt/Meta combos" },
                },
            }, { prefix = "<leader>" })
        end,
    },
}
