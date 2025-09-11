return {
    {
        "sainnhe/everforest",
        lazy = true,
        dependencies = { "folke/which-key.nvim" },

        -- Show group early in which-key
        init = function()
            local ok, wk = pcall(require, "which-key")
            if ok then
                (wk.add or wk.register)({
                        { "<leader>u",  group = "UI" },
                        { "<leader>ue", group = "Everforest" },
                    })
            end
        end,

        -- Keys lazy-load the theme and run helpers
        keys = function()
            ---------------------------------------------------------------------------
            -- State + apply
            ---------------------------------------------------------------------------
            local function apply(opts)
                local s    = vim.g._everforest or {
                    contrast    = "soft", -- "hard" | "medium" | "soft"
                    transparent = 0, -- 0 | 1 | 2
                    italic      = true,
                    italic_cmt  = true, -- comments italic
                    gutterless  = true, -- remove signcolumn/gutter bg
                    perf        = true, -- better performance
                    background  = "dark", -- "dark" | "light"
                }
                opts       = opts or {}
                s.contrast = opts.contrast or s.contrast
                if opts.transparent ~= nil then s.transparent = opts.transparent end
                if opts.italic ~= nil then s.italic = opts.italic end
                if opts.italic_cmt ~= nil then s.italic_cmt = opts.italic_cmt end
                if opts.gutterless ~= nil then s.gutterless = opts.gutterless end
                if opts.perf ~= nil then s.perf = opts.perf end
                s.background                            = opts.background or s.background
                vim.g._everforest                       = s

                -- Light/dark first
                vim.o.background                        = s.background

                -- Official options
                vim.g.everforest_background             = s.contrast
                vim.g.everforest_transparent_background = s.transparent
                vim.g.everforest_enable_italic          = s.italic and 1 or 0
                vim.g.everforest_disable_italic_comment = (s.italic and not s.italic_cmt) and 1 or 0
                vim.g.everforest_sign_column_background = s.gutterless and "none" or "bg0"
                vim.g.everforest_better_performance     = s.perf and 1 or 0

                -- Load it
                vim.cmd.colorscheme("everforest")

                -- keep statusline synced
                pcall(function() require("lualine").refresh() end)

                vim.notify(
                    ("Everforest → %s/%s%s%s%s%s"):format(
                        s.background, s.contrast,
                        s.transparent > 0 and (" +transparent(" .. s.transparent .. ")") or "",
                        s.italic and " +italic" or "",
                        (s.italic and not s.italic_cmt) and " -italic-comments" or "",
                        s.gutterless and " +gutterless" or ""
                    ),
                    vim.log.levels.INFO
                )
            end

            ---------------------------------------------------------------------------
            -- Small helpers
            ---------------------------------------------------------------------------
            local function cycle_contrast()
                local order = { "soft", "medium", "hard" }
                local s = vim.g._everforest or { contrast = "soft" }
                local i = 1
                for k, v in ipairs(order) do if v == s.contrast then
                        i = k
                        break
                    end end
                apply({ contrast = order[(i % #order) + 1] })
            end

            local function cycle_transparent()
                local s = vim.g._everforest or { transparent = 0 }
                local next = ((s.transparent or 0) + 1) % 3 -- 0 -> 1 -> 2 -> 0
                apply({ transparent = next })
            end

            local function toggle_bg()
                local s = vim.g._everforest or { background = vim.o.background or "dark" }
                apply({ background = (s.background == "dark") and "light" or "dark" })
            end

            local function toggle_italic()
                local s = vim.g._everforest or {}; apply({ italic = not s.italic })
            end
            local function toggle_italic_cmt()
                local s = vim.g._everforest or {}; apply({ italic_cmt = not s.italic_cmt })
            end
            local function toggle_gutter()
                local s = vim.g._everforest or {}; apply({ gutterless = not s.gutterless })
            end
            local function toggle_perf()
                local s = vim.g._everforest or {}; apply({ perf = not s.perf })
            end

            return {
                -- Apply defaults quickly
                { "<leader>ue1", function() apply() end, desc = "Everforest: Apply" },

                -- Variants & light/dark
                { "<leader>uec", cycle_contrast, desc = "Everforest: Cycle contrast (soft/med/hard)" },
                { "<leader>uel", toggle_bg, desc = "Everforest: Toggle light/dark" },

                -- Toggles
                { "<leader>uet", cycle_transparent, desc = "Everforest: Transparency 0→1→2" },
                { "<leader>uei", toggle_italic, desc = "Everforest: Toggle italic" },
                { "<leader>ueI", toggle_italic_cmt, desc = "Everforest: Toggle italic comments" },
                { "<leader>ueg", toggle_gutter, desc = "Everforest: Toggle gutter bg" },
                { "<leader>uep", toggle_perf, desc = "Everforest: Toggle better performance" },
            }
        end,
    },
}
