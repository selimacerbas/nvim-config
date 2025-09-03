-- Theme switcher: on-demand theme loading + quick keys via which-key
return {
    -- ── install themes (no colorscheme applied here) ──────────────────────────
    { "rose-pine/neovim",         name = "rose-pine",  lazy = true,    priority = 1000 },
    { "shaunsingh/nord.nvim",     lazy = true,         priority = 1000 },
    { "folke/tokyonight.nvim",    lazy = true,         priority = 1000 },
    { "catppuccin/nvim",          name = "catppuccin", lazy = true,    priority = 1000 },
    { "rebelot/kanagawa.nvim",    lazy = true,         priority = 1000 },
    { "EdenEast/nightfox.nvim",   lazy = true,         priority = 1000 },
    { "sainnhe/everforest",       lazy = true,         priority = 1000 },
    { "sainnhe/edge",             lazy = true,         priority = 1000 },
    { "sainnhe/gruvbox-material", lazy = true,         priority = 1000 },

    -- ── tiny helper that defines the switching logic + keys ───────────────────
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        config = function()
            local themes = {
                ["rose-pine"]        = {
                    plugin = "rose-pine",
                    pre = function()
                        -- keep your Rose-Pine customizations when switching to it
                        local rp = require("rose-pine")
                        rp.setup({
                            variant = "auto",
                            dark_variant = "main",
                            extend_background_behind_borders = true,
                            enable = { terminal = true, legacy_highlights = true, migrations = true },
                            styles = { bold = false, italic = false, transparency = false },
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
                            highlight_groups = {
                                ["@type"]              = { fg = "#869688" },
                                ["@variable"]          = { fg = "#b4bce0" },
                                NormalFloat            = { bg = "NONE" },
                                FloatBorder            = { bg = "NONE", fg = "muted" },
                                FloatTitle             = { bg = "NONE", fg = "subtle" },
                                WhichKeyFloat          = { bg = "NONE" },
                                Pmenu                  = { bg = "NONE" },
                                PmenuSel               = { bg = "rose" },
                                TelescopeNormal        = { bg = "NONE" },
                                TelescopeBorder        = { bg = "NONE", fg = "muted" },
                                TelescopePromptNormal  = { bg = "NONE" },
                                TelescopePromptBorder  = { bg = "NONE", fg = "muted" },
                                TelescopeResultsNormal = { bg = "NONE" },
                                TelescopePreviewNormal = { bg = "NONE" },
                                LspInfoBorder          = { link = "FloatBorder" },
                            },
                        })
                    end,
                },
                nord                 = { plugin = "nord.nvim" },
                tokyonight           = { plugin = "tokyonight.nvim" },
                catppuccin           = { plugin = "catppuccin" },
                kanagawa             = { plugin = "kanagawa.nvim" },
                nightfox             = { plugin = "nightfox.nvim" },
                everforest           = { plugin = "everforest" },
                edge                 = { plugin = "edge" },
                ["gruvbox-material"] = { plugin = "gruvbox-material" },
            }

            local function set_theme(name)
                local t = themes[name]
                if not t then
                    vim.notify("Theme not registered: " .. name, vim.log.levels.WARN)
                    return
                end
                -- ensure plugin is loaded before :colorscheme
                pcall(require("lazy").load, { plugins = { t.plugin } })
                if t.pre then pcall(t.pre) end
                local ok, err = pcall(vim.cmd.colorscheme, name)
                if not ok then
                    vim.notify(("Failed to load %s: %s"):format(name, err), vim.log.levels.ERROR)
                    return
                end
                -- refresh lualine to pick the palette
                local ok_ll, lualine = pcall(require, "lualine")
                if ok_ll and lualine.refresh then pcall(lualine.refresh) end
                vim.g.__last_theme = name
            end

            local order = {
                "rose-pine", "nord", "tokyonight", "catppuccin",
                "kanagawa", "nightfox", "everforest", "edge", "gruvbox-material",
            }
            local function idx_of(name)
                for i, n in ipairs(order) do if n == name then return i end end
                return 1
            end
            local function cycle(delta)
                local cur = vim.g.colors_name or order[1]
                local i = idx_of(cur)
                i = ((i - 1 + delta) % #order) + 1
                set_theme(order[i])
            end

            -- which-key menu under <leader>u (UI / Theme)
            local ok_wk, wk = pcall(require, "which-key")
            if not ok_wk then return end
            if wk.add then
                wk.add({
                    -- { "<leader>ut",  group = "UI / Theme" },
                    { "<leader>utr", function() set_theme("rose-pine") end,        desc = "Rose Pine" },
                    { "<leader>utn", function() set_theme("nord") end,             desc = "Nord" },
                    { "<leader>utt", function() cycle(1) end,                      desc = "Theme: Next" },
                    { "<leader>utT", function() cycle(-1) end,                     desc = "Theme: Prev" },
                    { "<leader>utc", function() set_theme("catppuccin") end,       desc = "Catppuccin" },
                    { "<leader>utk", function() set_theme("kanagawa") end,         desc = "Kanagawa" },
                    { "<leader>utf", function() set_theme("nightfox") end,         desc = "Nightfox" },
                    { "<leader>ute", function() set_theme("everforest") end,       desc = "Everforest" },
                    { "<leader>utE", function() set_theme("edge") end,             desc = "Edge" },
                    { "<leader>utg", function() set_theme("gruvbox-material") end, desc = "Gruvbox Material" },
                })
            else
                wk.register({
                    u = {
                        -- name = "UI / Theme",
                        r = { function() set_theme("rose-pine") end, "Rose Pine" },
                        n = { function() set_theme("nord") end, "Nord" },
                        t = { function() cycle(1) end, "Theme: Next" },
                        T = { function() cycle(-1) end, "Theme: Prev" },
                        c = { function() set_theme("catppuccin") end, "Catppuccin" },
                        k = { function() set_theme("kanagawa") end, "Kanagawa" },
                        f = { function() set_theme("nightfox") end, "Nightfox" },
                        e = { function() set_theme("everforest") end, "Everforest" },
                        E = { function() set_theme("edge") end, "Edge" },
                        g = { function() set_theme("gruvbox-material") end, "Gruvbox Material" },
                    },
                }, { prefix = "<leader>" })
            end

            -- keep lualine synced whenever colorscheme changes (manual or via set_theme)
            vim.api.nvim_create_autocmd("ColorScheme", {
                callback = function()
                    local ok_ll, lualine = pcall(require, "lualine")
                    if ok_ll and lualine.refresh then pcall(lualine.refresh) end
                end,
            })

            -- optional: if no scheme chosen yet, start with rose-pine
            if not vim.g.colors_name then pcall(set_theme, "rose-pine") end
        end,
    },
}
