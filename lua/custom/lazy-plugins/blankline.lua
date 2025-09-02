return {
    {
        "lukas-reineke/indent-blankline.nvim",
        main = "ibl",
        event = { "BufReadPre", "BufNewFile" },
        dependencies = { "folke/which-key.nvim" },

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

            -- which-key group and actions (v2/v3 compatible)
            local ok, wk = pcall(require, "which-key")
            if ok then
                local register = wk.add or wk.register
                register({
                    { "<leader>ui",  group = "Indent Guides" },
                    { "<leader>uit", "<cmd>IBLToggle<CR>",   desc = "Toggle Guides" },
                    { "<leader>uie", "<cmd>IBLEnable<CR>",   desc = "Enable Guides" },
                    { "<leader>uid", "<cmd>IBLDisable<CR>",  desc = "Disable Guides" },
                }, { mode = "n", silent = true, noremap = true })
            end
        end,
    },
}
