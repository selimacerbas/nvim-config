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
            'nvim-lualine/lualine.nvim',
            config = function()
                require('lualine').setup {
                    options = {
                        theme = 'catppuccin'
                    }
                }
            end
        },
    }



    -- Add more plugins below as needed
}
