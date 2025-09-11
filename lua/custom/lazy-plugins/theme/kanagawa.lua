return {

    {
        {
            'rebelot/kanagawa.nvim',
            config = function()
                require('kanagawa').setup({
                    transparent = false,
                    theme = 'default', -- Options: 'default', 'light', 'dragon'
                })
                vim.cmd('colorscheme kanagawa')
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
                        theme = "kanagawa",
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
