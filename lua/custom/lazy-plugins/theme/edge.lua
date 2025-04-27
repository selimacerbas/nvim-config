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
