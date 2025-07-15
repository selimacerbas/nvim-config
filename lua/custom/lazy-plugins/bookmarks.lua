return {
    {
        'crusj/bookmarks.nvim',
        branch = 'main',
        dependencies = {
            'nvim-web-devicons',
            'nvim-telescope/telescope.nvim',
            'folke/which-key.nvim',
        },
        keys = {
            { "<leader>bt", "<cmd>lua require('bookmarks').toggle_bookmarks()<CR>",    mode = "n", desc = "Toggle Bookmark List" },
            { "<leader>ba", "<cmd>lua require('bookmarks').add_bookmarks(false)<CR>",  mode = "n", desc = "Add Bookmark" },
            { "<leader>bA", "<cmd>lua require('bookmarks').add_bookmarks(true)<CR>",   mode = "n", desc = "Add Global Bookmark" },
            { "<leader>bd", "<cmd>lua require('bookmarks.list').delete_on_virt()<CR>", mode = "n", desc = "Delete Bookmark" },
            { "<leader>bs", "<cmd>lua require('bookmarks.list').show_desc()<CR>",      mode = "n", desc = "Show Description" },
            { "<leader>bf", "<cmd>Telescope bookmarks<CR>",                            mode = "n", desc = "Find Bookmarks (Telescope)" },
        },
        config = function()
            require('bookmarks').setup()
            require('telescope').load_extension('bookmarks')
        end,
    },
}
