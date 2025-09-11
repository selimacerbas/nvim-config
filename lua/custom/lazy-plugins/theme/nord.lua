return {
    -- Nord theme (installed, but not applied automatically)
    {
        "shaunsingh/nord.nvim",
        lazy = true,
    },

    -- Statusline: follow active colorscheme + keep your MCPHub/Pipeline badges
    {
        "nvim-lualine/lualine.nvim",
        dependencies = {
            "nvim-tree/nvim-web-devicons",
            { "franco-ruggeri/mcphub-lualine.nvim", lazy = true }, -- MCPHub component
        },
        config = function()
            require("lualine").setup({
                options = {
                    theme = "nord",
                },
                sections = {
                    lualine_x = {
                        { "mcphub", icon = "󰐻 " }, -- shows active MCP servers / spinner
                        { "pipeline", icon = "" }, -- ← latest CI run status
                        -- your other components can follow here
                    },
                },
            })
        end,
    },
}
