return {
    {
        'akinsho/toggleterm.nvim',
        version = "*",
        config = function()
            require('toggleterm').setup {
                size = function(term)
                    if term.direction == "horizontal" then
                        return 15
                    elseif term.direction == "vertical" then
                        return 60
                    end
                end,
                direction = 'float',
                float_opts = {
                    border = 'curved',
                    winblend = 5,
                },
            }

            local Terminal   = require('toggleterm.terminal').Terminal

            local float_term = Terminal:new({ direction = "float", hidden = true })
            local horiz_term = Terminal:new({ direction = "horizontal", hidden = true })
            local vert_term  = Terminal:new({ direction = "vertical", hidden = true })

            vim.keymap.set("n", "<leader>tt", function() float_term:toggle() end, { desc = "Float Terminal" })
            vim.keymap.set("n", "<leader>th", function() horiz_term:toggle() end, { desc = "Horizontal Terminal" })
            vim.keymap.set("n", "<leader>tv", function() vert_term:toggle() end, { desc = "Vertical Terminal" })

            require("which-key").register({
                t = {
                    name = "Terminal/Telescope/Twilight",
                    t = "Float Terminal", -- Later change it to tf after fixing treesitter tff function.
                    h = "Horizontal Terminal",
                    v = "Vertical Terminal",
                },
            }, { prefix = "<leader>" })

            -- Fix: Make <Esc> exit terminal mode. IMPORTANT!
            vim.api.nvim_set_keymap('t', '<Esc>', [[<C-\><C-n>]], { noremap = true, silent = true })
        end,
    }
}
