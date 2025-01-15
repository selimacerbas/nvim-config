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
            'nvim-lualine/lualine.nvim',
            config = function()
                require('lualine').setup {
                    options = {
                        theme = 'kanagawa'
                    }
                }
            end
        },
    }

    -- Add more plugins below as needed
}
