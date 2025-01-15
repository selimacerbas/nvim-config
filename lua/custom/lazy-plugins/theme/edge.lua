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
            'nvim-lualine/lualine.nvim',
            config = function()
                require('lualine').setup {
                    options = {
                        theme = 'edge'
                    }
                }
            end
        },
    }



    -- Add more plugins below as needed
}
