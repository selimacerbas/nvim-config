return {
    {
        "EdenEast/nightfox.nvim",
        lazy = true,
        dependencies = { "folke/which-key.nvim" },

        -- Show group early in which-key
        init = function()
            local ok, wk = pcall(require, "which-key")
            if ok then
                (wk.add or wk.register)({
                        { "<leader>u",  group = "UI" },
                        { "<leader>uf", group = "Nightfox" },
                    })
            end
        end,

        -- Lazy keymaps that load the plugin on first use
        keys = function()
            local flavors = { "nightfox", "duskfox", "nordfox", "dayfox", "dawnfox", "terafox", "carbonfox" }

            local function apply(opts)
                local s                = vim.g._nightfox_custom or {
                    flavor = "nightfox",
                    transparent = false,
                    dim_inactive = false,
                    styles = { comments = "italic", keywords = "bold" },
                }
                opts                   = opts or {}
                s.flavor               = opts.flavor or s.flavor
                s.transparent          = (opts.transparent ~= nil) and opts.transparent or s.transparent
                s.dim_inactive         = (opts.dim_inactive ~= nil) and opts.dim_inactive or s.dim_inactive
                s.styles               = opts.styles or s.styles
                vim.g._nightfox_custom = s

                local light_flavor     = (s.flavor == "dayfox" or s.flavor == "dawnfox")
                vim.o.background       = light_flavor and "light" or "dark"

                require("nightfox").setup({
                    options = {
                        transparent = s.transparent,
                        terminal_colors = true,
                        dim_inactive = { enabled = s.dim_inactive, percentage = 0.15 },
                        styles = {
                            comments = s.styles.comments, -- "italic" | "NONE"
                            keywords = s.styles.keywords, -- "bold"   | "NONE"
                        },
                    },
                })
                vim.cmd.colorscheme(s.flavor)

                -- keep lualine in sync
                pcall(function() require("lualine").refresh() end)

                vim.notify(string.format(
                    "Colorscheme → %s%s%s",
                    s.flavor,
                    s.transparent and " (transparent)" or "",
                    s.dim_inactive and " (dim inactive)" or ""
                ), vim.log.levels.INFO)
            end

            local function cycle()
                local s = vim.g._nightfox_custom or { flavor = "nightfox" }
                local idx = 1
                for i, f in ipairs(flavors) do if f == s.flavor then
                        idx = i
                        break
                    end end
                apply({ flavor = flavors[(idx % #flavors) + 1] })
            end

            local function set_flavor(name) return function() apply({ flavor = name }) end end
            local function toggle_transparent()
                local s = vim.g._nightfox_custom or {}
                apply({ transparent = not s.transparent })
            end
            local function toggle_dim()
                local s = vim.g._nightfox_custom or {}
                apply({ dim_inactive = not s.dim_inactive })
            end
            local function toggle_comments_italic()
                local s = vim.g._nightfox_custom or { styles = {} }
                local v = (s.styles.comments == "italic") and "NONE" or "italic"
                s.styles.comments = v
                apply({ styles = s.styles })
            end
            local function toggle_keywords_bold()
                local s = vim.g._nightfox_custom or { styles = {} }
                local v = (s.styles.keywords == "bold") and "NONE" or "bold"
                s.styles.keywords = v
                apply({ styles = s.styles })
            end

            return {
                -- Apply + cycle
                { "<leader>uf1", set_flavor("nightfox"),  desc = "Nightfox: Apply nightfox" },
                { "<leader>uf2", set_flavor("duskfox"),   desc = "Nightfox: Apply duskfox" },
                { "<leader>uf3", set_flavor("nordfox"),   desc = "Nightfox: Apply nordfox" },
                { "<leader>uf4", set_flavor("dayfox"),    desc = "Nightfox: Apply dayfox" },
                { "<leader>uf5", set_flavor("dawnfox"),   desc = "Nightfox: Apply dawnfox" },
                { "<leader>uf6", set_flavor("terafox"),   desc = "Nightfox: Apply terafox" },
                { "<leader>uf7", set_flavor("carbonfox"), desc = "Nightfox: Apply carbonfox" },
                { "<leader>ufc", cycle,                   desc = "Nightfox: Cycle variants" },

                -- Toggles
                { "<leader>uft", toggle_transparent,      desc = "Nightfox: Toggle transparent" },
                { "<leader>ufd", toggle_dim,              desc = "Nightfox: Toggle dim inactive" },
                { "<leader>ufi", toggle_comments_italic,  desc = "Nightfox: Toggle italic comments" },
                { "<leader>ufk", toggle_keywords_bold,    desc = "Nightfox: Toggle bold keywords" },
            }
        end,
    },
}
