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
                    }
                }
            end
        }, -- Add more plugins below as needed
    },

}
