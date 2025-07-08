return {
    {
        'numToStr/Comment.nvim',
        dependencies = { 'folke/which-key.nvim' },
        opts = {
            -- keep all default mappings and behavior
            padding = true,
            sticky = true,
            ignore = nil,
            toggler = {
                line  = 'gcc',
                block = 'gbc',
            },
            opleader = {
                line  = 'gc',
                block = 'gb',
            },
            extra = {
                above = 'gcO',
                below = 'gco',
                eol   = 'gcA',
            },
            mappings = {
                basic = true,
                extra = true,
            },
        },
    },
}
