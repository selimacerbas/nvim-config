return {
    'folke/todo-comments.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
        require('todo-comments').setup {
            -- You can customize highlight groups, keywords, and more here
            keywords = {
                TODO = { icon = " ", color = "info" },
                NOTE = { icon = " ", color = "hint" },
                FIXME = { icon = " ", color = "error" },
            },
        }
    end
}
