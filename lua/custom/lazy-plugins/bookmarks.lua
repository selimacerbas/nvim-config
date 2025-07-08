return {
    {
        'crusj/bookmarks.nvim',
        branch = 'main',
        dependencies = {
            'nvim-web-devicons',
            'nvim-telescope/telescope.nvim',
            'folke/which-key.nvim',
        },
        config = function()
            -- Basic setup
            require('bookmarks').setup()
            require('telescope').load_extension('bookmarks')

            -- Which-key mappings under <leader>b
            local wk_ok, which_key = pcall(require, 'which-key')
            if not wk_ok then return end

            which_key.register({
                b = {
                    name = "Bookmarks",
                    t = { "<cmd>lua require('bookmarks').toggle_bookmarks()<CR>", "Toggle List" },
                    a = { "<cmd>lua require('bookmarks').add_bookmarks(false)<CR>", "Add Bookmark" },
                    A = { "<cmd>lua require('bookmarks').add_bookmarks(true)<CR>", "Add Global Bookmark" },
                    d = { "<cmd>lua require('bookmarks.list').delete_on_virt()<CR>", "Delete Bookmark" },
                    s = { "<cmd>lua require('bookmarks.list').show_desc()<CR>", "Show Description" },
                    f = { "<cmd>Telescope bookmarks<CR>", "Find via Telescope" },
                },
            }, { prefix = "<leader>" })
        end,
    },
}
