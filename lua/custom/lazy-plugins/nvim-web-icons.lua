return {
    -- nvim-web-devicons for filetype icons
    {
        'nvim-tree/nvim-web-devicons',
        config = function()
            require('nvim-web-devicons').setup({
                -- Default options
                override = {}, -- Override specific icons if needed
                default = true -- Use default icons globally
            })
        end
    },

    -- Add more plugins below as needed
}
