return {
    -- toggleterm Terminal
    {
        'akinsho/toggleterm.nvim',
        config = function()
            require('toggleterm').setup {
                direction = 'float',   -- Terminal opens in a floating window
                float_opts = {
                    border = 'curved', -- Border style for the floating terminal
                    winblend = 5,
                    pumblend = 5,
                },
            }
        end
    },

    -- Add more plugins below as needed
}
