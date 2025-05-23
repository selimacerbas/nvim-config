return {

    -- Rosepine for Neovim
    {
        'rose-pine/neovim',
        name = 'rose-pine',
        config = function()
            require('rose-pine').setup({
                variant = "auto",      -- auto, main, moon, or dawn
                dark_variant = "main", -- main, moon, or dawn
                dim_inactive_windows = false,
                extend_background_behind_borders = true,

                enable = {
                    terminal = true,
                    legacy_highlights = true, -- Improve compatibility for previous versions of Neovim
                    migrations = true,        -- Handle deprecated options automatically
                },

                styles = {
                    bold = false,
                    italic = false,
                    transparency = false,
                },

                groups = {
                    border = "muted",
                    link = "iris",
                    panel = "surface",

                    error = "love",
                    hint = "iris",
                    info = "subtle",
                    note = "pine",
                    todo = "rose",
                    warn = "gold",

                    git_add = "foam",
                    git_change = "rose",
                    git_delete = "love",
                    git_dirty = "rose",
                    git_ignore = "muted",
                    git_merge = "iris",
                    git_rename = "pine",
                    git_stage = "iris",
                    git_text = "rose",
                    git_untracked = "subtle",

                    h1 = "iris",
                    h2 = "foam",
                    h3 = "rose",
                    h4 = "gold",
                    h5 = "pine",
                    h6 = "foam",
                },
            })

            vim.cmd('colorscheme rose-pine')

            -- Custom highlights for Tree-sitter syntax groups
            vim.api.nvim_set_hl(0, "@type", { fg = "#869688" })     -- Classes
            vim.api.nvim_set_hl(0, "@variable", { fg = "#b4bce0" }) -- Variables
        end
    },


    -- Statusline
    {
        'nvim-lualine/lualine.nvim',
        dependencies = { 'nvim-tree/nvim-web-devicons' },
        config = function()
            require('lualine').setup {
                options = {
                    theme = 'rose-pine',
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
        end,
    },


    -- Add more plugins below as needed
}
