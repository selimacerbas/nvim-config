return {
    {
        "rebelot/kanagawa.nvim",
        lazy = true,
        dependencies = { "folke/which-key.nvim" },

        -- Register groups early so they appear in which-key even before loading
        init = function()
            local ok, wk = pcall(require, "which-key")
            if ok then
                (wk.add or wk.register)({
                        { "<leader>u",  group = "UI" },
                        { "<leader>uk", group = "Kanagawa" },
                    })
            end
        end,

        -- Keys lazy-load the plugin on first use
        keys = function()
            local function apply(opts)
                local s = vim.g._kanagawa_custom or {
                    theme        = "wave", -- wave | dragon | lotus
                    transparent  = false,
                    dim_inactive = false,
                    gutterless   = true, -- remove gutter background
                }
                if opts then
                    if opts.theme then s.theme = opts.theme end
                    if opts.transparent ~= nil then s.transparent = opts.transparent end
                    if opts.dim_inactive ~= nil then s.dim_inactive = opts.dim_inactive end
                    if opts.gutterless ~= nil then s.gutterless = opts.gutterless end
                end
                vim.g._kanagawa_custom = s

                -- Light/dark background sync
                vim.o.background = (s.theme == "lotus") and "light" or "dark"

                local colors_cfg = {}
                if s.gutterless then
                    colors_cfg.theme = { all = { ui = { bg_gutter = "none" } } } -- remove sign/gutter bg
                end

                require("kanagawa").setup({
                    transparent    = s.transparent,
                    dimInactive    = s.dim_inactive,
                    terminalColors = true,
                    theme          = s.theme,
                    background     = { dark = "wave", light = "lotus" },
                    colors         = colors_cfg,
                })
                require("kanagawa").load(s.theme)

                -- keep statusline synced (theme="auto")
                pcall(function() require("lualine").refresh() end)

                vim.notify(string.format(
                    "Kanagawa → %s%s%s%s",
                    s.theme,
                    s.transparent and " (transparent)" or "",
                    s.dim_inactive and " (dim inactive)" or "",
                    s.gutterless and " (gutterless)" or ""
                ))
            end

            local function cycle()
                local flavors = { "wave", "dragon", "lotus" }
                local s = vim.g._kanagawa_custom or { theme = "wave" }
                local idx = 1
                for i, f in ipairs(flavors) do if f == s.theme then
                        idx = i
                        break
                    end end
                apply({ theme = flavors[(idx % #flavors) + 1] })
            end
            local function toggle_transparent()
                local s = vim.g._kanagawa_custom or {}; apply({ transparent = not s.transparent })
            end
            local function toggle_dim()
                local s = vim.g._kanagawa_custom or {}; apply({ dim_inactive = not s.dim_inactive })
            end
            local function toggle_gutter()
                local s = vim.g._kanagawa_custom or {}; apply({ gutterless = not s.gutterless })
            end

            return {
                -- Variants
                { "<leader>uk1", function() apply({ theme = "wave" }) end,   desc = "Kanagawa: Wave (dark default)" },
                { "<leader>uk2", function() apply({ theme = "dragon" }) end, desc = "Kanagawa: Dragon (darker)" },
                { "<leader>uk3", function() apply({ theme = "lotus" }) end,  desc = "Kanagawa: Lotus (light)" },
                { "<leader>ukc", cycle,                                      desc = "Kanagawa: Cycle variants" },

                -- Toggles
                { "<leader>ukt", toggle_transparent,                         desc = "Kanagawa: Toggle transparent" },
                { "<leader>ukd", toggle_dim,                                 desc = "Kanagawa: Toggle dim inactive" },
                { "<leader>ukg", toggle_gutter,                              desc = "Kanagawa: Toggle gutter bg" },

                -- Convenience: run compiler if you enable compile=true yourself
                { "<leader>ukC", function() vim.cmd("KanagawaCompile") end,  desc = "Kanagawa: Compile highlights" },
            }
        end,
    },
}
