return {
    {
        'numToStr/Comment.nvim',
        dependencies = { 'folke/which-key.nvim' },
        opts = {}, -- use defaults
        config = function(_, opts)
            require('Comment').setup(opts)

            -- Which-key mappings under <leader>c
            local wk_ok, which_key = pcall(require, 'which-key')
            if not wk_ok then return end

            which_key.register({
                c = {
                    name = "Comment",
                    c = { "<cmd>CommentToggle<CR>", "Toggle Comment" },
                    b = { "<cmd>CommentToggleBlock<CR>", "Toggle Block Comment" },
                },
            }, { prefix = "<leader>" })
        end,
    },
}
