return {
    {
        "folke/which-key.nvim",
        dependencies = { "echasnovski/mini.icons" }, -- Optional dependency
        config = function()
            require("which-key").setup({
                -- Add your customization options here
                plugins = {
                    spelling = {
                        enabled = true, -- Show suggestions for spelling
                        suggestions = 20,
                    },
                },
                replace = {
                    -- Override display of certain keys
                    ["<space>"] = "SPC",
                    ["<cr>"] = "RET",
                    ["<tab>"] = "TAB",
                },
                win = {
                    border = "rounded", -- none, single, double, shadow
                },
                layout = {
                    align = "center", -- align columns left, center, or right
                },
            })
        end,
    },
}
