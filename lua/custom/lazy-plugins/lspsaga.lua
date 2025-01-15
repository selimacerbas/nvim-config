return {
    -- LSP Saga for enhanced LSP UI
    {
        'glepnir/lspsaga.nvim',
        dependencies = {
            'nvim-tree/nvim-web-devicons',
        },
        config = function()
            local saga = require('lspsaga')
            saga.setup({
                lightbulb = {
                    enable = false, -- Disable the lightbulb feature
                },
            })
        end
    },
}
