return {
    {
        "sainnhe/gruvbox-material",
        lazy = true,
        dependencies = { "folke/which-key.nvim" },

        -- Show group early in which-key
        init = function()
            local ok, wk = pcall(require, "which-key")
            if ok then
                (wk.add or wk.register)({
                        { "<leader>u",  group = "UI" },
                        { "<leader>ug", group = "Gruvbox Material" },
                    })
            end
        end,

        -- Keys lazy-load the scheme and run the helpers
        keys = function()
            ---------------------------------------------------------------------------
            -- State + apply helper
            ---------------------------------------------------------------------------
            local function apply(opts)
                local s    = vim.g._gruvboxmat or {
                    contrast    = "soft", -- "hard" | "medium" | "soft"
                    palette     = "material", -- "material" | "mix" | "original"
                    transparent = 0, -- 0 | 1 | 2
                    italic      = true,
                    bold        = true,
                    gutterless  = true, -- remove signcolumn/gutter bg
                    background  = "dark", -- "dark" | "light"
                }
                opts       = opts or {}
                s.contrast = opts.contrast or s.contrast
                s.palette  = opts.palette or s.palette
                if opts.transparent ~= nil then s.transparent = opts.transparent end
                if opts.italic ~= nil then s.italic = opts.italic end
                if opts.bold ~= nil then s.bold = opts.bold end
                if opts.gutterless ~= nil then s.gutterless = opts.gutterless end
                s.background                                  = opts.background or s.background
                vim.g._gruvboxmat                             = s

                -- Set vim background first (controls light/dark variant)
                vim.o.background                              = s.background

                -- Core gruvbox-material options (new + old names for palette)
                vim.g.gruvbox_material_background             = s.contrast
                vim.g.gruvbox_material_foreground             = s.palette
                vim.g.gruvbox_material_palette                = s.palette -- compat (older versions)
                vim.g.gruvbox_material_transparent_background = s.transparent
                vim.g.gruvbox_material_enable_italic          = s.italic and 1 or 0
                vim.g.gruvbox_material_enable_bold            = s.bold and 1 or 0
                vim.g.gruvbox_material_sign_column_background = s.gutterless and "none" or "bg0"

                -- Load scheme
                vim.cmd.colorscheme("gruvbox-material")

                -- Keep statusline synced (lualine theme="auto")
                pcall(function() require("lualine").refresh() end)

                vim.notify(
                    ("Gruvbox Material → %s/%s%s%s%s  [%s]"):format(
                        s.background, s.contrast,
                        s.transparent > 0 and (" +transparent(" .. s.transparent .. ")") or "",
                        s.italic and " +italic" or "",
                        s.bold and " +bold" or "",
                        s.palette
                    ),
                    vim.log.levels.INFO
                )
            end

            ---------------------------------------------------------------------------
            -- Small helpers
            ---------------------------------------------------------------------------
            local function cycle_contrast()
                local order = { "soft", "medium", "hard" }
                local s = vim.g._gruvboxmat or { contrast = "soft" }
                local i = 1
                for k, v in ipairs(order) do if v == s.contrast then
                        i = k
                        break
                    end end
                apply({ contrast = order[(i % #order) + 1] })
            end

            local function cycle_palette()
                local order = { "material", "mix", "original" }
                local s = vim.g._gruvboxmat or { palette = "material" }
                local i = 1
                for k, v in ipairs(order) do if v == s.palette then
                        i = k
                        break
                    end end
                apply({ palette = order[(i % #order) + 1] })
            end

            local function cycle_transparent()
                local s = vim.g._gruvboxmat or { transparent = 0 }
                local next = ((s.transparent or 0) + 1) % 3 -- 0 -> 1 -> 2 -> 0
                apply({ transparent = next })
            end

            local function toggle_bg()
                local s = vim.g._gruvboxmat or { background = vim.o.background or "dark" }
                apply({ background = (s.background == "dark") and "light" or "dark" })
            end

            local function toggle_it()
                local s = vim.g._gruvboxmat or {}; apply({ italic = not s.italic })
            end
            local function toggle_bold()
                local s = vim.g._gruvboxmat or {}; apply({ bold = not s.bold })
            end
            local function toggle_gut()
                local s = vim.g._gruvboxmat or {}; apply({ gutterless = not s.gutterless })
            end

            return {
                -- Apply default profile quickly
                { "<leader>ug1", function() apply() end, desc = "Gruvbox: Apply" },

                -- Variants & palette
                { "<leader>ugc", cycle_contrast, desc = "Gruvbox: Cycle contrast (soft/med/hard)" },
                { "<leader>ugp", cycle_palette, desc = "Gruvbox: Cycle palette (material/mix/original)" },
                { "<leader>ugl", toggle_bg, desc = "Gruvbox: Toggle light/dark" },

                -- Toggles
                { "<leader>ugt", cycle_transparent, desc = "Gruvbox: Transparency 0→1→2" },
                { "<leader>ugi", toggle_it, desc = "Gruvbox: Toggle italic" },
                { "<leader>ugb", toggle_bold, desc = "Gruvbox: Toggle bold" },
                { "<leader>ugg", toggle_gut, desc = "Gruvbox: Toggle gutter bg" },
            }
        end,
    },
}
