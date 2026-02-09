return {
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        dependencies = { "echasnovski/mini.icons" }, -- optional, for nice symbols
        config = function()
            local wk = require("which-key")

            wk.setup({
                plugins = {
                    spelling = { enabled = true, suggestions = 20 },
                },
                -- v3: key label replacements live under `keys`
                keys = {
                    scroll_down = "<c-d>",
                    scroll_up = "<c-u>",
                },
                win = {
                    border = "rounded",
                    no_overlap = true,
                },
                layout = {
                    align = "center",
                },
                icons = {
                    breadcrumb = "»",
                    separator  = "➜",
                    group      = "+",
                },
                show_help = false,
            })

        end,
    },
}
