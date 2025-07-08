return {
    {
        'folke/twilight.nvim',
        opts = {}, -- use defaults
        config = function()
            require('twilight').setup({})

            local wk_ok, which_key = pcall(require, 'which-key')
            if not wk_ok then return end

            which_key.register({
                t = {
                    name = "Terminal/Telescope/Twilight",
                    w = { '<cmd>Twilight<CR>', 'Toggle Twilight' },
                },
            }, { prefix = '<leader>' })
        end,
    },
}
