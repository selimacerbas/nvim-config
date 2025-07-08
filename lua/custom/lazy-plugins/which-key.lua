return {
    {
        "folke/which-key.nvim",
        dependencies = { "echasnovski/mini.icons" }, -- Optional dependency
        config = function()
            local wk = require("which-key")

            wk.setup({
                plugins = {
                    spelling = {
                        enabled = true,
                        suggestions = 20,
                    },
                },
                replace = {
                    ["<space>"] = "SPC",
                    ["<cr>"] = "RET",
                    ["<tab>"] = "TAB",
                },
                win = {
                    border = "rounded",
                },
                layout = {
                    align = "center",
                },
            })
        end,
    },
}
