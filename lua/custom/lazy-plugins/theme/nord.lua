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
        opts = {
            options = {
                theme = "auto", -- ← auto-detect from current colorscheme (nord / rose-pine / etc.)
            },
            sections = {
                lualine_x = {
                    { "mcphub", icon = "󰐻 " }, -- active MCP servers
                    { "pipeline", icon = "" }, -- latest CI run status (pipeline.nvim)
                    -- …your other components
                },
            },
        },
    },
}
