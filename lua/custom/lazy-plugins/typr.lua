return {
    {
        "nvzone/typr",
        dependencies = {
            "nvzone/volt", -- core UI library
            "folke/which-key.nvim",
        },
        cmd          = { "Typr", "TyprStats" },
        keys         = {
            { "<leader>wt", "<cmd>Typr<CR>",      desc = "Typr: Start Typing Practice" },
            { "<leader>ws", "<cmd>TyprStats<CR>", desc = "Typr: Show Statistics" },
        },
        opts         = {}, -- no extra setup needed
        config       = function(_, opts)
            require("typr").setup(opts)

            local ok, which_key = pcall(require, "which-key")
            if not ok then return end

            -- Global <leader>w popup
            which_key.register({
                w = {
                    name = "Typr",
                    t    = { "<cmd>Typr<CR>", "Start Typing Practice" },
                    s    = { "<cmd>TyprStats<CR>", "Show Statistics" },
                },
            }, { prefix = "<leader>" })

            -- Contextual hints in the Typr dashboard
            vim.api.nvim_create_autocmd("FileType", {
                pattern = "typr",
                callback = function()
                    which_key.register({
                        s = { "s", "Toggle Symbols" },
                        n = { "n", "Toggle Numbers" },
                        r = { "r", "Randomize Text" },
                        ["1"] = { "1", "Practice 1 Line" },
                        ["2"] = { "2", "Practice 2 Lines" },
                        ["3"] = { "3", "Practice 3 Lines" },
                        ["4"] = { "4", "Practice 4 Lines" },
                        ["5"] = { "5", "Practice 5 Lines" },
                        ["6"] = { "6", "Practice 6 Lines" },
                        ["7"] = { "7", "Practice 7 Lines" },
                        ["8"] = { "8", "Practice 8 Lines" },
                        ["9"] = { "9", "Practice 9 Lines" },
                    }, { mode = "n", buffer = true, prefix = "" })
                end,
            })

            -- Contextual hints in the Stats view
            vim.api.nvim_create_autocmd("FileType", {
                pattern = "typrstats",
                callback = function()
                    which_key.register({
                        D = { "D", "Back to Dashboard" },
                        H = { "H", "History" },
                        K = { "K", "Raw Keystrokes" },
                    }, { mode = "n", buffer = true, prefix = "" })
                end,
            })
        end,
    },
}
