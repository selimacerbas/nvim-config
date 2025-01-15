return {

    {
        {
            'shaunsingh/nord.nvim',
            config = function()
                vim.cmd('colorscheme nord')
            end
        },

        -- Statusline
        {
            'nvim-lualine/lualine.nvim',
            config = function()
                require('lualine').setup {
                    options = {
                        theme = 'nord'
                    }
                }
            end
        },
    }




    -- Add more plugins below as needed
}
