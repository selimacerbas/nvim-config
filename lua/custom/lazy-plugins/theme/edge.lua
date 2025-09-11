return {
    {
        "sainnhe/edge",
        lazy = true,
        dependencies = { "folke/which-key.nvim" },

        -- which-key groups (show early)
        init = function()
            local ok, wk = pcall(require, "which-key")
            if ok then
                (wk.add or wk.register)({
                        { "<leader>u",  group = "UI" },
                        { "<leader>uE", group = "Edge" }, -- NOTE: uppercase E
                    })
            end
        end,

        -- keys will lazy-load the theme and run helpers
        keys = function()
            -------------------------------------------------------------------------
            -- State + apply
            -------------------------------------------------------------------------
            local function apply(opts)
                local s = vim.g._edge_custom or {
                    style       = "default", -- "default" | "aura" | "neon"
                    transparent = 0, -- 0 | 1 | 2
                    italic      = true,
                    italic_cmt  = true, -- comments italic
                    gutterless  = true, -- remove signcolumn bg
                    perf        = true, -- better performance
                    background  = "dark", -- "dark" | "light"
                }
                opts    = opts or {}
                s.style = opts.style or s.style
                if opts.transparent ~= nil then s.transparent = opts.transparent end
                if opts.italic ~= nil then s.italic = opts.italic end
                if opts.italic_cmt ~= nil then s.italic_cmt = opts.italic_cmt end
                if opts.gutterless ~= nil then s.gutterless = opts.gutterless end
                if opts.perf ~= nil then s.perf = opts.perf end
                s.background                      = opts.background or s.background
                vim.g._edge_custom                = s

                -- Light/dark first (Edge has a dedicated light variant)
                vim.o.background                  = s.background

                -- Official Edge options (common to Sainnhe’s schemes)
                vim.g.edge_style                  = s.style
                vim.g.edge_transparent_background = s.transparent -- supports 0/1/2
                vim.g.edge_enable_italic          = s.italic and 1 or 0
                vim.g.edge_disable_italic_comment = (s.italic and not s.italic_cmt) and 1 or 0
                vim.g.edge_sign_column_background = s.gutterless and "none" or "bg0"
                vim.g.edge_better_performance     = s.perf and 1 or 0

                -- Load scheme
                vim.cmd.colorscheme("edge")

                -- keep lualine synced (theme = "auto")
                pcall(function() require("lualine").refresh() end)

                vim.notify(
                    ("Edge → %s/%s [%s]%s%s%s%s"):format(
                        s.background, s.style,
                        s.transparent,
                        s.italic and " +italic" or "",
                        (s.italic and not s.italic_cmt) and " -italic-comments" or "",
                        s.gutterless and " +gutterless" or "",
                        s.perf and " +perf" or ""
                    ),
                    vim.log.levels.INFO
                )
            end

            -------------------------------------------------------------------------
            -- Small helpers
            -------------------------------------------------------------------------
            local function cycle_style()
                local order = { "default", "aura", "neon" }
                local s = vim.g._edge_custom or { style = "default" }
                local i = 1
                for k, v in ipairs(order) do if v == s.style then
                        i = k
                        break
                    end end
                apply({ style = order[(i % #order) + 1] })
            end

            local function cycle_transparent()
                local s = vim.g._edge_custom or { transparent = 0 }
                local next = ((s.transparent or 0) + 1) % 3 -- 0 -> 1 -> 2 -> 0
                apply({ transparent = next })
            end

            local function toggle_bg()
                local s = vim.g._edge_custom or { background = vim.o.background or "dark" }
                apply({ background = (s.background == "dark") and "light" or "dark" })
            end

            local function toggle_it()
                local s = vim.g._edge_custom or {}; apply({ italic = not s.italic })
            end
            local function toggle_it_cmt()
                local s = vim.g._edge_custom or {}; apply({ italic_cmt = not s.italic_cmt })
            end
            local function toggle_gutter()
                local s = vim.g._edge_custom or {}; apply({ gutterless = not s.gutterless })
            end
            local function toggle_perf()
                local s = vim.g._edge_custom or {}; apply({ perf = not s.perf })
            end

            return {
                -- Apply presets
                { "<leader>uE1", function() apply({ style = "default" }) end, desc = "Edge: Apply default" },
                { "<leader>uE2", function() apply({ style = "aura" }) end, desc = "Edge: Apply aura" },
                { "<leader>uE3", function() apply({ style = "neon" }) end, desc = "Edge: Apply neon" },
                { "<leader>uEc", cycle_style, desc = "Edge: Cycle styles" },

                -- Light/dark variant
                { "<leader>uEl", toggle_bg, desc = "Edge: Toggle light/dark" },

                -- Toggles
                { "<leader>uEt", cycle_transparent, desc = "Edge: Transparency 0→1→2" },
                { "<leader>uEi", toggle_it, desc = "Edge: Toggle italic" },
                { "<leader>uEI", toggle_it_cmt, desc = "Edge: Toggle italic comments" },
                { "<leader>uEg", toggle_gutter, desc = "Edge: Toggle gutter bg" },
                { "<leader>uEp", toggle_perf, desc = "Edge: Toggle better performance" },
            }
        end,
    },
}
