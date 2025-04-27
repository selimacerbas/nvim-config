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
