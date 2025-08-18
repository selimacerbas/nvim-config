return {
    {
        'akinsho/toggleterm.nvim',
        version = "*",
        config = function()
            require('toggleterm').setup({
                size = function(term)
                    local ratio = 0.45
                    if term.direction == "horizontal" then
                        return math.floor(vim.o.lines * ratio)
                    elseif term.direction == "vertical" then
                        return math.floor(vim.o.columns * ratio)
                    end
                end,
                persist_size = false,

                -- This only affects floats; splits ignore winblend.
                direction = 'float',
                float_opts = {
                    border = 'curved',
                    winblend = 5,
                },

                -- Optional: avoid extra tinting from ToggleTerm itself
                shade_terminals = false, -- or true with shading_factor = -10 to lighten a bit
                -- shading_factor = -10,
            })

            -- 1) One-time highlight group with no background
            vim.api.nvim_set_hl(0, "ToggleTermTransparent", { bg = "NONE" })

            -- 2) Helper to apply window-local highlights for the opened terminal
            local function make_transparent(term)
                if term.direction ~= "float" then
                    local hl = table.concat({
                        "Normal:ToggleTermTransparent",
                        "NormalNC:ToggleTermTransparent",
                        "SignColumn:ToggleTermTransparent",
                        "EndOfBuffer:ToggleTermTransparent",
                    }, ",")

                    -- New API (0.9+)
                    local ok = pcall(vim.api.nvim_set_option_value, "winhighlight", hl, { win = term.window })
                    if not ok then
                        -- Fallback for older versions
                        vim.api.nvim_win_set_option(term.window, "winhighlight", hl)
                    end
                end
            end

            local Terminal   = require('toggleterm.terminal').Terminal

            local float_term = Terminal:new({ direction = "float", hidden = true }) -- already has winblend via float_opts
            local horiz_term = Terminal:new({ direction = "horizontal", hidden = true, on_open = make_transparent })
            local vert_term  = Terminal:new({ direction = "vertical", hidden = true, on_open = make_transparent })

            vim.keymap.set("n", "<leader>tt", function() float_term:toggle() end, { desc = "Float Terminal" })
            vim.keymap.set("n", "<leader>th", function() horiz_term:toggle() end, { desc = "Horizontal Terminal" })
            vim.keymap.set("n", "<leader>tv", function() vert_term:toggle() end, { desc = "Vertical Terminal" })

            require("which-key").register({
                t = {
                    name = "Terminal/Telescope/Twilight/Treesitter",
                    t = "Float Terminal",
                    h = "Horizontal Terminal",
                    v = "Vertical Terminal",
                },
            }, { prefix = "<leader>" })

            -- Make <Esc> exit terminal-mode
            vim.api.nvim_set_keymap('t', '<Esc>', [[<C-\><C-n>]], { noremap = true, silent = true })
        end,
    }
}
