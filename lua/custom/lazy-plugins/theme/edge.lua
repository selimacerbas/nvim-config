return {

    {
        {
            'sainnhe/edge',
            config = function()
                vim.g.edge_style = 'aura' -- Options: 'default', 'aura', 'neon'
                vim.cmd('colorscheme edge')
            end
        },

        -- Statusline
        {
            "nvim-lualine/lualine.nvim",
            dependencies = {
                "nvim-tree/nvim-web-devicons",
                { "franco-ruggeri/mcphub-lualine.nvim", lazy = true }, -- MCPHub component
            },
            config = function()
                require("lualine").setup({
                    options = {
                        theme = "edge",
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



    -- Add more plugins below as needed
}
