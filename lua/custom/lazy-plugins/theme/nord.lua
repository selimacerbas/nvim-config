return {
    {
        "shaunsingh/nord.nvim",
        lazy = true,
        dependencies = { "folke/which-key.nvim" },

        -- Register groups early so they show up in which-key even before loading
        init = function()
            local ok, wk = pcall(require, "which-key")
            if not ok then return end
            (wk.add or wk.register)({
                    { "<leader>u",  group = "UI" },
                    { "<leader>un", group = "Nord" }, -- our Nord-specific actions live here
                })
        end,

        -- Keymaps will lazy-load the plugin and run the functions
        keys = function()
            local function apply_nord(opts)
                local state = vim.g._nord_custom or { transparent = false, borders = true, contrast = true }
                if opts then
                    if opts.transparent ~= nil then state.transparent = opts.transparent end
                    if opts.borders ~= nil then state.borders = opts.borders end
                    if opts.contrast ~= nil then state.contrast = opts.contrast end
                end
                vim.g._nord_custom                 = state

                -- Nord settings
                vim.g.nord_disable_background      = state.transparent
                vim.g.nord_borders                 = state.borders
                vim.g.nord_contrast                = state.contrast
                vim.g.nord_uniform_diff_background = true
                vim.g.nord_italic                  = true
                vim.g.nord_bold                    = true

                vim.o.background                   = "dark"
                require("nord").set()

                -- Optional: improve which-key visibility on Nord
                -- Frost accent for group names, bold for separation
                pcall(vim.api.nvim_set_hl, 0, "WhichKeyGroup", { fg = "#88C0D0", bold = true })

                -- Refresh statusline (follows theme = "auto" in your lualine)
                pcall(function() require("lualine").refresh() end)
                vim.notify("Colorscheme → Nord"
                    .. (state.transparent and " (transparent)" or "")
                    .. (state.borders and "" or " (no borders)"))
            end

            local function toggle_transparent()
                local s = vim.g._nord_custom or {}
                apply_nord({ transparent = not s.transparent })
            end

            local function toggle_borders()
                local s = vim.g._nord_custom or {}
                apply_nord({ borders = not s.borders })
            end

            local function toggle_contrast()
                local s = vim.g._nord_custom or {}
                apply_nord({ contrast = not s.contrast })
            end

            return {
                { "<leader>un1", function() apply_nord() end, desc = "Nord: Apply" },
                { "<leader>unt", toggle_transparent,          desc = "Nord: Toggle transparent" },
                { "<leader>unb", toggle_borders,              desc = "Nord: Toggle borders" },
                { "<leader>unc", toggle_contrast,             desc = "Nord: Toggle contrast" },
                -- convenience command if you prefer :ThemeNord
                {
                    "<leader>un!",
                    function()
                        vim.api.nvim_create_user_command("ThemeNord", function() apply_nord() end, { force = true })
                        vim.cmd("ThemeNord")
                    end,
                    desc = "Nord: Apply (and create :ThemeNord)"
                },
            }
        end,
    },
}
