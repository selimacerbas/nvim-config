return {
    {
        "catppuccin/nvim",
        name = "catppuccin",
        lazy = true,
        dependencies = { "folke/which-key.nvim" },

        -- show the group early in which-key
        init = function()
            local ok, wk = pcall(require, "which-key")
            if ok then
                (wk.add or wk.register)({
                        { "<leader>u",  group = "UI" },
                        { "<leader>uc", group = "Catppuccin" },
                    })
            end
        end,

        -- keys lazy-load the theme and run helpers
        keys = function()
            local flavours = { "latte", "frappe", "macchiato", "mocha" }

            local function apply(opts)
                local s   = vim.g._catppuccin or {
                    flavour      = "mocha", -- latte | frappe | macchiato | mocha
                    transparent  = false, -- transparent_background
                    term_colors  = true, -- apply palette to :terminal
                    dim_inactive = false, -- dim inactive windows
                    styles       = { -- see README for groups
                        comments = { "italic" },
                        keywords = { "bold" },
                    },
                }
                opts      = opts or {}
                s.flavour = opts.flavour or s.flavour
                if opts.transparent ~= nil then s.transparent = opts.transparent end
                if opts.term_colors ~= nil then s.term_colors = opts.term_colors end
                if opts.dim_inactive ~= nil then s.dim_inactive = opts.dim_inactive end
                if opts.styles ~= nil then s.styles = opts.styles end
                vim.g._catppuccin = s

                -- keep :set background in sync with the chosen flavour
                vim.o.background = (s.flavour == "latte") and "light" or "dark"

                require("catppuccin").setup({
                    flavour = s.flavour,
                    transparent_background = s.transparent,
                    term_colors = s.term_colors,
                    dim_inactive = { enabled = s.dim_inactive, percentage = 0.15 },
                    styles = s.styles,
                    background = { light = "latte", dark = "mocha" },
                    integrations = {
                        treesitter = true,
                        which_key = true,
                        lualine = true,
                        gitsigns = true,
                        cmp = true,
                        telescope = true,
                        nvimtree = true,
                        mason = true,
                        native_lsp = { enabled = true },
                    },
                })
                vim.cmd.colorscheme("catppuccin")

                -- keep statusline synced
                pcall(function() require("lualine").refresh() end)

                vim.notify(("Catppuccin → %s%s%s"):format(
                    s.flavour,
                    s.transparent and " (transparent)" or "",
                    s.dim_inactive and " (dim inactive)" or ""
                ))
            end

            local function set_flavour(name) return function() apply({ flavour = name }) end end
            local function cycle()
                local s = vim.g._catppuccin or { flavour = "mocha" }
                local idx = 1
                for i, f in ipairs(flavours) do if f == s.flavour then
                        idx = i
                        break
                    end end
                apply({ flavour = flavours[(idx % #flavours) + 1] })
            end
            local function toggle_transparent()
                local s = vim.g._catppuccin or {}
                apply({ transparent = not s.transparent })
            end
            local function toggle_dim()
                local s = vim.g._catppuccin or {}
                apply({ dim_inactive = not s.dim_inactive })
            end
            local function toggle_comments_italic()
                local s = vim.g._catppuccin or { styles = { comments = { "italic" } } }
                local has_italic = false
                for _, v in ipairs(s.styles.comments or {}) do if v == "italic" then
                        has_italic = true
                        break
                    end end
                s.styles.comments = has_italic and {} or { "italic" }
                apply({ styles = s.styles })
            end
            local function toggle_bg() -- light↔dark (maps to latte↔mocha)
                local bg = vim.o.background
                apply({ flavour = (bg == "light") and "mocha" or "latte" })
            end

            return {
                -- apply flavours
                { "<leader>uc1", set_flavour("latte"), desc = "Catppuccin: Latte (light)" },
                { "<leader>uc2", set_flavour("frappe"), desc = "Catppuccin: Frappe" },
                { "<leader>uc3", set_flavour("macchiato"), desc = "Catppuccin: Macchiato" },
                { "<leader>uc4", set_flavour("mocha"), desc = "Catppuccin: Mocha (dark)" },
                { "<leader>ucc", cycle, desc = "Catppuccin: Cycle flavours" },

                -- toggles
                { "<leader>uct", toggle_transparent, desc = "Catppuccin: Toggle transparent" },
                { "<leader>ucd", toggle_dim, desc = "Catppuccin: Toggle dim inactive" },
                { "<leader>uci", toggle_comments_italic, desc = "Catppuccin: Toggle italic comments" },
                { "<leader>ucl", toggle_bg, desc = "Catppuccin: Toggle light/dark (latte↔mocha)" },
            }
        end,
    },
}
