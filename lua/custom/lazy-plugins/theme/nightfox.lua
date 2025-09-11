return {

    {
        {
            'EdenEast/nightfox.nvim',
            config = function()
                require('nightfox').setup({
                    options = {
                        styles = {
                            comments = "italic",
                            keywords = "bold",
                        },
                    }
                })
                vim.cmd('colorscheme nightfox') -- Options: 'nightfox', 'duskfox', 'nordfox', etc.
            end
        },

        {
            "nvim-lualine/lualine.nvim",
            dependencies = {
                "nvim-tree/nvim-web-devicons",
                { "franco-ruggeri/mcphub-lualine.nvim", lazy = true }, -- MCPHub component
            },
            config = function()
                require("lualine").setup({
                    options = {
                        theme = "nightfox",
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
