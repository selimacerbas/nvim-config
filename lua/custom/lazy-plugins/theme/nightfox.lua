return {

    {
        {
            'EdenEast/nightfox.nvim',
            config = function()
                require('nightfox').setup({
                    options = {
                        styles = {
                            comments = "italic",
                            keywords = "bold",
                        },
                    }
                })
                vim.cmd('colorscheme nightfox') -- Options: 'nightfox', 'duskfox', 'nordfox', etc.
            end
        },

        -- Statusline
        {
            'nvim-lualine/lualine.nvim',
            config = function()
                require('lualine').setup {
                    options = {
                        theme = 'nightfox' -- Match the chosen theme
                    }
                }
            end
        },
    }

    -- Add more plugins below as needed
}
