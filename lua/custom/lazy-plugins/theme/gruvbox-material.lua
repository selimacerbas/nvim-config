return {

    {
        {
            'sainnhe/gruvbox-material',
            config = function()
                vim.g.gruvbox_material_background = 'soft' -- Options: 'hard', 'medium', 'soft'
                vim.g.gruvbox_material_enable_italic = 1
                vim.cmd('colorscheme gruvbox-material')
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
                        theme = "gruvbox-material",
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
    },

}
