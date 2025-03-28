return {
    -- Add autopair plugin for automatic closing of braces, brackets, etc.
    {
        'windwp/nvim-autopairs',
        config = function()
            require('nvim-autopairs').setup({})
        end,
    },

    -- Add more plugins below as needed
}
