return {
    {
        "theprimeagen/refactoring.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-treesitter/nvim-treesitter",
            "folke/which-key.nvim",
        },
        config = function()
            -- Initialize refactoring.nvim
            require("refactoring").setup({})

            -- Which-Key integration
            local ok, which_key = pcall(require, "which-key")
            if not ok then return end

            -- Refactor operations in visual mode
            which_key.register({
                r = {
                    name = "Refactor",
                    e = { "<Esc><Cmd>lua require('refactoring').refactor('Extract Function')<CR>", "Extract Function" },
                    f = { "<Esc><Cmd>lua require('refactoring').refactor('Extract Function To File')<CR>", "Extract Function To File" },
                    v = { "<Esc><Cmd>lua require('refactoring').refactor('Extract Variable')<CR>", "Extract Variable" },
                    i = { "<Esc><Cmd>lua require('refactoring').refactor('Inline Variable')<CR>", "Inline Variable" },
                    b = { "<Esc><Cmd>lua require('refactoring').refactor('Extract Block')<CR>", "Extract Block" },
                    r = { "<Esc><Cmd>lua require('refactoring').refactor('Extract Block To File')<CR>", "Extract Block To File" },
                    p = { "<Esc><Cmd>lua require('refactoring').debug.print_var({})<CR>", "Print Variable" },
                },
            }, { prefix = "<leader>", mode = "v" })

            -- Inline variable and debug in normal mode
            which_key.register({
                r = {
                    name = "Refactor",
                    i = { "<Cmd>lua require('refactoring').refactor('Inline Variable')<CR>", "Inline Variable" },
                    p = { "<Cmd>lua require('refactoring').debug.print_var({})<CR>", "Print Variable" },
                },
            }, { prefix = "<leader>", mode = "n" })
        end,
    },
}
