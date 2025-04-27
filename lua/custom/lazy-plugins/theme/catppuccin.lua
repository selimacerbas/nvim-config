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
                    },
                    sections = {
                        -- add mcphub’s status component here
                        lualine_x = {
                            { require('mcphub.extensions.lualine') },
                            -- any other components you already had can go after
                        },
                        -- keep your other sections (a, b, c, y, z) as-is
                    },
                }
            end
        },
    }



    -- Add more plugins below as needed
}
