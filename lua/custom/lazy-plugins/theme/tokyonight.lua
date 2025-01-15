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
            'nvim-lualine/lualine.nvim',
            config = function()
                require('lualine').setup {
                    options = {
                        theme = 'tokyonight'
                    }
                }
            end
        },
    }



    -- Add more plugins below as needed
}
