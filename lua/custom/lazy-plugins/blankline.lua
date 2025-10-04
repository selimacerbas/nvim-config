return {
    {
        "lukas-reineke/indent-blankline.nvim",
        main = "ibl",
        event = { "BufReadPre", "BufNewFile" },

        opts = function()
            -- Recommended hooks from ibl
            local hooks = require("ibl.hooks")
            hooks.register(hooks.type.WHITESPACE, hooks.builtin.hide_first_space_indent_level)
            hooks.register(hooks.type.SCOPE_HIGHLIGHT, hooks.builtin.scope_highlight_from_extmark)

            return {
                -- Use box-drawing vertical bar for cleaner alignment than ASCII '|'
                indent = {
                    char = "│",
                    tab_char = "│",
                },
                scope = {
                    enabled = true,
                    show_start = true,
                    show_end = true,
                },
                -- Keep guides out of special/ephemeral buffers
                exclude = {
                    filetypes = {
                        "help", "alpha", "dashboard", "neo-tree", "NvimTree",
                        "lazy", "mason", "Trouble", "TelescopePrompt",
                        "snacks_picker_input", "spectre_panel", "gitcommit", "gitrebase",
                    },
                    buftypes = { "nofile", "prompt", "terminal", "quickfix" },
                },
            }
        end,

        config = function(_, opts)
            require("ibl").setup(opts)
            -- ⛔️ Removed: all keymaps / which-key registrations for this plugin.
        end,
    },
}
