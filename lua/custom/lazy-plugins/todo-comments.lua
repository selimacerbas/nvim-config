return {
    'folke/todo-comments.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
        require('todo-comments').setup {
            keywords = {
                TODO = { icon = " ", color = "info" },
                NOTE = { icon = " ", color = "hint" },
                FIXME = { icon = " ", color = "error" },
                WARNING = { icon = " ", color = "warning" },
                HACK = { icon = " ", color = "warning" },
                PERF = { icon = " ", color = "hint" },
            },
        }
    end
}
