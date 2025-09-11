return {

    {
        {
            'catppuccin/nvim',
            name = 'catppuccin',
            config = function()
                require('catppuccin').setup({
                    flavour = 'mocha', -- Options: 'latte', 'frappe', 'macchiato', 'mocha'
                })
                vim.cmd('colorscheme catppuccin')
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
                        theme = "catppuccin",
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
