return {

    {
        {
            'sainnhe/everforest',
            config = function()
                vim.g.everforest_background = 'soft' -- Options: 'hard', 'medium', 'soft'
                vim.g.everforest_enable_italic = 1
                vim.cmd('colorscheme everforest')
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
                        theme = "everforest",
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
