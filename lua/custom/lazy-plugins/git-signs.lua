return {

    -- Add Gitsigns plugin for Git integration
    {
        'lewis6991/gitsigns.nvim',
        config = function()
            require('gitsigns').setup({
                signs = {
                    add          = { text = '+' }, -- Added lines
                    change       = { text = '┃' }, -- Thick vertical bar for changes
                    delete       = { text = '_' }, -- Deleted lines
                    topdelete    = { text = '‾' }, -- Top-deleted lines
                    changedelete = { text = '~' }, -- Modified and deleted lines
                },
                current_line_blame = true, -- Enable blame line annotations
            })
        end,
    },

    -- Add more plugins below as needed
}
