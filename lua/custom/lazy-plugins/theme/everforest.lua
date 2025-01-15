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
            'nvim-lualine/lualine.nvim',
            config = function()
                require('lualine').setup {
                    options = {
                        theme = 'everforest'
                    }
                }
            end
        },
    }



    -- Add more plugins below as needed
}
