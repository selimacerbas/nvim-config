return {
    {
        'crusj/bookmarks.nvim',
        branch = 'main', -- Use the main branch
        dependencies = { 'nvim-web-devicons' }, -- Optional for icons
        config = function()
            require("bookmarks").setup() -- Default configuration
            require("telescope").load_extension("bookmarks") -- Optional Telescope integration
        end,
    }
}
