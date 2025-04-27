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
            'nvim-lualine/lualine.nvim',
            config = function()
                require('lualine').setup {
                    options = {
                        theme = 'gruvbox-material'
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
        }, -- Add more plugins below as needed
    },

}
