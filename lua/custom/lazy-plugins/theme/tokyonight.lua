return {

    {
        {
            'folke/tokyonight.nvim',
            config = function()
                require('tokyonight').setup({
                    style = 'storm', -- Options: 'storm', 'night', 'day', 'moon'
                    transparent = false,
                })
                vim.cmd('colorscheme tokyonight')
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
                        theme = "tokyonight",
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
