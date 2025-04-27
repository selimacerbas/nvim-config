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
                    },
                    sections = {
                        -- add mcphub’s status component here
                        lualine_x = {
                            { require('mcphub.extensions.lualine') },
                            -- any other components you already had can go after
                        },
                        -- keep your other sections (a, b, c, y, z) as-is
                    },
                }
            end
        },
    }

    -- Add more plugins below as needed
}
