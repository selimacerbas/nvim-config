return {
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        dependencies = { "echasnovski/mini.icons" }, -- optional, for nice symbols
        config = function()
            local wk = require("which-key")

            wk.setup({
                plugins = {
                    spelling = { enabled = true, suggestions = 20 }, -- shows z= suggestions nicely
                },
                -- Show prettier labels for these keys in the popup
                replace = {
                    ["<space>"] = "SPC",
                    ["<cr>"]    = "RET",
                    ["<tab>"]   = "TAB",
                },
                win = {
                    border = "rounded",
                    no_overlap = true, -- avoid covering the statusline/cmdline if possible
                },
                layout = {
                    align = "center",
                },
                icons = {
                    breadcrumb = "»",
                    separator  = "➜",
                    group      = "+",
                },
                show_help = false, -- popup stays clean; use :h which-key for docs
            })

        end,
    },
}
